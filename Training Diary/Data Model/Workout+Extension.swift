//
//  Workout+Extension.swift
//  Training Diary
//
//  Created by Steven Lord on 07/10/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Cocoa

extension Workout: PeriodNode{

    var totalCTL: Double { return 0.0 }
    var swimCTL: Double { return 0.0 }
    var bikeCTL: Double { return 0.0 }
    var runCTL: Double { return 0.0 }

    @objc dynamic var hours:        Double{ return seconds * Constant.HoursPerSecond.rawValue}
    @objc dynamic var minutes:      Double{ return seconds * Constant.MinutesPerSecond.rawValue}
    @objc dynamic var miles:        Double{ return km * Constant.MilesPerKM.rawValue }
    @objc dynamic var ascentFeet:   Double{ return ascentMetres * Constant.FeetPerMetre.rawValue }
    @objc dynamic var rpeTSS:       Double{ return (100/49)*rpe*rpe*Double(seconds)/3600 }
    
    @objc dynamic var activityTypeOK:   Bool { return activityTypeValid() }
    @objc dynamic var equipmentOK:      Bool { return equipmentValid() }
    
    @objc var secondsPerKM: TimeInterval{
        return km > 0 ? TimeInterval(seconds / km ) : 0.0
    }
    
    @objc var secondsPer100m: TimeInterval{
        return secondsPerKM / 10.0
    }
    
    @objc var kph: TimeInterval{
        return km / hours
    }
    
    @objc dynamic var estimatedKJ: Double{
        if watts > 0.0{
            return watts * seconds / 1000.0
        }else{
            return rpeTSS * 5.0
        }
    }
    
    @objc dynamic var activityString: String{
        get{
            return activity?.name ?? "Activity not set"
        }
        set{
            if let td = day?.trainingDiary{
                activity = td.addActivity(forString: newValue)
            }
        }
    }
    
    @objc dynamic var activityTypeString: String{
        get{
            return activityType?.name ?? ConstantString.NotSet.rawValue
        }
        set{
            if newValue != ConstantString.NotSet.rawValue{
                if let td = day?.trainingDiary{
                    if let a = activity?.name{
                        activityType = td.addActivityType(forActivity: a, andType: newValue)
                    }
                }
            }
        }
    }
    
    @objc dynamic var equipmentName: String{
        get{
            return equipment?.name ?? ConstantString.NotSet.rawValue
        }
        set{
            if newValue != ConstantString.NotSet.rawValue{
                if let td = day?.trainingDiary{
                    if let a = activity?.name{
                        equipment = td.addEquipment(forActivity: a, andName: newValue)
                    }
                }
            }
        }
    }
    
    
    override public class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String>{
        let keyPaths = super.keyPathsForValuesAffectingValue(forKey: key)
        switch key {
        case WorkoutProperty.notBike.rawValue:
            return keyPaths.union(Set([WorkoutProperty.activity.rawValue]))
        case WorkoutProperty.rpeTSS.rawValue:
            return keyPaths.union(Set([WorkoutProperty.seconds.rawValue,WorkoutProperty.rpe.rawValue]))
            
        case WorkoutProperty.estimatedKJ.rawValue:
            return keyPaths.union(Set([WorkoutProperty.watts.rawValue, WorkoutProperty.seconds.rawValue, WorkoutProperty.rpeTSS.rawValue]))
        case WorkoutProperty.miles.rawValue:
            return keyPaths.union(Set([WorkoutProperty.km.rawValue]))
        case WorkoutProperty.ascentFeet.rawValue:
            return keyPaths.union(Set([WorkoutProperty.ascentMetres.rawValue]))
        default:
            return keyPaths
        }
    }
    
    //MARK: - PeriodNode protocol implmentation
    @objc var isLeaf: Bool { return true }
    @objc var isRoot: Bool { return false}
    @objc var isWorkout: Bool { return true}
    @objc var name: String { return (activity?.name ?? "") + ":" + (activityType?.name ?? "") }
    @objc var children: [PeriodNode] { return [] }
    @objc var childCount: Int { return 0 }
    @objc var totalKM: Double { return km }
    @objc var totalSeconds:  Double { return TimeInterval(seconds) }
    @objc var totalTSS: Double { return tss }
    @objc var swimKM: Double {
        if activityString == FixedActivity.Swim.rawValue{
            return km
        }else{
            return 0.0
        }
    }
    @objc var swimSeconds: TimeInterval {
        if activityString == FixedActivity.Swim.rawValue{
            return TimeInterval(seconds)
        }else{
            return TimeInterval(0.0)
        }
    }

