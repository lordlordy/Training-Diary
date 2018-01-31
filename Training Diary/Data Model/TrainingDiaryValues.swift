//
//  TrainingDiaryValues.swift
//  Training Diary
//
//  Created by Steven Lord on 27/01/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Foundation

protocol TrainingDiaryValues{
    //NB the equivalent of Activity = nil, ActivityType = nil, Equipment = nil is to pass the string "All"
    func valuesFor(activity a: Activity?, activityType at: ActivityType?, equipment e: Equipment?, period p: Period, unit u: Unit, from: Date?, to: Date?) -> [(date: Date, value: Double)]
    func valuesFor(activity a: String, activityType at: String, equipment e: String, period p: Period, unit u: Unit, from: Date?, to: Date?) -> [(date: Date, value: Double)]
    func valuesAreForTrainingDiary() -> TrainingDiary
    
}
