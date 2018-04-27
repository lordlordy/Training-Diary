//
//  MeanAggregator.swift
//  Training Diary
//
//  Created by Steven Lord on 27/04/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Foundation


class MeanAggregator:SumAggregator{

    
    override internal func createRollingPeriodCalculator() -> RollingPeriodCalculator?{
        var rAverage: RollingPeriodWeightedAverage?
        switch period{
        case .Day:          rAverage = RollingPeriodWeightedAverage(size: 1)
        case .rWeek:        rAverage = RollingPeriodWeightedAverage(size: 7)
        case .rMonth:       rAverage = RollingPeriodWeightedAverage(size: 30)
        case .rYear:        rAverage = RollingPeriodWeightedAverage(size: 365)
            
        case .WeekToDate:   rAverage = ToDateWeightedAverage(size: 7, rule: {$0.isEndOfWeek()})
        case .WTDTue:       rAverage = ToDateWeightedAverage(size: 7, rule: {$0.isMonday()})
        case .WTDWed:       rAverage = ToDateWeightedAverage(size: 7, rule: {$0.isTuesday()})
        case .WTDThu:       rAverage = ToDateWeightedAverage(size: 7, rule: {$0.isWednesday()})
        case .WTDFri:       rAverage = ToDateWeightedAverage(size: 7, rule: {$0.isThursday()})
        case .WTDSat:       rAverage = ToDateWeightedAverage(size: 7, rule: {$0.isFriday()})
        case .WTDSun:       rAverage = ToDateWeightedAverage(size: 7, rule: {$0.isSaturday()})
        case .MonthToDate:  rAverage = ToDateWeightedAverage(size: 31, rule: {$0.isEndOfMonth()})
        case .YearToDate:   rAverage = ToDateWeightedAverage(size: 366, rule: {$0.isEndOfYear()})
        case .Week:         rAverage = PeriodWeightedAverage(size: 7, rule: {$0.isEndOfWeek()})
        case .WeekTue:      rAverage = PeriodWeightedAverage(size: 7, rule: {$0.isMonday()})
        case .WeekWed:      rAverage = PeriodWeightedAverage(size: 7, rule: {$0.isTuesday()})
        case .WeekThu:      rAverage = PeriodWeightedAverage(size: 7, rule: {$0.isWednesday()})
        case .WeekFri:      rAverage = PeriodWeightedAverage(size: 7, rule: {$0.isThursday()})
        case .WeekSat:      rAverage = PeriodWeightedAverage(size: 7, rule: {$0.isFriday()})
        case .WeekSun:      rAverage = PeriodWeightedAverage(size: 7, rule: {$0.isSaturday()})
        case .Month:        rAverage = PeriodWeightedAverage(size: 31, rule: {$0.isEndOfMonth()})
        case .Year:         rAverage = PeriodWeightedAverage(size: 366, rule: {$0.isEndOfYear()})
            
        case .Lifetime, .Adhoc, .Workout:
            return nil
        }
        return rAverage
        
    }
}
