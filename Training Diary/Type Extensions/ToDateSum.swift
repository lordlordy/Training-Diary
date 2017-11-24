//
//  ToDateSum.swift
//  Training Diary
//
//  Created by Steven Lord on 24/11/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Foundation

/* Class that calculates a "To Date" sum eg WeekToDate, MonthToDate, YearToDate. Same as a rolling queue but the sum resets
 at the end of the period. This means to initiaze you give it a function that returns true if the sum should reset after returning
 current sum */
class ToDateSum: RollingPeriodSum{
    
    private var resetRule: (Date) -> Bool
    
    init(size: Int, rule: @escaping (Date) -> Bool){
        resetRule = rule
        super.init(size: size)
    }
    
    override func addAndReturnSum(forDate date: Date, value v: Double) -> Double {
        let sum = super.addAndReturnSum(forDate: date, value: v)
        if resetRule(date){
            resetQueue()
        }
        return sum
    }
}
