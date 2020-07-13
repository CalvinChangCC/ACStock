//
//  PricePredictionWorker.swift
//  ACStock
//
//  Created by Chang Wen-Lung on 27.04.20.
//  Copyright © 2020 Accelgor. All rights reserved.
//

import Foundation

enum Candlestick {
    case fluctuating
    case decreaing
    case largeSpike
    case smallSpike
}

enum PredictInputDataType {
    case initData
    case monday(Section)
    case tuesday(Section)
    case wednesDay(Section)
    case thursday(Section)
    case friday(Section)

    enum Section {
        case morning
        case afternoon
    }
}

enum PredictError {
    case notEnoughData
    case outOfBound
}

enum PredictResult {
    case success(Candlestick)
    case warning([Candlestick], lackData: [PredictInputDataType])
    case error(PredictError, lackData: [PredictInputDataType])
}

protocol PricePredictionWorkingLogic {
    func predictCandlestick(weekly: WeeklyPrice) -> PredictResult
}

final class PricePredictionWorker: PricePredictionWorkingLogic {
    func predictCandlestick(weekly: WeeklyPrice) -> PredictResult {
        guard let mondayMorning = weekly.mondayPrice?.morningPrice else {
            return .error(.notEnoughData, lackData: [.initData, .monday(.morning)])
        }

        let ratio = mondayMorning / weekly.purchasePrice

        switch ratio {
        case 0.9 ..< 10:
            return highRationChart(weekly: weekly)
        case 0.85 ..< 0.9:
            return mediumRatioChart(weekly: weekly)
        case 0.8 ..< 0.85:
            return .success(.smallSpike)
        case 0.6 ..< 0.8:
            return lowRatioChart(weekly: weekly)
        case -10 ..< 0.6:
            return .success(.smallSpike)
        default:
            return .error(.outOfBound, lackData: [])
        }
    }

    private func highRationChart(weekly: WeeklyPrice) -> PredictResult {
        if let mondayAfternoon = weekly.mondayPrice?.afternoonPrice,
            let tuesdayMorning = weekly.tuesdayPrice?.morningPrice {
            let ratioMonday = mondayAfternoon / weekly.purchasePrice
            let ratioTuesday = tuesdayMorning / weekly.purchasePrice
            return ratioMonday < 0.8 || ratioTuesday < 1.4
                ? .success(.fluctuating)
                : .success(.smallSpike)
        } else if let mondayAfternoon = weekly.mondayPrice?.afternoonPrice {
            let ratio = mondayAfternoon / weekly.purchasePrice
            return ratio > 0.8
                ? .warning([.smallSpike, .fluctuating], lackData: [.tuesday(.morning)])
                : .success(.fluctuating)
        } else if let tuesdayMorning = weekly.tuesdayPrice?.morningPrice {
            let ratio = tuesdayMorning / weekly.purchasePrice
            return ratio >= 1.4
                ? .success(.smallSpike)
                : .success(.fluctuating)
        } else {
            return .warning([.smallSpike, .fluctuating], lackData: [.monday(.afternoon), .tuesday(.morning)])
        }
    }

    // swiftlint:disable:next function_body_length
    private func mediumRatioChart(weekly: WeeklyPrice) -> PredictResult {
        if let mondayMorning = weekly.mondayPrice?.morningPrice,
            let mondayAfternoon = weekly.mondayPrice?.afternoonPrice,
            let tuesdayMorning = weekly.tuesdayPrice?.morningPrice,
            let tuesdayAfternoon = weekly.tuesdayPrice?.afternoonPrice,
            let wednesdayMorning = weekly.wednesdayPrice?.morningPrice,
            let wednesdayAfternoon = weekly.wednesdayPrice?.afternoonPrice,
            let thursdayMorning = weekly.thursdayPrice?.morningPrice,
            let thursdayAfternoon = weekly.thursdayPrice?.afternoonPrice {

            let prices = [
                mondayMorning,
                mondayAfternoon,
                tuesdayMorning,
                tuesdayAfternoon,
                wednesdayMorning,
                wednesdayAfternoon,
                thursdayMorning,
                thursdayAfternoon,
                weekly.fridayPrice?.morningPrice
                ]
                .compactMap { $0 }

            if prices.sorted().reversed() == prices {
                return .success(.decreaing)
            } else {
                for (index, price) in prices.enumerated() {
                    guard index > 0, index < prices.count - 1 else { continue }
                    if price > prices[index - 1] {
                        return prices[index + 1] / weekly.purchasePrice > 1.4
                            ? .success(.largeSpike)
                            : .success(.smallSpike)
                    }
                }

                if prices.count < 9 {
                    return .warning([.largeSpike, .smallSpike], lackData: [.friday(.morning)])
                }
                return .success(.decreaing)
            }
        } else { // Not provide all the price data
            let prices = [
                weekly.mondayPrice?.morningPrice,
                weekly.mondayPrice?.afternoonPrice,
                weekly.tuesdayPrice?.morningPrice,
                weekly.tuesdayPrice?.afternoonPrice,
                weekly.wednesdayPrice?.morningPrice,
                weekly.wednesdayPrice?.afternoonPrice,
                weekly.thursdayPrice?.morningPrice,
                weekly.thursdayPrice?.afternoonPrice,
                weekly.fridayPrice?.morningPrice
            ]

            for (index, price) in prices.enumerated() {
                guard index > 0, index < prices.count - 1 else { continue }
                guard let newPrice = price, let oldPrice = prices[index - 1] else { continue }
                if let futurePrice = prices[index + 1] {
                    guard newPrice > oldPrice else { continue }
                    return futurePrice / weekly.purchasePrice > 1.4
                        ? .success(.largeSpike)
                        : .success(.smallSpike)
                }
            }

            return .warning([.largeSpike, .smallSpike, .decreaing], lackData: [])
        }
    }

