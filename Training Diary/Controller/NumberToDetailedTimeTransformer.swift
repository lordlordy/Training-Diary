//
//  NumberToDetailedTimeTransformer.swift
//  Training Diary
//
//  Created by Steven Lord on 09/12/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//


import Cocoa

class NumberToDetailedTimeTransformer: ValueTransformer {
    
    private var formatter: DateComponentsFormatter
    
    override init() {
        formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.year, .day, .hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        super.init()
    }
    
    //What do I transform
    override class func transformedValueClass() -> AnyClass {return NSNumber.self}
    
    override class func allowsReverseTransformation() -> Bool {return false}
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let s = value as? Int else { return nil }
        
        return formatter.string(from: TimeInterval(s))

        
    }
    

}
