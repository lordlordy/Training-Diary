//
//  Weight+Extension.swift
//  Training Diary
//
//  Created by Steven Lord on 09/11/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Foundation

extension Weight{
    //need to remove 'lbs' for core data model. Then can change this name to "lbs"
    @objc dynamic var lbs_c: Double{
        return kg * Constant.LbsPerKg.rawValue
    }
    
    
    override public class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String>{
        let keyPaths = super.keyPathsForValuesAffectingValue(forKey: key)
        switch key {
        case "lbs_c":
            return keyPaths.union(Set(["kg"]))
        default:
            return keyPaths
        }
    }
}
