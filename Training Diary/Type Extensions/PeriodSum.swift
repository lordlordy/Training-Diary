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
    
    override func addAndReturnValue(forDate date: Date?, value v: Double, weighting w: Double? = nil) -> Double?{
        if let d = date{
            let sum = super.addAndReturnValue(forDate: d, value: v)
            if resetRule(d){
                return sum
            }
        }
        return nil
    }
    
    
}
