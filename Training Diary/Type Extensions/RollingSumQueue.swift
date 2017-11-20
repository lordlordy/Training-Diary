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
    
    func resetQueue(){
        sumQueue.resetQueue()
        rollingSum = 0.0
    }
    
}
