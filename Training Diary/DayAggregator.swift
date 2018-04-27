
//
//  DayAggregator.swift
//  Training Diary
//
//  Created by Steven Lord on 27/04/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Foundation

class DayAggregator: DayAggregatorProtocol{
        
        private var dayType: DayType?
        private var activity: Activity?
        private var activityType: ActivityType?
        private var equipment: Equipment?
        private var period: Period
        private var unit: Unit
    private var from: Date
    private var to: Date
        
    init(dayType dt: DayType? = nil, activity a: Activity? = nil, activityType at: ActivityType? = nil, equipment e: Equipment? = nil, period p: Period, unit u: Unit, from f: Date, to t: Date) {
            dayType = dt
            activity = a
            activityType = at
            equipment = e
            period = p
            unit = u
            from = f
            to = t
        }
        
        func aggregate(data: [Day]) -> [(date: Date, value: Double)]{
            var result: [(date: Date, value: Double)] = []
            
            for d in data.filter({$0.date! >= from.startOfDay() && $0.date! <= to.endOfDay()}).sorted(by: {$0.date! < $1.date!}){
                result.append((d.date!, d.valueFor(dayType: dayType, activity: activity, activityType: activityType, equipment: equipment, unit: unit)))
            }
            
            return result

        }
    
}
