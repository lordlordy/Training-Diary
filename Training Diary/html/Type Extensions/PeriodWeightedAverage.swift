//
//  PeriodWeightedAverage.swift
//  Training Diary
//
//  Created by Steven Lord on 01/12/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Foundation

class PeriodWeightedAverage: ToDateWeightedAverage{
    
    override func addAndReturnValue(forDate date: Date?, value v: Double, weighting w: Double? = 1.0) -> Double?{
        if let d = date{
            let average = super.addAndReturnValue(forDate: d, value: v, weighting: w)
            if resetRule(d){
                return average
            }
        }
        return nil
    }
    
}
