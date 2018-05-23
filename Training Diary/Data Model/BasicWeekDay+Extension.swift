//
//  BasicWeekDay+Extension.swift
//  Training Diary
//
//  Created by Steven Lord on 24/04/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Foundation

extension BasicWeekDay{
    
    @objc dynamic var totalTSS: Double { return swimTSS + runTSS + bikeTSS}
    
    @objc dynamic var planName: String{
        return plan?.name ?? "Unkown Plan"
    }
    
    /*This is the method that needs implementing to ensure calculated properties update when the properties
     they depend on change.
     */
    override public class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String>{
        let keyPaths = super.keyPathsForValuesAffectingValue(forKey: key)
        switch key {
        case BasicWeekDayProperty.totalTSS.rawValue:
            return keyPaths.union(Set([BasicWeekDayProperty.swimTSS.rawValue, BasicWeekDayProperty.bikeTSS.rawValue, BasicWeekDayProperty.runTSS.rawValue]))
        default:
            return keyPaths
        }
    }
    
    
}
