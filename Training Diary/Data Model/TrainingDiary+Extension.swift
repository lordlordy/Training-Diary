//
//  TrainingDiary+Extension.swift
//  Training Diary
//
//  Created by Steven Lord on 08/11/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Foundation

extension TrainingDiary{
    
    @objc dynamic var totalBikeKM: Double{
        return total(forKey: "bikeKM")
    }

    @objc dynamic var totalSwimKM: Double{
        return total(forKey: "swimKM")
    }
    
    @objc dynamic var totalRunKM: Double{
        return total(forKey: "runKM")
    }
    
    @objc dynamic var totalSeconds: Double{
        return total(forKey: "allSeconds")
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

    func getTSB(forActivity activity: Activity) ->  [(ctl: Double, atl: Double, tsb: Double)]{
        return getTSB(forActivity: activity, fromDate: firstDayOfDiary!)
    }
    
    func getTSB(forActivity activity: Activity, fromDate from: Date) -> [(ctl: Double, atl: Double, tsb: Double)]{
        return getTSB(forActivity: activity, fromDate: from, toDate: lastDayOfDiary!)
    }
    
    func getTSB(forActivity activity: Activity, fromDate from: Date, toDate to: Date) ->   [(ctl: Double, atl: Double, tsb: Double)]{
        let sortedDays = ascendingOrderedDays(fromDate: from, toDate: to)
        var result: [(Double, Double,Double)] = []
        
        for day in sortedDays{
            let a = day.value(forKey: activity.keyString(forUnit: .ATL)) as! Double
            let c = day.value(forKey: activity.keyString(forUnit: .CTL)) as! Double
            let t = day.value(forKey: activity.keyString(forUnit: .TSB)) as! Double
            result.append((ctl: c, atl: a, tsb: t))
        }

        return result
    }
    
    func getValues(forActivity activity: Activity, andUnit unit: Unit) -> [Double]{
        return getValues(forActivity: activity, andUnit: unit, fromDate: firstDayOfDiary!, toDate: lastDayOfDiary!)
    }

    func getValues(forActivity activity: Activity, andUnit unit: Unit, fromDate from: Date) -> [Double]{
        return getValues(forActivity: activity, andUnit: unit, fromDate: from, toDate: lastDayOfDiary!)
    }

    func getValues(forActivity activity: Activity, andUnit unit: Unit, fromDate from: Date, toDate to: Date) -> [Double]{
        let start = Date()
        var result: [Double] = []
        let sortedDays = ascendingOrderedDays(fromDate: from, toDate: to)
        for day in sortedDays{
            result.append(day.valueFor(activity: activity, activityType: ActivityType.All, unit: unit))
        }
        print("Time taken to get diary values for \(activity):\(unit) = \(Date().timeIntervalSince(start)) seconds")
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
