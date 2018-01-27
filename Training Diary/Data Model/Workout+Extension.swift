//
//  Workout+Extension.swift
//  Training Diary
//
//  Created by Steven Lord on 07/10/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Cocoa

extension Workout{
    
    @objc dynamic var notBike: Bool{
        return !(activity == ActivityEnum.Bike.rawValue)
    }
    
    @objc dynamic var hours: Double{
        return seconds * Constant.HoursPerSecond.rawValue
    }
    
    @objc dynamic var minutes: Double{
        return seconds * Constant.MinutesPerSecond.rawValue
    }
    
    @objc dynamic var miles: Double{
        return km * Constant.MilesPerKM.rawValue
    }
    
    @objc dynamic var ascentFeet: Double{
        return ascentMetres * Constant.FeetPerMetre.rawValue
    }
    
    @objc dynamic var rpeTSS: Double{
        return (100/49)*rpe*rpe*Double(seconds)/3600
    }
    
    @objc dynamic var estimatedKJ: Double{
        if watts > 0.0{
            return watts * seconds / 1000.0
        }else{
            return rpeTSS * 5.0
        }
    }
    
    
    override public class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String>{
        let keyPaths = super.keyPathsForValuesAffectingValue(forKey: key)
        switch key {
        case WorkoutProperty.notBike.rawValue:
            return keyPaths.union(Set([WorkoutProperty.activity.rawValue]))
        case WorkoutProperty.rpeTSS.rawValue:
            return keyPaths.union(Set([WorkoutProperty.seconds.rawValue,WorkoutProperty.rpe.rawValue]))
        case "estimatedKJ":
            return keyPaths.union(Set([WorkoutProperty.watts.rawValue, WorkoutProperty.seconds.rawValue, WorkoutProperty.rpeTSS.rawValue]))
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
    func valueFor(_ a: [ActivityEnum],_ t: [ActivityTypeEnum], _ unit: Unit, _ b: BikeName? = nil) -> Double{
        if let requestedBike = b{
            //bike passed in. If this workout is on this bike then continue. If not return zero
            if requestedBike.rawValue != bike{
                return 0.0
            }
        }
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
    
    private func isOfType(_ a: ActivityEnum, _ t: ActivityTypeEnum ) -> Bool{
        return isOneOfTheseTypes([a], [t])
    }
    
    private func isOneOfTheseTypes(_ a: [ActivityEnum], _ t: [ActivityTypeEnum]) -> Bool{
        return (a.contains(ActivityEnum.All) || isOneOff(a)) && (t.contains(ActivityTypeEnum.All) || isOneOff(t))
    }
    
    private func getActivity() -> ActivityEnum?{
        if let activity = self.activity{
            return ActivityEnum(rawValue: activity)
        }else{
            return nil
        }
    }

    private func getActivityType() -> ActivityTypeEnum?{
        if let activityType  = self.activityType{
            return ActivityTypeEnum(rawValue: activityType)
        }else{
            return nil
        }
    }
    
    private func isOneOff(_ a: [ActivityEnum]) -> Bool{
        if getActivity() == nil {
            return false
        }else{
            return a.contains(getActivity()!)
        }
    }

    private func isOneOff(_ a: [ActivityTypeEnum]) -> Bool{
        if getActivityType() == nil {
            return false
        }else{
            return a.contains(getActivityType()!)
        }
    }

}
