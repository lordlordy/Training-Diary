//
//  ToDateWeightedAverage.swift
//  Training Diary
//
//  Created by Steven Lord on 30/11/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Foundation

class ToDateWeightedAverage: RollingPeriodWeightedAverage{
    
    var resetRule: ((Date) -> Bool)
    
    init(size: Int, rule: @escaping (Date) -> Bool){
        resetRule = rule
        super.init(size: size)
    }
    
    override func addAndReturnValue(forDate date: Date?, value v: Double, weighting w: Double? = 1.0) -> Double?{
        if let d = date{
            let average = super.addAndReturnValue(forDate: d, value: v, weighting: w)
            if resetRule(d){
                resetQueue()
            }
            return average
        }
        return nil
    }
    

}
