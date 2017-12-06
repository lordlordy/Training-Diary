//
//  PeriodSum.swift
//  Training Diary
//
//  Created by Steven Lord on 01/12/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Foundation

/* Like to date sum but only returns a value at the end of the period.
 */
class PeriodSum: ToDateSum{
    
    
    override func addAndReturnSum(forDate date: Date, value v: Double) -> Double? {
        let sum = super.addAndReturnSum(forDate: date, value: v)
        if resetRule(date){
            return sum
        }
        return nil
    }
    
}
