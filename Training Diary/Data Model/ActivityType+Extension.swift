//
//  ActivityType+Extension.swift
//  Training Diary
//
//  Created by Steven Lord on 29/01/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Foundation

extension ActivityType: CategoryProtocol{
    
    @objc dynamic var workoutCount: Int { return workouts?.count ?? 0 }
    @objc dynamic var km: Double { return getWorkouts().reduce(0,{$0 + $1.km}) }
    @objc dynamic var hours: Double { return getWorkouts().reduce(0,{$0 + $1.hours}) }
    @objc dynamic var tss: Double { return getWorkouts().reduce(0,{$0 + $1.tss}) }

    
    func categoryName() -> String { return name! }

    private func getWorkouts() -> [Workout]{
        if let w = workouts?.allObjects as? [Workout]{
            return w
        }
        return []
    }
    
}
