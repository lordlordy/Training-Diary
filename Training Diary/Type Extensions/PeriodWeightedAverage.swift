//
//  PeriodWeightedAverage.swift
//  Training Diary
//
//  Created by Steven Lord on 01/12/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Foundation

class PeriodWeightedAverage: ToDateWeightedAverage{
    
    override func addAndReturnAverage(forDate date: Date, value v: Double, wieghting w: Double) -> Double? {
        let average = super.addAndReturnAverage(forDate: date, value: v, wieghting: w)
        if resetRule(date){
            return average
        }
        return nil
    }
    
    
}
