//
//  TrainingDiary+Extension.swift
//  Training Diary
//
//  Created by Steven Lord on 08/11/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Foundation

extension TrainingDiary{
    
    //MARK: - for display in GUI summary
    @objc dynamic var totalBikeKM:  Double{ return total(forKey: "bikeKM") }
    @objc dynamic var totalSwimKM:  Double{ return total(forKey: "swimKM") }
    @objc dynamic var totalRunKM:   Double{ return total(forKey: "runKM") }
    @objc dynamic var totalSeconds: Double{ return total(forKey: "allSeconds")}
    @objc dynamic var totalTime: TimeInterval{ return TimeInterval(totalSeconds)}
    
    // don't think this really need @objc dynamic - check and remove
    @objc dynamic var firstDayOfDiary: Date{
        let days = ascendingOrderedDays()
        if days.count > 0{
            if let day = days[0].date{ return day }
        }
        return Date()
    }
    
    // don't think this really need @objc dynamic - check and remove
    @objc dynamic var lastDayOfDiary: Date{
        return latestDay()?.date ?? Date()
    }
    
    func latestDay() -> Day?{
        let days = ascendingOrderedDays()
        if days.count > 0{ return days[days.count-1] }
        return nil
    }
    
    func firstYear() -> Int{ return Calendar.current.dateComponents([.year], from: firstDayOfDiary).year! }
    func lastYear() -> Int{ return Calendar.current.dateComponents([.year], from: lastDayOfDiary).year! }
    
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
    
    func hrDateOrder() -> [(date: Date, value: Double)]{
        var result: [(date: Date, value: Double)] = []
        if let orderedPhysios = physiologicalsAscendingDateOrder(){
            for o in orderedPhysios{
                result.append((o.fromDate!, Double(o.restingHR)))
            }
        }
        return result
    }
    
    func sdnnDateOrder() -> [(date: Date, value: Double)]{
        var result: [(date: Date, value: Double)] = []
        if let orderedPhysios = physiologicalsAscendingDateOrder(){
            for o in orderedPhysios{
                result.append((o.fromDate!, Double(o.restingSDNN)))
            }
        }
        return result
    }

    func rmssdDateOrder() -> [(date: Date, value: Double)]{
        var result: [(date: Date, value: Double)] = []
        if let orderedPhysios = physiologicalsAscendingDateOrder(){
            for o in orderedPhysios{
                result.append((o.fromDate!, Double(o.restingRMSSD)))
            }
        }
        return result
    }
    

 //   func getValues(forActivity activity: Activity, andUnit unit: Unit) -> [(date: Date, value:Double)]{
   //     return getValues(forActivity: activity, andUnit: unit, fromDate: firstDayOfDiary, toDate: lastDayOfDiary)
    //}

 //   func getValues(forActivity activity: Activity, andUnit unit: Unit, fromDate from: Date) -> [(date: Date, value:Double)]{
   //     return getValues(forActivity: activity, andUnit: unit, fromDate: from, toDate: lastDayOfDiary)
   // }

/*    func getValues(forActivity activity: Activity, andUnit unit: Unit, fromDate from: Date, toDate to: Date) -> [(date: Date, value:Double)]{
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
*/
    
    //MARK: - Getting values
    func getValues(forActivity activity: Activity, andPeriod period: Period, andUnit unit: Unit) -> [(date: Date, value:Double)]{
        return getValues(forActivity: activity, andPeriod: period, andUnit: unit, fromDate: firstDayOfDiary)
    }

    // note this can be pretty time consuming if asking for things like RYear
    func getValues(forActivity activity: Activity, andPeriod period: Period, andUnit unit: Unit, fromDate from: Date) -> [(date: Date, value:Double)]{
        return getValues(forActivity: activity, andPeriod: period, andUnit: unit, fromDate: from, toDate: lastDayOfDiary)
    }