    @objc var swimTSS: Double {
        if activityString == FixedActivity.Swim.rawValue{
            return tss
        }else{
            return 0.0
        }
    }
    @objc var bikeKM: Double {
        if activityString == FixedActivity.Bike.rawValue{
            return km
        }else{
            return 0.0
        }
    }
    @objc var bikeSeconds: TimeInterval {
        if activityString == FixedActivity.Bike.rawValue{
            return TimeInterval(seconds)
        }else{
            return TimeInterval(0.0)
        }
    }
    @objc var bikeTSS: Double {
        if activityString == FixedActivity.Bike.rawValue{
            return tss
        }else{
            return 0.0
        }
    }
    @objc var runKM: Double {
        if activityString == FixedActivity.Run.rawValue{
            return km
        }else{
            return 0.0
        }
    }
    @objc var runSecondsPerKM: TimeInterval{
        return runKM > 0 ? runSeconds / runKM : 0.0
    }
    @objc var runSeconds: TimeInterval {
        if activityString == FixedActivity.Run.rawValue{
            return TimeInterval(seconds)
        }else{
            return TimeInterval(0.0)
        }
    }
    @objc var runTSS: Double {
        if activityString == FixedActivity.Run.rawValue{
            return tss
        }else{
            return 0.0
        }
    }

    @objc var fromDate: Date { return day!.date! }
    @objc var toDate: Date { return day!.date! }
    func inPeriod(_ p: PeriodNode) -> Bool{
        return (p.fromDate <= fromDate) && (p.toDate >= toDate)
    }
    func child(forName n: String) -> PeriodNode?{
        for node in children{
            if node.name == n{
                return node
            }
        }
        return nil
    }
    func add(child: PeriodNode) {
        print("Can't add children to Workouts")
    }
    
    var leafCount: Int {
        return 1
    }


    func valueFor( activity a: String, activityType at: String, equipment e: String, period p: Period, unit u: Unit) -> Double{

        var v: Double = 0.0

        if u.isActivityBased{
            if (isOfType(activity: a, activityType: at, equipment: e) && !u.isMetric){
                if(u.isDerived()){
                    if let derivation = u.dataForDerivation(){
                        if let d = value(forKey: derivation.unit.rawValue){
                            v = (d as! Double) * derivation.multiple.rawValue
                        }else{
                            print("couldn't get value for \(String(describing: derivation.unit.rawValue))")
                        }
                    }else{
                        print("derived data nil for \(u)")
                    }
                }else{
                    if let d = value(forKey: u.rawValue){
                        if let dd = d as? Double{
                            v = dd
                        }else if let b = d as? Bool{
                            if b { v = 1.0 }
                        }
                        
                    }
                }
            }
        }
        
        return v
    }
 
    
    //MARK: - private
    


    private func isOfType(activity: String, activityType: String, equipment: String ) -> Bool{
        let correctActivity: Bool = (activity == ConstantString.EddingtonAll.rawValue || activity == activityString)
        let correctType: Bool = (activityType == ConstantString.EddingtonAll.rawValue || activityType == activityTypeString)
        let correctEquipment: Bool = (equipment == ConstantString.EddingtonAll.rawValue || equipment == equipmentName)
        return correctActivity && correctType && correctEquipment
    }

    private func activityTypeValid() -> Bool{
        if let validTypes = activity?.activityTypes{
            if let at = activityType{
                return validTypes.contains(at)
            }
        }
        return false
    }

    private func equipmentValid() -> Bool{
        if equipment == nil { return true } // ok to not have equipment set
        if let validTypes = activity?.equipment{
            if let e = equipment{
                return validTypes.contains(e)
            }
        }else{
            //no equipment set up
            return equipment == nil
        }
        return false
    }
    
}
