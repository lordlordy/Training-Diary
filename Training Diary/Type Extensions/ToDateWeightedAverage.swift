//
//  ToDateWeightedAverage.swift
//  Training Diary
//
//  Created by Steven Lord on 30/11/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Foundation

class ToDateWeightedAverage: RollingPeriodWeightedAverage{
    
    var resetRule: (Date) -> Bool
    
    init(size: Int, rule: @escaping (Date) -> Bool){
        resetRule = rule
        super.init(size: size)
    }
    
    override func addAndReturnAverage(forDate date: Date, value v: Double, wieghting w: Double) -> Double? {
        let average = super.addAndReturnAverage(forDate: date, value: v, wieghting: w)
        if resetRule(date){
            resetQueue()
        }
        return average
    }
}
