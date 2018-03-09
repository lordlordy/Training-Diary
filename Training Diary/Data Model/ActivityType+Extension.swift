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
    
    func categoryName() -> String { return name! }

    
}
