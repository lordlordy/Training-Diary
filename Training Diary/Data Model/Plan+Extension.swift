//
//  Plan+Extension.swift
//  Training Diary
//
//  Created by Steven Lord on 22/04/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Foundation

extension Plan{

    @objc dynamic var basicWeekTotalSwimTSS: Double { return totalBasicWeek(forProperty: BasicWeekDayProperty.swimTSS) }
    @objc dynamic var basicWeekTotalBikeTSS: Double { return totalBasicWeek(forProperty: BasicWeekDayProperty.bikeTSS) }
    @objc dynamic var basicWeekTotalRunTSS: Double { return totalBasicWeek(forProperty: BasicWeekDayProperty.runTSS) }
    @objc dynamic var basicWeekTotalAllTSS: Double { return basicWeekTotalSwimTSS + basicWeekTotalBikeTSS + basicWeekTotalRunTSS }

    private var basicWeekDictionary: [String: BasicWeekDay]{
        let a = basicWeek!.allObjects as! [BasicWeekDay]
        var result: [String: BasicWeekDay] = [:]
        for d in a{
            result[d.name!] = d
        }
        return result
    }
    
    
    func createPlan(){
        planDays = nil
        let firstDay = addNewPlanDay()
        firstDay.date = from?.yesterday()
        firstDay.swimATL = swimStartATL
        firstDay.swimCTL = swimStartCTL
        firstDay.bikeATL = bikeStartATL
        firstDay.bikeCTL = bikeStartCTL
        firstDay.runATL = runStartATL
        firstDay.runCTL = runStartCTL

        firstDay.actualSwimATL = swimStartATL
        firstDay.actualSwimCTL = swimStartCTL
        firstDay.actualBikeATL = bikeStartATL
        firstDay.actualBikeCTL = bikeStartCTL
        firstDay.actualRunATL = runStartATL
        firstDay.actualRunCTL = runStartCTL
        
        var currentDay = from!
        
        var cal = Calendar.init(identifier: .iso8601)
        cal.timeZone = TimeZone.init(secondsFromGMT: 0)!
        var buildCount = 0
        
        //build phase
        while cal.compare(taperStart!, to: currentDay, toGranularity: Calendar.Component.day) == ComparisonResult.orderedDescending{
            let pDay = newPlanDay(from: basicWeekDictionary[currentDay.dayOfWeekName()]!, planDay: buildCount)
            pDay.date = currentDay
            currentDay = currentDay.addDays(numberOfDays: 1)
            buildCount += 1
        }

        //taper phase
        var taperCount = 0
        while cal.compare(to!, to: currentDay, toGranularity: Calendar.Component.day) == ComparisonResult.orderedDescending{
            let pDay = newPlanTaperDay(from: basicWeekDictionary[currentDay.dayOfWeekName()]!, buildDays: buildCount, planTaperDay: taperCount)
            pDay.date = currentDay
            currentDay = currentDay.addDays(numberOfDays: 1)
            taperCount += 1
        }

        calcTSB()
        
    }
    
