//
//  AgeFormatter.swift
//  Training Diary
//
//  Created by Steven Lord on 06/08/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//



import Cocoa

class AgeFormatter: ValueTransformer {
    
    private var formatter: DateComponentsFormatter
    
    override init() {
        formatter = DateComponentsFormatter()
        formatter.allowedUnits = [ .year, .day]
        formatter.unitsStyle = .abbreviated
        super.init()
    }
    
    //What do I transform
    override class func transformedValueClass() -> AnyClass {return NSNumber.self}
    
    override class func allowsReverseTransformation() -> Bool {return false}
    
    override func transformedValue(_ value: Any?) -> Any? {
        if let s = value as? TimeInterval{
            return formatter.string(from: s)
        }
        
        return nil
        
    }
    
    
}
