//
//  Bike+Extension.swift
//  Training Diary
//
//  Created by Steven Lord on 22/01/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Foundation

extension Bike{
    
    @objc dynamic var nameIsEditable: Bool{
        return rides == 0
    }
    
    @objc dynamic var rides: Int{
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
    

    func workoutDateRange() -> (from: Date, to: Date){
        let dates = getWorkouts().map({$0.day!.date!})
        return (from: dates.min()!, to: dates.max()!)
    }
    
    func getWorkouts() -> [Workout]{
        if let result =  workouts?.allObjects as? [Workout]{
            return result
        }
        return []
    }
}
