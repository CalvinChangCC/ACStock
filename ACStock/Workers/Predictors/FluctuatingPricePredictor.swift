//
//  FluctuatingPricePredictor.swift
//  ACStock
//
//  Created by Chang Wen-Lung on 28.04.20.
//  Copyright © 2020 Accelgor. All rights reserved.
//

import Foundation

struct PricePrediction {
    let highest: [Double]
    let lowest: [Double]
    let current: [Double]
}

enum PricePridictError: Error {
    case notEnoughData(lackof: [PredictInputDataType])
}

protocol PricePredictingLogic {
    func predict(weeklyPrice: WeeklyPrice) throws -> PricePrediction
}

final class FluctuatingPricePredictor: PricePredictingLogic {
    struct Params {
        static let riseUpperRatio = 1.4
        static let riseLowerRatio = 0.9
        static let failUpperRatio = 0.8
        static let failLowerRatio = 0.6
    }

    func predict(weeklyPrice: WeeklyPrice) throws -> PricePrediction {
        guard let mondayMorning = weeklyPrice.mondayPrice?.morningPrice else {
            throw PricePridictError.notEnoughData(lackof: [.monday(.morning)])
        }
        let base = weeklyPrice.purchasePrice
        
        var current: [Double] = []
        var highest: [Double] = []
        var lowest: [Double] = []
        
        for price in weeklyPrice.prices {
            if let price = price {
                current.append(price)
                highest.append(price)
                lowest.append(price)
            } else {
                break
            }
        }
        
        
        // calculate the start point
        if mondayMorning >= base { // Start rise stage 1
            
        } else { // Start fail stage 1
            
        }
        
        return PricePrediction(highest: highest, lowest: lowest, current: current)
    }

    private func pridictRiseStage(basePrice: Double) -> (upper: Double, lower: Double) {
        (basePrice * Params.riseUpperRatio, basePrice * Params.riseLowerRatio)
    }

    private func pridictFailStage(basePrice: Double) -> (upper: Double, lower: Double) {
        (basePrice * Params.failUpperRatio, basePrice * Params.failLowerRatio)
    }
}

extension WeeklyPrice {
    var prices: [Double?] {
        [
            mondayPrice?.morningPrice,
            mondayPrice?.afternoonPrice,
            tuesdayPrice?.morningPrice,
            tuesdayPrice?.afternoonPrice,
            wednesdayPrice?.morningPrice,
            wednesdayPrice?.afternoonPrice,
            thursdayPrice?.morningPrice,
            thursdayPrice?.afternoonPrice,
            fridayPrice?.morningPrice,
            fridayPrice?.afternoonPrice
        ]
    }
}
