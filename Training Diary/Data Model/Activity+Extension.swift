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

    
    func ctl(yesterdayCTL: Double, tss: Double) -> Double{
        return yesterdayCTL * ctlDecayFactor + tss * ctlImpactFactor
    }
    
    func atl(yesterdayATL: Double, tss: Double) -> Double{
        return yesterdayATL * atlDecayFactor + tss * atlImpactFactor
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
    
    private func getWorkouts() -> [Workout]{
        if let w = workouts?.allObjects as? [Workout]{
            return w
        }
        return []
    }
    
    //DEPRECATED. Need to remove as Activities no longer hard coded
    func validUnits() -> Set<Unit>{
        switch self.name!{
        case "Swim":
            return [ .Hours, .KJ, .KM, .Miles, .Minutes, .RPETSS, .Seconds, .TSS, .Watts, .ATL, .CTL, .TSB ]
        case "Bike":
            return [ .AscentMetres, .AscentFeet,  .Cadence, .Hours, .HR, .KJ, .KM, .Miles, .Minutes, .RPETSS, .Seconds, .TSS, .Watts, .ATL, .CTL, .TSB ]
        case "Run":
            return [ .AscentMetres, .AscentFeet,  .Cadence, .Hours, .HR, .KJ, .KM, .Miles, .Minutes, .RPETSS, .Seconds, .TSS, .Watts, .ATL, .CTL, .TSB ]
        case "Gym":
            return [ .Hours, .KJ, .Minutes, .Reps, .RPETSS, .Seconds, .TSS, .ATL, .CTL, .TSB ]
        case "Walk":
            return [ .AscentMetres, .AscentFeet, .Hours, .HR, .KJ, .KM, .Miles, .Minutes, .RPETSS, .Seconds, .TSS, .ATL, .CTL, .TSB ]
        case "Other":
            return [ .Hours, .HR, .KJ, .Minutes, .RPETSS, .Seconds, .TSS, .ATL, .CTL, .TSB ]
        default:
            return [ .AscentMetres, .AscentFeet,  .Cadence, .Hours, .HR, .KJ, .KM, .Miles, .Minutes, .Reps, .RPETSS, .Seconds, .TSS, .Watts, .ATL, .CTL, .TSB ]
        }
    }
    
    private func isOneOfFixedActivityTypes() -> Bool{
        if let n = name{
            return FixedActivity.All.map({$0.rawValue}).contains(n)
        }
        return false
    }
    
}
