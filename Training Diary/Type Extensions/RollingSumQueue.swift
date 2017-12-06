//
//  RollingSumQueue.swift
//  Training Diary
//
//  Created by Steven Lord on 06/11/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Foundation

class RollingSumQueue{
    private var sumQueue = Queue<Double>()
    private var rollingSum: Double = 0.0
    
    init(size: Int){
        sumQueue.maxSize = size
    }
    
    func addAndReturnSum(value v: Double) -> Double{
        rollingSum += v
        if let valueRemoved = sumQueue.enqueue(v){
            rollingSum -= valueRemoved
        }
        return rollingSum
    }
    
    func addAndReturnAverage(value v: Double) -> Double{
        let sum  = addAndReturnSum(value: v)
        let numberNonZeroOfItems = sumQueue.currentSize - numberOfZeroes()
        

        if numberNonZeroOfItems > 0{
            return sum / Double(numberNonZeroOfItems)
        }
        return sum
    }
    
    private func numberOfZeroes() -> Int{
        return sumQueue.array().filter({$0 <= 0.0001}).count
    }
    
    func resetQueue(){
        sumQueue.resetQueue()
        rollingSum = 0.0
    }
    
    func size() -> Int{
        return sumQueue.maxSize
    }
    
}
