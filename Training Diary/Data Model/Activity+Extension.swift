//
//  Activity+Extension.swift
//  Training Diary
//
//  Created by Steven Lord on 27/01/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Foundation

extension Activity: CategoryProtocol{
    
    @objc dynamic var isFixedActivity: Bool {return isOneOfFixedActivityTypes() }
    @objc dynamic var canEditName: Bool { return !isFixedActivity }
    
    @objc dynamic var workoutCount: Int { return workouts?.count ?? 0 }
    @objc dynamic var km: Double { return getWorkouts().reduce(0,{$0 + $1.km}) }
    @objc dynamic var hours: Double { return getWorkouts().reduce(0,{$0 + $1.hours}) }
    @objc dynamic var tss: Double { return getWorkouts().reduce(0,{$0 + $1.tss}) }

    @objc dynamic var ctlDecayFactor: Double { return exp(-1 / ctlDecay) }
    @objc dynamic var ctlImpactFactor: Double { return 1.0 - exp(-1 / ctlImpact) }
    @objc dynamic var atlDecayFactor: Double { return exp(-1 / atlDecay) }
    @objc dynamic var atlImpactFactor: Double { return 1.0 - exp(-1 / atlImpact) }
    
    @objc dynamic var ctlHalfLife: Double { return -log(0.5) * ctlDecay }
    @objc dynamic var atlHalfLife: Double { return -log(0.5) * atlDecay }


    
    func ctl(yesterdayCTL: Double, tss: Double) -> Double{
        return yesterdayCTL * ctlDecayFactor + tss * ctlImpactFactor
    }
    
    func atl(yesterdayATL: Double, tss: Double) -> Double{
        return yesterdayATL * atlDecayFactor + tss * atlImpactFactor
    }
    
    func effect(afterDays d: Double) -> Double {
        return (ctlImpactFactor * pow(ctlDecayFactor,d) - atlImpactFactor * pow(atlDecayFactor,d))
    }

    func ctlDecayFactor(afterNDays n: Int) -> Double{
        return pow(ctlDecayFactor, Double(n))
    }
    
    func ctlReplacementTSSFactor(afterNDays n: Int) -> Double{
        return (1 - pow(ctlDecayFactor,Double(n))) / (1 - ctlDecayFactor)
    }
    
    func atlDecayFactor(afterNDays n: Int) -> Double{
        return pow(atlDecayFactor, Double(n))
    }
    
    func atlReplacementTSSFactor(afterNDays n: Int) -> Double{
        return (1 - pow(atlDecayFactor,Double(n))) / (1 - ctlDecayFactor)
    }
    
    func categoryName() -> String { return name! }
    
    func keyString(forUnit unit: Unit) -> String{
        return self.name!.lowercased() + unit.rawValue
    }
    
    func validTypes() -> [ActivityType]{
        if let types = activityTypes{
            return types.allObjects as! [ActivityType]
        }
        return []
    }
    
    func validEquipment() -> [Equipment]{
        if let e = equipment{
            return e.allObjects as! [Equipment]
        }
        return []
    }
    
    //MARK: - Core Data dependent key values
    
    /*This is the method that needs implementing to ensure calculated properties update when the properties
     they depend on change.
     */
    override public class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String>{
        let keyPaths = super.keyPathsForValuesAffectingValue(forKey: key)
        switch key {
        case ActivityProperty.atlDecayFactor.rawValue:
            return keyPaths.union(Set([ActivityProperty.atlDecay.rawValue]))
        case ActivityProperty.atlImpactFactor.rawValue:
            return keyPaths.union(Set([ActivityProperty.atlImpact.rawValue]))
        case ActivityProperty.ctlDecayFactor.rawValue:
            return keyPaths.union(Set([ActivityProperty.ctlDecay.rawValue]))
        case ActivityProperty.ctlImpactFactor.rawValue:
            return keyPaths.union(Set([ActivityProperty.ctlImpact.rawValue]))
        case ActivityProperty.ctlHalfLife.rawValue:
            return keyPaths.union(Set([ActivityProperty.ctlDecay.rawValue]))
        case ActivityProperty.atlHalfLife.rawValue:
            return keyPaths.union(Set([ActivityProperty.atlDecay.rawValue]))
        default:
            return keyPaths
        }
    }
    
    
    private func getWorkouts() -> [Workout]{
        if let w = workouts?.allObjects as? [Workout]{
            return w
        }
        return []
    }
    

    private func isOneOfFixedActivityTypes() -> Bool{
        if let n = name{
            return FixedActivity.All.map({$0.rawValue}).contains(n)
        }
        return false
    }
    
}
