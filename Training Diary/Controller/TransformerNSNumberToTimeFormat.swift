//
//  TransformerNSNumberToTimeFormat.swift
//  Training Diary
//
//  Created by Steven Lord on 07/10/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Cocoa

class TransformerNSNumberToTimeFormat: ValueTransformer {
    //What do I transform
    override class func transformedValueClass() -> AnyClass {return NSNumber.self}
    
    override class func allowsReverseTransformation() -> Bool {return true}
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let s = value as? Int else { return nil }
        let secs = s % 60
        let mins = (s / 60) % 60
        let hours = (s / 3600)
        return String(format: "%02d:%02d:%02d", hours, mins, secs)    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let type = value as? NSString else { return nil }
        let myString: String = type as String
        let b = myString.split(separator: ":") as [NSString]
        let total = b[0].integerValue*3600 + b[1].integerValue*60 + b[2].integerValue
        return NSNumber(value: total)
    }
}
