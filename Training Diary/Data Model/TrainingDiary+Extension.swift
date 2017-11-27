//
//  TrainingDiary+Extension.swift
//  Training Diary
//
//  Created by Steven Lord on 08/11/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Foundation

extension TrainingDiary{
    
    @objc dynamic var totalBikeKM:  Double{ return total(forKey: "bikeKM") }
    @objc dynamic var totalSwimKM:  Double{ return total(forKey: "swimKM") }
    @objc dynamic var totalRunKM:   Double{ return total(forKey: "runKM") }
    @objc dynamic var totalSeconds: Double{ return total(forKey: "allSeconds")}
    
    var numberOfDays: Int{
        if let daysSet = days{
            return daysSet.count
        }
        return 0
    }
    
    //needs implementing properly
    @objc dynamic var firstDayOfDiary: Date?{
        let days = ascendingOrderedDays()
        if days.count > 0{
            return days[0].date
        }else{
            return nil
        }
    }
    
    func firstYear() -> Int{
        return Calendar.current.dateComponents([.year], from: firstDayOfDiary!).year!
    }
    
    @objc dynamic var lastDayOfDiary: Date?{
        let days = ascendingOrderedDays()
        if days.count > 0{
            return days[days.count-1].date
        }else{
            return nil
        }
    }
    
    func lastYear() -> Int{
        return Calendar.current.dateComponents([.year], from: lastDayOfDiary!).year!
    }
    
    func weightsAscendingDateOrder() -> [Weight]?{
        if let ws = self.weights{
            let weightsArray = ws.allObjects as! [Weight]
            return weightsArray.sorted(by: { $0.fromDate! < $1.fromDate! })
        }
        return nil
    }

    func physiologicalsAscendingDateOrder() -> [Physiological]?{
        if let ps = self.physiologicals{
            let physios = ps.allObjects as! [Physiological]
            return physios.sorted(by: { $0.fromDate! < $1.fromDate! })
        }
        return nil
    }
    
    func kgAscendingDateOrder() -> [(date: Date, value: Double)]{
        var result: [(date: Date, value: Double)] = []
        if let orderedWeights = weightsAscendingDateOrder(){
            for w in orderedWeights{
                result.append((w.fromDate!, w.kg))
            }
        }
        return result
    }
    
    func fatPercentageDateOrder() -> [(date: Date, value: Double)]{
        var result: [(date: Date, value: Double)] = []
        if let orderedWeights = weightsAscendingDateOrder(){
            for w in orderedWeights{
                result.append((w.fromDate!, w.fatPercent))
            }
        }
        return result
    }
    
    func hrPercentageDateOrder() -> [(date: Date, value: Double)]{
        var result: [(date: Date, value: Double)] = []
        if let orderedPhysios = physiologicalsAscendingDateOrder(){
            for o in orderedPhysios{
                result.append((o.fromDate!, Double(o.restingHR)))
            }
        }
        return result
    }
    
    func sdnnPercentageDateOrder() -> [(date: Date, value: Double)]{
        var result: [(date: Date, value: Double)] = []
        if let orderedPhysios = physiologicalsAscendingDateOrder(){
            for o in orderedPhysios{
                result.append((o.fromDate!, Double(o.restingSDNN)))
            }
        }
        return result
    }

    func rmssdPercentageDateOrder() -> [(date: Date, value: Double)]{
        var result: [(date: Date, value: Double)] = []
        if let orderedPhysios = physiologicalsAscendingDateOrder(){
            for o in orderedPhysios{
                result.append((o.fromDate!, Double(o.restingRMSSD)))
            }
        }
        return result
    }
    
    private func total(forKey: String) ->Double{
        var result: Double = 0.0
        if let allDays = days{
            for d in allDays{
                let day = d as! Day
                result += day.value(forKey: forKey) as! Double
            }
        }
        return result
    }


    func getValues(forActivity activity: Activity, andUnit unit: Unit) -> [(date: Date, value:Double)]{
        return getValues(forActivity: activity, andUnit: unit, fromDate: firstDayOfDiary!, toDate: lastDayOfDiary!)
    }

    func getValues(forActivity activity: Activity, andUnit unit: Unit, fromDate from: Date) -> [(date: Date, value:Double)]{
        return getValues(forActivity: activity, andUnit: unit, fromDate: from, toDate: lastDayOfDiary!)
    }

    func getValues(forActivity activity: Activity, andUnit unit: Unit, fromDate from: Date, toDate to: Date) -> [(date: Date, value:Double)]{
        let start = Date()
        var result: [(date: Date, value: Double)] = []
        let sortedDays = ascendingOrderedDays(fromDate: from, toDate: to)
        if sortedDays.count > 0 {
            for day in sortedDays{
                result.append((date: day.date!, value: day.valueFor(activity: activity, activityType: ActivityType.All, unit: unit)))
            }
        }
        print("Time taken to get diary values for \(activity):\(unit) = \(Date().timeIntervalSince(start)) seconds")
        return result
    }

    // not this can be pretty time consuming if asking for things like RYear
    func getValues(forActivity activity: Activity, andPeriod period: Period, andUnit unit: Unit) -> [(date: Date, value:Double)]{
        if let results = optimisedCalculation(forActivity: activity, andPeriod: period, andUnit: unit){
            //optimized calculation available
            return results
        }
        return getValues(forActivity: activity, andPeriod: period, andUnit: unit, fromDate: firstDayOfDiary!)
    }

    // not this can be pretty time consuming if asking for things like RYear
    func getValues(forActivity activity: Activity, andPeriod period: Period, andUnit unit: Unit, fromDate from: Date) -> [(date: Date, value:Double)]{
        return getValues(forActivity: activity, andPeriod: period, andUnit: unit, fromDate: from, toDate: lastDayOfDiary!)
    }

