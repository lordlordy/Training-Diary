//
//  BaseDataCreatorFactory.swift
//  Training Diary
//
//  Created by Steven Lord on 06/11/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Foundation

protocol BaseDataCreator{
    func add(forDay d: Day)->Double
    func create(forDay d: Day)->Double
}

class BaseDataCreatorFactory{
    
    public static let shared = BaseDataCreatorFactory()
    
    func baseDataCreator(forActivity a: Activity, andActivityType at: ActivityType, andUnit u: Unit, andPeriod p: Period) -> BaseDataCreator?{
        switch p{
        case .Day:              return DayCreator(forActivity: a,andActivityType: at,andUnit: u)
        case .rWeek:            return RollingCreator(forActivity: a, andActivityType: at, andUnit: u, maxDays: 7)
        case .rMonth:           return RollingCreator(forActivity: a, andActivityType: at, andUnit: u, maxDays: 30)
        case .rYear:            return RollingCreator(forActivity: a, andActivityType: at, andUnit: u, maxDays: 365)
        case .WeekToDate:       return WTDCreator(forActivity: a, andActivityType: at, andUnit: u, maxDays: 7)
        case .MonthToDate:      return MTDCreator(forActivity: a, andActivityType: at, andUnit: u, maxDays: 31)
        case .YearToDate:       return YTDCreator(forActivity: a, andActivityType: at, andUnit: u, maxDays: 366)
        case .Week:             return WeekCreator(forActivity: a, andActivityType: at, andUnit: u, maxDays: 7)
        case .Month:            return MonthCreator(forActivity: a, andActivityType: at, andUnit: u, maxDays: 31)
        case .Year:             return YearCreator(forActivity: a, andActivityType: at, andUnit: u, maxDays: 366)
        case .Lifetime, .Adhoc: return nil
        }
    }
    
    private class DayCreator: BaseDataCreator{
        private let a: Activity
        private let at: ActivityType
        private let u: Unit
        init(forActivity a: Activity,andActivityType at: ActivityType, andUnit u: Unit){
            self.a = a
            self.at = at
            self.u = u
        }
        func add(forDay d: Day) -> Double {
            return d.valueFor(activity: a, activityType: at, unit: u)
        }
        func create(forDay d: Day) -> Double {
            return add(forDay: d)
        }
    }
    
    private class RollingCreator: BaseDataCreator{
        private let a: Activity
        private let at: ActivityType
        private let u: Unit
        private let maxSize: Int
        fileprivate let values: RollingSumQueue
        private var rollingSum = 0.0
        
        init(forActivity a: Activity, andActivityType at: ActivityType, andUnit u: Unit, maxDays r: Int){
            self.a = a
            self.at = at
            self.u = u
            values = RollingSumQueue(size: r)
            maxSize = r
        }
        
        func add(forDay d: Day) -> Double {
            return values.addAndReturnSum( value: d.valueFor(activity: a, activityType: at, unit: u) )
        }
        func create(forDay d: Day) -> Double {
            return 0.0
        }
    }
    
    //resets at start of week
    private class WTDCreator: RollingCreator{
        override func add(forDay d: Day) -> Double {
            if reset(forDay: d){
                values.resetQueue()
            }
            return super.add(forDay: d)
        }
        func reset(forDay d: Day) -> Bool{
            return d.date!.isStartOfWeek()
        }
    }
    
    private class WeekCreator: WTDCreator{
        override func add(forDay d: Day)-> Double{
            let value = super.add(forDay: d)
            if d.date!.isEndOfWeek(){
                return value
            }else{
                return 0.0
            }
        }
    }
    
    //resets at start of Month
    private class MTDCreator: WTDCreator{
        override func reset(forDay d: Day) -> Bool{
            return d.date!.isStartOfMonth()
        }
    }
    
    private class MonthCreator: MTDCreator{
        override func add(forDay d: Day) -> Double {
            let value = super.add(forDay: d)
            if d.date!.isEndOfMonth(){
                return value
            }else{
                return 0.0
            }
        }
    }

    //resets at start of Year
    private class YTDCreator: WTDCreator{
        override func reset(forDay d: Day) -> Bool{
            return d.date!.isStartdOfYear()
        }
    }

    private class YearCreator: YTDCreator{
        override func add(forDay d: Day) -> Double {
            let value = super.add(forDay: d)
            if d.date!.isEndOfYear(){
                return value
            }else{
                return 0.0
            }
        }
    }
    
    private init(){}
}



