//
//  Workout+Extension.swift
//  Training Diary
//
//  Created by Steven Lord on 07/10/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Cocoa

extension Workout{
    
    @objc dynamic var hours: Double{
        return seconds * Constant.HoursPerSecond.rawValue
    }
    
    @objc dynamic var minutes: Double{
        return seconds * Constant.MinutesPerSecond.rawValue
    }
    
    @objc dynamic var miles: Double{
        return km * Constant.MilesPerKM.rawValue
    }
    
    @objc dynamic var rpeTSS: Double{
        return (100/49)*rpe*rpe*Double(seconds)/3600
    }
    

    
    override public class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String>{
        let keyPaths = super.keyPathsForValuesAffectingValue(forKey: key)
        switch key {
        case "rpeTSS":
            return keyPaths.union(Set(["seconds","rpe"]))
        default:
            return keyPaths
        }
    }
    
    /* All workouts respond to requests for any combination of
         Activity
         ActivityType
         Unit
     Returning zero if it's not this type
     */
    func valueFor(_ a: [Activity],_ t: [ActivityType], _ unit: Unit) -> Double{
        if (isOneOfTheseTypes(a, t) && !unit.isMetric){
            if(unit.isDerived()){
                if let derivation = unit.dataForDerivation(){
                    if let d = value(forKey: derivation.unit.workoutPropertyName()!){
                        return (d as! Double) * derivation.multiple.rawValue
                    }else{
                        print("couldn't get value for \(String(describing: derivation.unit.workoutPropertyName()))")
                    }
                }else{
                    print("derived data nil for \(unit)")
                }
            }else{
                if let d = value(forKey: unit.workoutPropertyName()!){
                    return d as! Double
                }else{
                    return 0.0
                }
            }
        }
        return 0.0
    }
    
    //MARK: - private
    
    private func isOfType(_ a: Activity, _ t: ActivityType ) -> Bool{
        return isOneOfTheseTypes([a], [t])
    }
    
    private func isOneOfTheseTypes(_ a: [Activity], _ t: [ActivityType]) -> Bool{
        return (a.contains(Activity.All) || isOneOff(a)) && (t.contains(ActivityType.All) || isOneOff(t))
    }
    
    private func getActivity() -> Activity?{
        if let activity = self.activity{
            return Activity(rawValue: activity)
        }else{
            return nil
        }
    }

    private func getActivityType() -> ActivityType?{
        if let activityType  = self.activityType{
            return ActivityType(rawValue: activityType)
        }else{
            return nil
        }
    }
    
    private func isOneOff(_ a: [Activity]) -> Bool{
        if getActivity() == nil {
            return false
        }else{
            return a.contains(getActivity()!)
        }
    }

    private func isOneOff(_ a: [ActivityType]) -> Bool{
        if getActivityType() == nil {
            return false
        }else{
            return a.contains(getActivityType()!)
        }
    }

}
