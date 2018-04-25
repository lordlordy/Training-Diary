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
    
    @objc dynamic var recordingDate: String{
        return fromDate!.iso8601Format()
    }
    
    @objc dynamic var bmi: Double{
        if let height = trainingDiary?.athleteHeightCM{
            if height > 0{
                return kg / pow(trainingDiary!.athleteHeightCM / 100.0,2)
            }
        }
        return 0.0
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