    // note this can be pretty time consuming if asking for things like RYear
    func getValues(forActivity activity: Activity, andPeriod period: Period, andUnit unit: Unit, fromDate from: Date, toDate to: Date) -> [(date: Date, value:Double)]{
        let start = Date()
        
        if let optimizedResults = optimisedCalculation(forActivity: activity, andPeriod: period, andUnit: unit, fromDate: from, toDate: to){
            return optimizedResults
        }
        
        //if we get to this point it means optimization calculation hasn't worked.
        //This will then sum through days / workouts recursively. This can be slow
        //it also means averaging is rather tricky and hasn't been implemented (yet?)
        var result: [(date: Date, value: Double)] = []
        
        if period != Period.Day && !unit.summable{
            print("getValues(forActivity in Training Diary has not implemented weighted averaging so cannot return values for \(unit.rawValue)")
            return result
        }
        
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
               // print("calc for \(day.date!) ATL: \(atl) - CTL: \(ctl) using KEY: \(activity.keyString(forUnit: Unit.ATL))")
                let s = Date()
                day.setMetricValue(forActivity: activity, andMetric: Unit.ATL, toValue: atl)
       /*         if activity == Activity.Run{
                    day.setValue(atl, forKey: "test")
                }else{
                    day.setValue(atl, forKey: activity.keyString(forUnit: Unit.ATL))
                }
 */
                let s2 = Date()
                day.setMetricValue(forActivity: activity, andMetric: Unit.CTL, toValue: ctl)
   /*             if activity == Activity.Bike{
                    day.setValue(ctl, forKey: "testCTL")
                }else{
                    day.setValue(ctl, forKey: activity.keyString(forUnit: Unit.CTL))
                }
 */
                 let finish = Date()
                day.setMetricValue(forActivity: activity, andMetric: Unit.TSB, toValue: ctl - atl)
                if s2.timeIntervalSince(s) > TimeInterval(0.1){ print("ATL for \(activity) took \(s2.timeIntervalSince(s)) seconds") }
                if finish.timeIntervalSince(s2) > TimeInterval(0.1){ print("CTL for \(activity) took \(finish.timeIntervalSince(s2)) seconds") }

                
                if Date().timeIntervalSince(start) > TimeInterval(5.0){
                    print("exiting TSB calc for \(activity) as taking too long (ie more than 5s)")
                    return
                }
                
            }
            print("Calc TSB for \(activity.rawValue) took \(Date().timeIntervalSince(start)) seconds")
            
            
        }
        
    }
    
    //MARK: - Private
    
    private func weightsAscendingDateOrder() -> [Weight]?{
        if let ws = self.weights{
            let weightsArray = ws.allObjects as! [Weight]
            return weightsArray.sorted(by: { $0.fromDate! < $1.fromDate! })
        }
        return nil
    }
    
    private func physiologicalsAscendingDateOrder() -> [Physiological]?{
        if let ps = self.physiologicals{
            let physios = ps.allObjects as! [Physiological]
            return physios.sorted(by: { $0.fromDate! < $1.fromDate! })
        }
        return nil
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
    

    
    // this is focussed on the rolling periods. It is very time consuming to just loop through and ask each day for it's rolling period - by way of example. RollingYear for all days would require summing 365 days for every day - thats 5,000 x 365 sums - if we ask each day individually. If we run through the days and keep a total as we go there are ~ 2 sums per day. So should be ~ 180 times faster. Sacrifising generalisation for speed here. A second benefit is this method makes it easier to average units rather than just sum them.
    private func optimisedCalculation(forActivity activity: Activity, andPeriod period: Period, andUnit unit: Unit, fromDate from: Date, toDate to: Date) -> [(date: Date, value:Double)]?{
        print("STARTING optimized calculation for \(activity):\(period.rawValue):\(unit)...")
        let start = Date()
        var result: [(date: Date, value:Double)] = []
        
        if unit.summable{
            var rSum: RollingPeriodSum
            switch period{
            case .rWeek:        rSum = RollingPeriodSum(size: 7)
            case .rMonth:       rSum = RollingPeriodSum(size: 30)
            case .rYear:        rSum = RollingPeriodSum(size: 365)
            case .WeekToDate:   rSum  = ToDateSum(size: 7, rule: {$0.isEndOfWeek()})
            case .MonthToDate:  rSum  = ToDateSum(size: 31, rule: {$0.isEndOfMonth()})
            case .YearToDate:   rSum  = ToDateSum(size: 366, rule: {$0.isEndOfYear()})
            case .Week:         rSum  = PeriodSum(size: 7, rule: {$0.isEndOfWeek()})
            case .Month:        rSum  = PeriodSum(size: 31, rule: {$0.isEndOfMonth()})
            case .Year:         rSum  = PeriodSum(size: 366, rule: {$0.isEndOfYear()})
            default:
                print("... no need for period: \(period.rawValue)")
                return nil
            }
            
            for d in ascendingOrderedDays(fromDate: rSum.preLoadData(forDate: from), toDate: to){
                let sum = rSum.addAndReturnSum(forDate: d.date!, value: d.valueFor(activity: activity, activityType: ActivityType.All, unit: unit))
                if d.date! >= from{
                    if let s = sum{
                        result.append((d.date!, s))
                    }
                }
            }
            
        }else{
            var rAverage: RollingPeriodWeightedAverage
            switch period{
            case .rWeek:        rAverage = RollingPeriodWeightedAverage(size: 7)
            case .rMonth:       rAverage = RollingPeriodWeightedAverage(size: 30)
            case .rYear:        rAverage = RollingPeriodWeightedAverage(size: 365)
            case .WeekToDate:   rAverage = ToDateWeightedAverage(size: 7, rule: {$0.isEndOfWeek()})
            case .MonthToDate:  rAverage = ToDateWeightedAverage(size: 31, rule: {$0.isEndOfMonth()})
            case .YearToDate:   rAverage = ToDateWeightedAverage(size: 366, rule: {$0.isEndOfYear()})
            case .Week:         rAverage = PeriodWeightedAverage(size: 7, rule: {$0.isEndOfWeek()})
            case .Month:        rAverage = PeriodWeightedAverage(size: 31, rule: {$0.isEndOfMonth()})
            case .Year:         rAverage = PeriodWeightedAverage(size: 366, rule: {$0.isEndOfYear()})
            default:
                print("... no need for period: \(period.rawValue)")
                return nil
            }
            
            
            for d in ascendingOrderedDays(fromDate: rAverage.preLoadData(forDate: from), toDate: to){
                let sum = rAverage.addAndReturnAverage(forDate: d.date!, value: d.valueFor(activity: activity, activityType: ActivityType.All, unit: unit), wieghting: d.valueFor(activity: activity, activityType: ActivityType.All, unit: Unit.Seconds))
                if d.date! >= from{
                    if let s = sum{
                        result.append((d.date!, s))
                    }
                }
            }
        }
        
        
        print("Optimised calculation returned \(result.count) results and took \(Date().timeIntervalSince(start)) seconds")
        
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
