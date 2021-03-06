//
//  Weight+Extension.swift
//  Training Diary
//
//  Created by Steven Lord on 09/11/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Foundation

extension Weight{
    
    
    //this is for JSON serialisation
    @objc dynamic var iso8601DateString: String{
        return fromDate?.iso8601Format() ?? ""
    }
    
    //for csv serialisation - simple data
    @objc dynamic var fromDateString: String{
        return fromDate?.dateOnlyString() ?? ""
    }
    
    //need to remove 'lbs' for core data model. Then can change this name to "lbs"
    @objc dynamic var lbs: Double{
        return kg * Constant.LbsPerKg.rawValue
    }
    
    
    @objc dynamic var bmi: Double{
        if let height = trainingDiary?.athleteHeightCM{
            if height > 0{
                return kg / pow(trainingDiary!.athleteHeightCM / 100.0,2)
            }
        }
        return 0.0
    }
    /*Katch-McArdle formula
     daily cals = 370 + 21.6 x leanBodyMass
     */
    @objc dynamic var basalCalsPerDay: Double{
        return 370 + 21.6 * (kg * (1-fatPercent/100.0))
    }
    
    override public class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String>{
        let keyPaths = super.keyPathsForValuesAffectingValue(forKey: key)
        switch key {
        case WeightProperty.lbs.rawValue, WeightProperty.bmi.rawValue:
            return keyPaths.union(Set([WeightProperty.kg.rawValue]))
        case WeightProperty.basalCalsPerDay.rawValue:
            return keyPaths.union(Set([WeightProperty.kg.rawValue, WeightProperty.fatPercent.rawValue]))
        default:
            return keyPaths
        }
    }
}