    // not this can be pretty time consuming if asking for things like RYear
    func getValues(forActivity activity: Activity, andPeriod period: Period, andUnit unit: Unit, fromDate from: Date, toDate to: Date) -> [(date: Date, value:Double)]{
        let start = Date()
        var result: [(date: Date, value: Double)] = []
        let sortedDays = ascendingOrderedDays(fromDate: from, toDate: to)
        if sortedDays.count > 0 {
            for day in sortedDays{
                result.append((date: day.date!, value: day.valueFor(period: period, activity: activity, activityType: ActivityType.All, unit: unit)))
            }
        }
        print("Time taken to get diary values for \(activity):\(period.rawValue):\(unit) = \(Date().timeIntervalSince(start)) seconds")
        return result
    }
    
    func calcTSB(forActivity activity: Activity, fromDate d: Date){
        let start = Date()
        
        if !(activity == Activity.All){ // all is a calculated property
            let factors = tsbFactors(forActivity: activity)
            for day in ascendingOrderedDays(fromDate: d){
                let tss = day.valueFor(activity: activity, activityType: ActivityType.All, unit: Unit.TSS)
                var atl = tss * factors.atlDayFactor
                var ctl = tss * factors.ctlDayFactor
                
                if let yesterday = day.yesterday{
                    let yATL = yesterday.value(forKey: activity.keyString(forUnit: .ATL)) as! Double
                    let yCTL = yesterday.value(forKey: activity.keyString(forUnit: .CTL)) as! Double
                    atl += yATL * factors.atlYDayFactor
                    ctl += yCTL * factors.ctlYDayFactor
                }
                day.setValue(atl, forKey: activity.keyString(forUnit: Unit.ATL))
                day.setValue(ctl, forKey: activity.keyString(forUnit: Unit.CTL))
            }
        }
        
        print("Calc TSB for \(activity.rawValue) took \(Date().timeIntervalSince(start)) seconds")
    }
    
    // this is focussed on the rolling periods. It is very time consuming to just loop through and ask each day for it's rolling period - by way of example. RollingYear for all days would require summing 365 days for every day - thats 5,000 x 365 sums - if we ask each day individually. If we run through the days and keep a total as we go there is ~ 2 sums per day. So should be ~ 180 times faster. Sacrifising generalisation for speed here.
    private func optimisedCalculation(forActivity activity: Activity, andPeriod period: Period, andUnit unit: Unit) -> [(date: Date, value:Double)]?{
        print("STARTING optimized calculation for \(activity):\(period.rawValue):\(unit)...")
        let start = Date()
        var result: [(date: Date, value:Double)] = []
        var rSum: RollingPeriodSum
        switch period{
        case .rWeek:    rSum = RollingPeriodSum.init(size: 7)
        case .rMonth:   rSum = RollingPeriodSum.init(size: 30)
        case .rYear:    rSum = RollingPeriodSum.init(size: 365)
        case .WeekToDate: rSum  = ToDateSum(size: 7, rule: {$0.isEndOfWeek()})
        case .MonthToDate: rSum  = ToDateSum(size: 31, rule: {$0.isEndOfMonth()})
        case .YearToDate: rSum  = ToDateSum(size: 366, rule: {$0.isEndOfYear()})
        default:
            print("... no need for period: \(period.rawValue)")
            return nil
        }
        
        for d in ascendingOrderedDays(){
            let sum = rSum.addAndReturnSum(forDate: d.date!, value: d.valueFor(activity: activity, activityType: ActivityType.All, unit: unit))
            result.append((d.date!, sum))
        }
        
        print("Optimised took \(Date().timeIntervalSince(start)) seconds")
        
        return result
    }

    private func tsbFactors(forActivity activity: Activity) -> (ctlYDayFactor: Double,ctlDayFactor:Double, atlYDayFactor: Double, atlDayFactor: Double){
        
        let constants = tsbConstants(forActivity: activity)
        
        let ctlYDF = exp(-1.0/constants.ctlDays)
        let ctlDF = 1.0 - ctlYDF
        let atlYDF = exp(-1.0/constants.atlDays)
        let atlDF = 1.0 - atlYDF
        
        return (ctlYDayFactor: ctlYDF, ctlDayFactor: ctlDF, atlYDayFactor: atlYDF, atlDayFactor: atlDF)
        
    }
    
    private func tsbConstants(forActivity activity: Activity) -> (atlDays: Double, ctlDays: Double){
        switch activity{
        case .Swim: return (atlDays: self.swimATLDays, ctlDays: self.swimCTLDays)
        case .Bike: return (atlDays: self.bikeATLDays, ctlDays: self.bikeCTLDays)
        case .Run: return (atlDays: self.runATLDays, ctlDays: self.runCTLDays)
        default: return (atlDays: self.atlDays, ctlDays: self.ctlDays)
        }
    }
    
    private func ascendingOrderedDays(fromDate from: Date, toDate to: Date) -> [Day]{
        return ascendingOrderedDays().filter({$0.date! >= from && $0.date! <= to})
    }
    
    private func ascendingOrderedDays(fromDate d: Date) -> [Day]{
        return ascendingOrderedDays().filter({$0.date! >= d})
    }
    
    private func ascendingOrderedDays() -> [Day]{
        if let diaryDays = self.days{
            var days: [Day] = []
            for fd in diaryDays{
                days.append(fd as! Day)
            }
            return days.sorted(by: {$0.date! < $1.date!})
        }
        return []
    }
}
