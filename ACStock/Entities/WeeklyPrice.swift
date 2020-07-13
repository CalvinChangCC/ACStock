//
//  WeeklyPrice.swift
//  ACStock
//
//  Created by Chang Wen-Lung on 27.04.20.
//  Copyright © 2020 Accelgor. All rights reserved.
//

import Foundation

struct WeeklyPrice {
    let purchasePrice: Double
    private(set) var mondayPrice: DailyPrice?
    private(set) var tuesdayPrice: DailyPrice?
    private(set) var wednesdayPrice: DailyPrice?
    private(set) var thursdayPrice: DailyPrice?
    private(set) var fridayPrice: DailyPrice?
    
    mutating func set(monday: DailyPrice) {
        mondayPrice = monday
    }
    
    mutating func set(tuesday: DailyPrice) {
        tuesdayPrice = tuesday
    }
    
    mutating func set(wednesday: DailyPrice) {
        wednesdayPrice = wednesday
    }
    
    mutating func set(thursday: DailyPrice) {
        thursdayPrice = thursday
    }
    
    mutating func set(friday: DailyPrice) {
        fridayPrice = friday
    }
}
