//
//  RollingPeriodSum.swift
//  Training Diary
//
//  Created by Steven Lord on 24/11/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Foundation

class RollingPeriodSum{
    
    fileprivate var rollingSumQueue: RollingSumQueue
    
    init(size s: Int){
        rollingSumQueue = RollingSumQueue(size: s)
    }
    
    //This method doesn't use the date. Subclasses do. 
    func addAndReturnSum(forDate date: Date, value v: Double) -> Double? {
            return rollingSumQueue.addAndReturnSum(value: v)
    }
     
    func resetQueue(){
        rollingSumQueue.resetQueue()
    }

    func preLoadData(forDate d: Date) -> Date{
        return d.addDays(numberOfDays: -rollingSumQueue.size())
    }
    
}
