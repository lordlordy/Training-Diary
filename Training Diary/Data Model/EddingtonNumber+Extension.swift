//
//  EddingtonNumber+Extension.swift
//  Training Diary
//
//  Created by Steven Lord on 31/10/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Foundation

extension EddingtonNumber{
    

    static func eddingtonCode(forActivity a: Activity, activityType at: ActivityType, period p: Period, unit u: Unit) -> String{
        return eddingtonCode(forActivity: a.rawValue, activityType: at.rawValue, period: p.rawValue, unit: u.rawValue)
    }
    
    static func annualEddingtonCode(forYear y: Int16, activity a: Activity, activityType at: ActivityType, period p: Period, unit u: Unit) -> String{
        return annualEddingtonCode(year: y, forActivity: a.rawValue, activityType: at.rawValue, period: p.rawValue, unit: u.rawValue)
    }

    
   
    static func eddingtonCode(forActivity a: String, activityType at: String, period p: String, unit u: String) -> String{
        return a + ":" + at + ":" + p + ":" + u
    }
   
    static func annualEddingtonCode(year y: Int16, forActivity a: String, activityType at: String, period p: String, unit u: String) -> String{
        return String(y) + ":" + eddingtonCode(forActivity: a, activityType: at, period: p, unit: u)
    }


    
    @objc dynamic var eddingtonCode: String{
        if let a = activity {
            if let at = activityType {
                if let p = period {
                    if let u = unit {
                        return EddingtonNumber.eddingtonCode(forActivity: a, activityType: at, period: p, unit: u)
                    }
                }
            }
        }
        return ""
    }
    
    @objc dynamic var annualEddingtonCode: String{
        return String(year) + ":" + eddingtonCode
    }
    
    override public class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String>{
        let keyPaths = super.keyPathsForValuesAffectingValue(forKey: key)
        switch key {
        case "eddingtonCode":
            return keyPaths.union(Set(["activity","activityType","period","unit"]))
        case "annualEddingtonCode":
            return keyPaths.union(Set(["activity","activityType","period","unit","year"]))
        default:
            return keyPaths
        }
    }
    
}
