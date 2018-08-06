//
//  NumberToSummaryTimeFormatter.swift
//  Training Diary
//
//  Created by Steven Lord on 09/12/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//


import Cocoa

class NumberToSummaryTimeFormatter: ValueTransformer {
    
    private var formatter: DateComponentsFormatter
    
    override init() {
        formatter = DateComponentsFormatter()
        formatter.allowedUnits = [ .hour, .minute, .second]
        formatter.unitsStyle = .positional
        super.init()
    }
    
    //What do I transform
    override class func transformedValueClass() -> AnyClass {return NSNumber.self}
    
    override class func allowsReverseTransformation() -> Bool {return false}
    
    override func transformedValue(_ value: Any?) -> Any? {
        if let s = value as? TimeInterval{
            return formatter.string(from: s)
        }
        if let s = value as? Int{
            return formatter.string(from: TimeInterval(s))
        }
        
        return nil
                
    }
    
    
}
