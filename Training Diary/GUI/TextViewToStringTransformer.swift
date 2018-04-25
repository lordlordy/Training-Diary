//
//  TextViewToStringTransformer.swift
//  Training Diary
//
//  Created by Steven Lord on 24/01/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Foundation

class TextViewToStringTransformer: ValueTransformer{
    
    
    override class func transformedValueClass() -> AnyClass {return NSAttributedString.self}
    
    override class func allowsReverseTransformation() -> Bool {return true}
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let s = value as? String else { return nil}
        return NSAttributedString.init(string: s)
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let s = value as? NSAttributedString else { return nil }
        return s.string
    }
    
}
