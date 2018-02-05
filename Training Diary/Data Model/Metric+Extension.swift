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
    
    static func key(forActivity a: Activity, andUnit u: Unit) -> String{ return Metric.key(forActivity: a.name!, andUnit: u)}
    static func key(forActivity a: String, andUnit u: Unit) -> String{ return a + u.rawValue}

}
