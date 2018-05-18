//
//  DayValueProtocol.swift
//  Training Diary
//
//  Created by Steven Lord on 18/05/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Foundation

protocol DayValueProtocol {
    
    var date: Date?{get}
    
    func valueFor(dayType dt: DayType?, activity a: Activity?, activityType at: ActivityType?, equipment e: Equipment?, unit u: Unit) -> Double
    
    func valueFor(dayType dt: String, activity a: String, activityType at: String, equipment e: String, unit u: Unit) -> Double
}