    // swiftlint:disable:next function_body_length
    private func lowRatioChart(weekly: WeeklyPrice) -> PredictResult {
        if let mondayMorning = weekly.mondayPrice?.morningPrice,
            let mondayAfternoon = weekly.mondayPrice?.afternoonPrice,
            let tuesdayMorning = weekly.tuesdayPrice?.morningPrice {
            let ratioDiffMonday = (mondayMorning - mondayAfternoon) / weekly.purchasePrice
            let ratioDiffTuesday = (mondayAfternoon - tuesdayMorning) / weekly.purchasePrice
            if ratioDiffMonday >= 0.05 || ratioDiffTuesday >= 0.05 {
                return .success(.fluctuating)
            } else if ratioDiffMonday < 0.04 || ratioDiffTuesday < 0.04 {
                return.success(.smallSpike)
            } else {
                // Special stituation 1
                if let mondayMorning = weekly.mondayPrice?.morningPrice,
                    let mondayAfternoon = weekly.mondayPrice?.afternoonPrice,
                    let tuesdayMorning = weekly.tuesdayPrice?.morningPrice,
                    let tuesdayAfternoon = weekly.tuesdayPrice?.afternoonPrice {
                    if mondayMorning > mondayAfternoon,
                        mondayAfternoon > tuesdayMorning,
                        tuesdayMorning < tuesdayAfternoon {
                        if let wednesdayAfternoon = weekly.wednesdayPrice?.afternoonPrice {
                            let ratio = wednesdayAfternoon / weekly.purchasePrice
                            return ratio >= 1.4
                                ? .success(.smallSpike)
                                : .success(.fluctuating)
                        } else {
                            return .warning([.smallSpike, .fluctuating], lackData: [.wednesDay(.afternoon)])

                        }
                    } else {
                        return .success(.fluctuating)
                    }
                }

                // Special stituation 2
                if let mondayMorning = weekly.mondayPrice?.morningPrice,
                    let mondayAfternoon = weekly.mondayPrice?.afternoonPrice,
                    let tuesdayMorning = weekly.tuesdayPrice?.morningPrice {
                    if mondayMorning > mondayAfternoon,
                        mondayAfternoon < tuesdayMorning {
                        if let wednesdayMorning = weekly.wednesdayPrice?.morningPrice {
                            let ratio = wednesdayMorning / weekly.purchasePrice
                            return ratio >= 1.4
                                ? .success(.smallSpike)
                                : .success(.fluctuating)
                        } else {
                            return .warning([.smallSpike, .fluctuating], lackData: [.wednesDay(.morning)])

                        }
                    } else {
                        return .success(.fluctuating)
                    }
                }
                return .warning([.smallSpike, .fluctuating], lackData: [.monday(.morning), .monday(.afternoon), .tuesday(.morning)])
            }
        } else if let mondayMorning = weekly.mondayPrice?.morningPrice,
            let mondayAfternoon = weekly.mondayPrice?.afternoonPrice {
            let ratio = (mondayMorning - mondayAfternoon) / weekly.purchasePrice
            return ratio >= 0.05
                ? .success(.fluctuating)
                : .warning([.smallSpike, .fluctuating], lackData: [.tuesday(.morning)])
        } else {
            return .warning([.smallSpike, .fluctuating], lackData: [.monday(.afternoon), .tuesday(.morning)])
        }
    }
}
