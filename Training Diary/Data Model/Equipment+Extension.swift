//
//  Equipment+Extension.swift
//  Training Diary
//
//  Created by Steven Lord on 30/01/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Foundation

extension Equipment: CategoryProtocol{
    @objc dynamic var nameIsEditable: Bool{
        return workoutCount == 0
    }
    
    @objc dynamic var workoutCount: Int{
        return workouts?.count ?? 0
    }
    
    @objc dynamic var miles: Double{ return km * Constant.MilesPerKM.rawValue}
    @objc dynamic var ascentFeet: Double { return ascentMetres * Constant.FeetPerMetre.rawValue}
    @objc dynamic var hours: Double { return seconds / Constant.SecondsPerHour.rawValue}
    
    @objc dynamic var km: Double{
        var result: Double = 0.0
        for w in getWorkouts(){ result += w.km }
        return result + preDiaryKMs
    }
    
    @objc dynamic var ascentMetres: Double{
        var result: Double = 0.0
        for w in getWorkouts(){ result += w.ascentMetres }
        return result
    }
    
    @objc dynamic var numberOfTypes: Int{
        let typeStrings = getWorkouts().flatMap({$0.activityType?.name})
        let mySet = Set<String>(typeStrings)
        return mySet.count
    }
    
    @objc dynamic var seconds: Double{
        var result: Double = 0.0
        for w in getWorkouts(){ result += w.seconds }
        return result
    }
    
    @objc dynamic var tss: Double{
        var result: Double = 0.0
        for w in getWorkouts(){ result += w.tss }
        return result
    }
    
    @objc dynamic var kj: Double{
        var result: Double = 0.0
        for w in getWorkouts(){ result += w.kj }
        return result
    }
    
    func categoryName() -> String { return name! }

    
    func workoutDateRange() -> (from: Date, to: Date){
        let dates = getWorkouts().map({$0.day!.date!})
        if dates.count == 0{
            return (from: Date(), to: Date())
        }
        return (from: dates.min()!, to: dates.max()!)
    }
    
    func getWorkouts() -> [Workout]{
        if let result =  workouts?.allObjects as? [Workout]{
            return result
        }
        return []
    }
}
