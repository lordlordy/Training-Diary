//
//  ActivityTypeToStringTransformer.swift
//  Training Diary
//
//  Created by Steven Lord on 01/08/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Foundation

class ActivityTypeToStringTransformer: ValueTransformer {
    
    
    //What do I transform
    override class func transformedValueClass() -> AnyClass {return ActivityType.self}
    
    override class func allowsReverseTransformation() -> Bool {return true}
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let a = value as? ActivityType else { return nil }
        
        return a.name
        
    }
    
    
}
