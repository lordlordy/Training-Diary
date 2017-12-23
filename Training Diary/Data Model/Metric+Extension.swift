//
//  Metric+Extension.swift
//  Training Diary
//
//  Created by Steven Lord on 13/12/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Foundation

extension Metric{
    
    var uniqueKey: String{
        if let a = activity{
            if let n = name{
                return a + n
            }
        }
        return "uniqueKeyToBeSet"
        
    }
    
    static func key(forActivity a: Activity, andUnit u: Unit) -> String{ return a.rawValue + u.rawValue }
    
}
