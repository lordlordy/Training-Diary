//
//  SumAggregator.swift
//  Training Diary
//
//  Created by Steven Lord on 26/04/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Foundation

class SumAggregator:DayAggregatorProtocol{
    
    internal var dayType: DayType?
    internal var activity: Activity?
    internal var activityType: ActivityType?
    internal var equipment: Equipment?
    internal var period: Period
    internal var unit: Unit
    internal var weighting: Unit?
    internal var from: Date
    internal var to: Date

    internal var calculator: RollingPeriodCalculator?
    
    
    init(dayType dt: DayType? = nil, activity a: Activity? = nil, activityType at: ActivityType? = nil, equipment e: Equipment? = nil, period p: Period, unit u: Unit, weighting w: Unit?, from f: Date, to t: Date) {
        dayType = dt
        activity = a
        activityType = at
        equipment = e
        period = p
        unit = u
        weighting = w
        from = f.startOfDay()
        to = t.endOfDay()
        
        calculator = createRollingPeriodCalculator()
    }
    
    func aggregate(data: [Day]) -> [(date: Date, value: Double)]{
        var result: [(date: Date, value: Double)] = []
        
        if let rSum = calculator{
            for d in data.filter({$0.date! >= preloadDate() && $0.date! <= to}).sorted(by: {$0.date! < $1.date!}){
                let v = d.valueFor(dayType: dayType, activity: activity, activityType: activityType, equipment: equipment, unit: unit)
                var weight = 1.0
                if let w = weighting{
                    weight = d.valueFor(dayType: dayType, activity: activity, activityType: activityType, equipment: equipment, unit: w)
                }
                if let sum = rSum.addAndReturnValue(forDate: d.date!, value: v, weighting: weight){
                    if d.date! >= from{
                        result.append((d.date!, sum))
                    }
                }
            }
        }
        
        return result
        
    }
    
    //this returns the date to start calculation from. Imagine doing month to date - need to start 31 days before to guarantee getting it correct
    internal func preloadDate() -> Date{
        return from.addDays(numberOfDays: -period.size())
    }
    
    internal func createRollingPeriodCalculator() -> RollingPeriodCalculator?{
        var rSum: RollingPeriodCalculator?
        switch period{
        case .Day, .rWeek, .rMonth, .rYear, .Lifetime:
            rSum = RollingPeriodSum(size: period.size())
        case .WeekToDate:   rSum  = ToDateSum(size: period.size(), rule: {$0.isEndOfWeek()})
        case .WTDTue:       rSum  = ToDateSum(size: period.size(), rule: {$0.isMonday()})
        case .WTDWed:       rSum  = ToDateSum(size: period.size(), rule: {$0.isTuesday()})
        case .WTDThu:       rSum  = ToDateSum(size: period.size(), rule: {$0.isWednesday()})
        case .WTDFri:       rSum  = ToDateSum(size: period.size(), rule: {$0.isThursday()})
        case .WTDSat:       rSum  = ToDateSum(size: period.size(), rule: {$0.isFriday()})
        case .WTDSun:       rSum  = ToDateSum(size: period.size(), rule: {$0.isSaturday()})
        case .MonthToDate:  rSum  = ToDateSum(size: period.size(), rule: {$0.isEndOfMonth()})
        case .YearToDate:   rSum  = ToDateSum(size: period.size(), rule: {$0.isEndOfYear()})
        case .Week:         rSum  = PeriodSum(size: period.size(), rule: {$0.isEndOfWeek()})
        case .WeekTue:      rSum  = PeriodSum(size: period.size(), rule: {$0.isMonday()})
        case .WeekWed:      rSum  = PeriodSum(size: period.size(), rule: {$0.isTuesday()})
        case .WeekThu:      rSum  = PeriodSum(size: period.size(), rule: {$0.isWednesday()})
        case .WeekFri:      rSum  = PeriodSum(size: period.size(), rule: {$0.isThursday()})
        case .WeekSat:      rSum  = PeriodSum(size: period.size(), rule: {$0.isFriday()})
        case .WeekSun:      rSum  = PeriodSum(size: period.size(), rule: {$0.isSaturday()})
        case .Month:        rSum  = PeriodSum(size: period.size(), rule: {$0.isEndOfMonth()})
        case .Year:         rSum  = PeriodSum(size: period.size(), rule: {$0.isEndOfYear()})
            
        case .Adhoc, .Workout:
            return nil
            
        }
        
        return rSum
        
    }
    

    
    
}
