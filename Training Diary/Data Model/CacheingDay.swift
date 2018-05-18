//
//  CacheingDay.swift
//  Training Diary
//
//  Created by Steven Lord on 18/05/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Foundation

class CacheingDay: DayValueProtocol{

    var date: Date?{
        return day.date
    }
    
    private var day: DayValueProtocol
    private var cache: [String:Double] = [:]
    
    init(_ day: DayValueProtocol){
        self.day = day
    }
    
    func valueFor(dayType dt: DayType?, activity a: Activity?, activityType at: ActivityType?, equipment e: Equipment?, unit u: Unit) -> Double {
        let all: String = ConstantString.EddingtonAll.rawValue
        return valueFor(dayType: dt?.rawValue ?? all , activity: a?.name ?? all, activityType: at?.name ?? all, equipment: e?.name ?? all, unit: u)
    }
    
    func valueFor(dayType dt: String, activity a: String, activityType at: String, equipment e: String, unit u: Unit) -> Double {
        let cacheKey: String = EddingtonNumber.code(dayType: dt, activity: a, activityType: at, equipment: e, period: Period.Day.rawValue, unit: u.rawValue)
        
        if let v = cache[cacheKey]{
            return v
        }else{
            let result = day.valueFor(dayType: dt, activity: a, activityType: at, equipment: e, unit: u)
            cache[cacheKey] = result
            return result
        }
    }

    
}
