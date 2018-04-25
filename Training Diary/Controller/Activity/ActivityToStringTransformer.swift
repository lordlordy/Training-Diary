//
//  ActivityToStringTransformer.swift
//  Training Diary
//
//  Created by Steven Lord on 29/01/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Foundation

class ActivityToStringTransformer: ValueTransformer {
    
    
    //What do I transform
    override class func transformedValueClass() -> AnyClass {return Activity.self}
    
    override class func allowsReverseTransformation() -> Bool {return false}
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let a = value as? Activity else { return nil }
        
        return a.name
        
        
    }
    
    
}
