//
//  RollingPeriodWeightedAverage.swift
//  Training Diary
//
//  Created by Steven Lord on 30/11/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Foundation

class RollingPeriodWeightedAverage: RollingPeriodCalculator{
    
    fileprivate var rollingSumQueue: RollingSumQueue
    fileprivate var rollingWeightsQueue: RollingSumQueue
    
    init(size s: Int){
        rollingSumQueue = RollingSumQueue(size: s)
        rollingWeightsQueue = RollingSumQueue(size: s)
    }
    
    func addAndReturnValue(forDate date: Date?, value v: Double, weighting w: Double? = 1.0) -> Double?{
        let sum = rollingSumQueue.addAndReturnSum(value: v * w!)
        let weighting = rollingWeightsQueue.addAndReturnSum(value: w!)
        if weighting < 0.000001{return 0.0}
        return sum / weighting
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
    

}
