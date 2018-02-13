//
//  RollingPeriodWeightedAverage.swift
//  Training Diary
//
//  Created by Steven Lord on 30/11/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Foundation

class RollingPeriodWeightedAverage{
    
    fileprivate var rollingSumQueue: RollingSumQueue
    fileprivate var rollingWeightsQueue: RollingSumQueue
    
    init(size s: Int){
        rollingSumQueue = RollingSumQueue(size: s)
        rollingWeightsQueue = RollingSumQueue(size: s)
    }
    
    func addAndReturnAverage(forDate date: Date, value v: Double, wieghting w: Double) -> Double? {
        let sum = rollingSumQueue.addAndReturnSum(value: v * w)
        let weighting = rollingWeightsQueue.addAndReturnSum(value: w)
        if weighting < 0.000001{return 0.0}
        return sum / weighting
    }
    
    func resetQueue(){
        rollingSumQueue.resetQueue()
        rollingWeightsQueue.resetQueue()
    }
    
    func preLoadData(forDate d: Date) -> Date{
        return d.addDays(numberOfDays: -rollingSumQueue.size())
    }
    
}
