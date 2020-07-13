//
//  LargeSpikePricePredictor.swift
//  ACStock
//
//  Created by Chang Wen-Lung on 28.04.20.
//  Copyright © 2020 Accelgor. All rights reserved.
//

import Foundation

final class LargeSpikePricePredictor: PricePredictingLogic {
    enum PredictError: Error {
        case outOfBound
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

    private func pridictStrongRiseStage(basePrice: Double, section: Int) throws -> (upper: Double, lower: Double) {
        guard section < 3, section >= 0 else { throw PredictError.outOfBound }
        switch section {
        case 0: return (basePrice * 1.4, basePrice * 0.9)
        case 1: return (basePrice * 2.0, basePrice * 1.4)
        case 2: return (basePrice * 6.0, basePrice * 2.0)
        default: assertionFailure()
        }
    }
    
    private func pridictWeakRiseStage(basePrice: Double, section: Int) throws -> (upper: Double, lower: Double) {
        guard section < 2, section >= 0 else { throw PredictError.outOfBound }
        switch section {
        case 0: return (basePrice * 2.0, basePrice * 1.4)
        case 1: return (basePrice * 1.4, basePrice * 0.9)
        default: assertionFailure()
        }
    }

    private func pridictFailStage(
        basePrice: Double,
        previousUpperRatio: Double,
        previousLowerRatio: Double
    ) -> (upper: Double, lower: Double) {
        (basePrice * (previousUpperRatio - 0.03), basePrice * (previousLowerRatio - 0.05)
    }
}
