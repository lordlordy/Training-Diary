//
//  RollingSum.swift
//  Training Diary
//
//  Created by Steven Lord on 18/10/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Foundation

public struct RollingSum{
    
    private var buffer: [Double]
    private var writeIndex: Int = 0
    public var total: Double = 0.0
    
    public init(size:Int){
        buffer = Array.init(repeating: 0.0, count: size)
    }
    
    func printBuffer(){
        print("\(buffer) total:\(total)")
    }
    
    func read() -> Double{
        return buffer[writeIndex]
    }
    
    mutating func add(_ value: Double){
        total = total - buffer[writeIndex] + value
        buffer[writeIndex] = value
        writeIndex  = (writeIndex+1) % buffer.count
    }
    
    mutating func addAndReturnTotal(_ value: Double) -> Double{
        add(value)
        return total
    }
    
}