    func calcTSB(){
        if let td = trainingDiary{
            
            var cal = Calendar.init(identifier: .iso8601)
            cal.timeZone = TimeZone.init(secondsFromGMT: 0)!
            
            let swim = td.activity(forString: FixedActivity.Swim.rawValue)!
            let bike = td.activity(forString: FixedActivity.Bike.rawValue)!
            let run = td.activity(forString: FixedActivity.Run.rawValue)!
            var yesterday: PlanDay? = nil
            let today = Date()
            
            
            for d in orderedPlanDays(){
                if let y = yesterday{
                    d.swimATL = swim.atl(yesterdayATL: y.swimATL, tss: d.swimTSS)
                    d.swimCTL = swim.ctl(yesterdayCTL: y.swimCTL, tss: d.swimTSS)
                    d.bikeATL = bike.atl(yesterdayATL: y.bikeATL, tss: d.bikeTSS)
                    d.bikeCTL = bike.ctl(yesterdayCTL: y.bikeCTL, tss: d.bikeTSS)
                    d.runATL = run.atl(yesterdayATL: y.runATL, tss: d.runTSS)
                    d.runCTL = run.ctl(yesterdayCTL: y.runCTL, tss: d.runTSS)

                    var todayPassed: Bool = false
                    

                    if cal.compare(d.date!, to: today, toGranularity: .day) == ComparisonResult.orderedDescending{
                        //after today so no actual
                        if todayPassed{
                            d.actualSwimATL = swim.atl(yesterdayATL: y.swimATL, tss: d.swimTSS)
                            d.actualSwimCTL = swim.ctl(yesterdayCTL: y.swimCTL, tss: d.swimTSS)
                            d.actualBikeATL = bike.atl(yesterdayATL: y.bikeATL, tss: d.bikeTSS)
                            d.actualBikeCTL = bike.ctl(yesterdayCTL: y.bikeCTL, tss: d.bikeTSS)
                            d.actualRunATL = run.atl(yesterdayATL: y.runATL, tss: d.runTSS)
                            d.actualRunCTL = run.ctl(yesterdayCTL: y.runCTL, tss: d.runTSS)
                        }else{
                            d.actualSwimATL = swim.atl(yesterdayATL: y.actualSwimATL, tss: d.swimTSS)
                            d.actualSwimCTL = swim.ctl(yesterdayCTL: y.actualSwimCTL, tss: d.swimTSS)
                            d.actualBikeATL = bike.atl(yesterdayATL: y.actualBikeATL, tss: d.bikeTSS)
                            d.actualBikeCTL = bike.ctl(yesterdayCTL: y.actualBikeCTL, tss: d.bikeTSS)
                            d.actualRunATL = run.atl(yesterdayATL: y.actualRunATL, tss: d.runTSS)
                            d.actualRunCTL = run.ctl(yesterdayCTL: y.actualRunCTL, tss: d.runTSS)
                            todayPassed = true
                        }
                    }else{
                        //before today or today so use actual TSS
                        d.actualSwimATL = swim.atl(yesterdayATL: y.actualSwimATL, tss: d.actualSwimTSS)
                        d.actualSwimCTL = swim.ctl(yesterdayCTL: y.actualSwimCTL, tss: d.actualSwimTSS)
                        d.actualBikeATL = bike.atl(yesterdayATL: y.actualBikeATL, tss: d.actualBikeTSS)
                        d.actualBikeCTL = bike.ctl(yesterdayCTL: y.actualBikeCTL, tss: d.actualBikeTSS)
                        d.actualRunATL = run.atl(yesterdayATL: y.actualRunATL, tss: d.actualRunTSS)
                        d.actualRunCTL = run.ctl(yesterdayCTL: y.actualRunCTL, tss: d.actualRunTSS)
                    }
 
                }
                yesterday = d
            }
            
        }
        
        
    }
    
    func orderedPlanDays() -> [PlanDay]{
        if let p = planDays?.allObjects as? [PlanDay]{
            return p.sorted(by: {$0.date! < $1.date!})
        }
        return []
    }
    
    
    //returns the new day
    private func addNewPlanDay() -> PlanDay{
        let days = mutableSetValue(forKey: PlanProperty.planDays.rawValue)
        let newDay = CoreDataStackSingleton.shared.newPlanDay()
        days.add(newDay)
        return newDay
    }
    
    private func newPlanDay(from day: BasicWeekDay, planDay : Int) -> PlanDay{
        let newDay = addNewPlanDay()
        let week = Int(Double(planDay)/7.0)
        
        newDay.bikeTSS = day.bikeTSS * pow((1 + day.bikePercentage/100),Double(week))
        newDay.swimTSS = day.swimTSS * pow((1 + day.swimPercentage/100),Double(week))
        newDay.runTSS = day.runTSS * pow((1 + day.runPercentage/100),Double(week))
        newDay.comments = day.comments
        
        return newDay
    }

    private func newPlanTaperDay(from day: BasicWeekDay, buildDays: Int, planTaperDay : Int) -> PlanDay{
        let newDay = addNewPlanDay()
        let buildWeeks = Int(Double(buildDays)/7.0)
        let taperWeek = Int(Double(planTaperDay)/7.0) + 1
        
        newDay.bikeTSS = day.bikeTSS * pow((1 + day.bikePercentage/100),Double(buildWeeks)) * pow((1 - day.bikeTaperPercentage/100),Double(taperWeek))
        newDay.swimTSS = day.swimTSS * pow((1 + day.swimPercentage/100),Double(buildWeeks)) * pow((1 - day.swimTaperPercentage/100),Double(taperWeek))
        newDay.runTSS = day.runTSS * pow((1 + day.runPercentage/100),Double(buildWeeks)) * pow((1 - day.runTaperPercentage/100),Double(taperWeek))
        
        return newDay
    }
    
    
    private func orderedBasicWeek() -> [BasicWeekDay]{
        if let basicWeek = basicWeek?.allObjects as? [BasicWeekDay]{
            return basicWeek.sorted(by: {$0.order < $1.order})
        }
        return []
    }
    
    private func totalBasicWeek(forProperty p: BasicWeekDayProperty) -> Double{
        var result: Double = 0.0
        for d in orderedBasicWeek(){
            result += d.value(forKey: p.rawValue) as! Double
        }
        return result
    }
    

}
