//
//  Plan+Extension.swift
//  Training Diary
//
//  Created by Steven Lord on 22/04/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Foundation

extension Plan{

    @objc dynamic var precedingPlanName: String{
        get{
            return precedingPlan?.name ?? ConstantString.NotSet.rawValue
        }
        set{
           let p  = trainingDiary?.plan(forName: newValue)
            precedingPlan = p
        }
    }
    
    //this is for JSON serialisation
    @objc dynamic var iso8061FromString: String{
        return from!.iso8601Format()
    }
    @objc dynamic var iso8061TaperStartString: String{
        return taperStart!.iso8601Format()
    }
    @objc dynamic var iso8061ToString: String{
        return to!.iso8601Format()
    }

    //this is for CSV serialisation
    @objc dynamic var csvFromString: String{
        return from!.dateOnlyString()
    }
    @objc dynamic var csvTaperStartString: String{
        return taperStart!.dateOnlyString()
    }
    @objc dynamic var csvToString: String{
        return to!.dateOnlyString()
    }
    
    @objc dynamic var nameNotSet: Bool{
        if let n = name{
            return n == ""
        }
        return true
    }
    
    func updateFirstDay(){
        let days = orderedPlanDays()
        if days.count > 0{
            populateStartingTrainingLoads(inDay: days[0])
        }
    }
    
    func createPlan(){
        planDays = nil
        let firstDay = addNewPlanDay()
        firstDay.date = from?.yesterday()

        populateStartingTrainingLoads(inDay: firstDay)
        
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

                    if cal.compare(d.date!, to: today, toGranularity: .day) == ComparisonResult.orderedDescending{
                        //after today so no actual
                        d.actualSwimATL = swim.atl(yesterdayATL: y.actualSwimATL, tss: 0.0)
                        d.actualSwimCTL = swim.ctl(yesterdayCTL: y.actualSwimCTL, tss: 0.0)
                        d.actualBikeATL = bike.atl(yesterdayATL: y.actualBikeATL, tss: 0.0)
                        d.actualBikeCTL = bike.ctl(yesterdayCTL: y.actualBikeCTL, tss: 0.0)
                        d.actualRunATL = run.atl(yesterdayATL: y.actualRunATL, tss: 0.0)
                        d.actualRunCTL = run.ctl(yesterdayCTL: y.actualRunCTL, tss: 0.0)
                        d.actualThenPlanSwimATL = swim.atl(yesterdayATL: y.actualThenPlanSwimATL, tss: d.swimTSS)
                        d.actualThenPlanSwimCTL = swim.ctl(yesterdayCTL: y.actualThenPlanSwimCTL, tss: d.swimTSS)
                        d.actualThenPlanBikeATL = bike.atl(yesterdayATL: y.actualThenPlanBikeATL, tss: d.bikeTSS)
                        d.actualThenPlanBikeCTL = bike.ctl(yesterdayCTL: y.actualThenPlanBikeCTL, tss: d.bikeTSS)
                        d.actualThenPlanRunATL = run.atl(yesterdayATL: y.actualThenPlanRunATL, tss: d.runTSS)
                        d.actualThenPlanRunCTL = run.ctl(yesterdayCTL: y.actualThenPlanRunCTL, tss: d.runTSS)
                    }else{
                        //before today or today so use actual TSS
                        d.actualSwimATL = swim.atl(yesterdayATL: y.actualSwimATL, tss: d.actualSwimTSS)
                        d.actualSwimCTL = swim.ctl(yesterdayCTL: y.actualSwimCTL, tss: d.actualSwimTSS)
                        d.actualBikeATL = bike.atl(yesterdayATL: y.actualBikeATL, tss: d.actualBikeTSS)
                        d.actualBikeCTL = bike.ctl(yesterdayCTL: y.actualBikeCTL, tss: d.actualBikeTSS)
                        d.actualRunATL = run.atl(yesterdayATL: y.actualRunATL, tss: d.actualRunTSS)
                        d.actualRunCTL = run.ctl(yesterdayCTL: y.actualRunCTL, tss: d.actualRunTSS)
                        d.actualThenPlanSwimATL = d.actualSwimATL
                        d.actualThenPlanSwimCTL = d.actualSwimCTL
                        d.actualThenPlanBikeATL = d.actualBikeATL
                        d.actualThenPlanBikeCTL = d.actualBikeCTL
                        d.actualThenPlanRunATL = d.actualRunATL
                        d.actualThenPlanRunCTL = d.actualRunCTL
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
    
    func orderedBasicWeek() -> [BasicWeekDay]{
        if let basicWeek = basicWeek?.allObjects as? [BasicWeekDay]{
            return basicWeek.sorted(by: {$0.order < $1.order})
        }
        return []
    }
    
    private var basicWeekDictionary: [String: BasicWeekDay]{
        let a = basicWeek!.allObjects as! [BasicWeekDay]
        var result: [String: BasicWeekDay] = [:]
        for d in a{
            result[d.name!] = d
        }
        return result
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
    
    /* Logic here. Priority is:
     1. Take starting from Training Diary if last day of diary is this day  or later
     2. If preceding plan is set take from there and decay to day before start if needed
     3. If start training loads override set to true
     4. Final thing is to use Training Plan and decay from there
    */
    private func populateStartingTrainingLoads(inDay day: PlanDay){
        guard let date = day.date else { return }
        guard let td = trainingDiary else { return }
        
        let cal = Calendar.init(identifier: Calendar.Identifier.iso8601)
        let comparison: ComparisonResult = cal.compare(date, to: td.lastDayOfDiary, toGranularity: .day)
        
        if comparison != ComparisonResult.orderedDescending{
            populateTrainingLoad(fromTrainingDiary: td, inDay: day)
        }else if let plan = precedingPlan{
            populateTrainingLoad(fromPlan: plan, inDay: day)
        }else if useStartingLoadOverrides{
            populateTrainingLoadFromOverrides(inDay: day)
        }else{
            populateTrainingLoad(fromTrainingDiary: td, inDay: day)
        }
        
        
    }
    
    private func populateTrainingLoad(fromTrainingDiary td: TrainingDiary, inDay day: PlanDay){
        if let d = td.getDay(forDate: day.date!){
            //can just get plan and actual from this day
            day.swimATL = d.swimATL
            day.swimCTL = d.swimCTL
            day.bikeATL = d.bikeATL
            day.bikeCTL = d.bikeCTL
            day.runATL = d.runATL
            day.runCTL = d.runCTL
            
            day.actualSwimATL = d.swimATL
            day.actualSwimCTL = d.swimCTL
            day.actualBikeATL = d.bikeATL
            day.actualBikeATL = d.bikeCTL
            day.actualRunATL = d.runATL
            day.actualRunCTL = d.runCTL
        }else if let d = td.latestDay(){
            let cal = Calendar.init(identifier: .iso8601)
            let dc = cal.dateComponents(Set([Calendar.Component.day]), from: d.date!, to: day.date!)
            let decayDays: Int = dc.day ?? 1
            
            day.swimATL = decayATL(value: d.swimATL, forActivity: FixedActivity.Swim.rawValue, numberOfDays: decayDays)
            day.swimCTL = decayCTL(value: d.swimCTL, forActivity: FixedActivity.Swim.rawValue, numberOfDays: decayDays)
            day.bikeATL = decayATL(value: d.bikeATL, forActivity: FixedActivity.Bike.rawValue, numberOfDays: decayDays)
            day.bikeCTL = decayCTL(value: d.bikeCTL, forActivity: FixedActivity.Bike.rawValue, numberOfDays: decayDays)
            day.runATL = decayATL(value: d.runATL, forActivity: FixedActivity.Run.rawValue, numberOfDays: decayDays)
            day.runCTL = decayCTL(value: d.runCTL, forActivity: FixedActivity.Run.rawValue, numberOfDays: decayDays)
        }
    }
    
    private func populateTrainingLoad(fromPlan plan: Plan, inDay day: PlanDay){
        let planDays: [PlanDay] = plan.orderedPlanDays()
        guard planDays.count > 0 else {return}
        let cal = Calendar.init(identifier: .iso8601)
        let pDay = cal.startOfDay(for: planDays[planDays.count - 1].date!)
        let daysSinceEndOfPlan = cal.dateComponents(Set([Calendar.Component.day]), from: pDay, to: cal.startOfDay(for: day.date!))
        
        if let daysSince = daysSinceEndOfPlan.day{
            if daysSince < 0{
                let index = planDays.count + daysSince - 1
                if index >= 0 && index < planDays.count{
                    let planDay = planDays[index]
                    day.swimATL = planDay.actualThenPlanSwimATL
                    day.swimCTL = planDay.actualThenPlanSwimCTL
                    day.bikeATL = planDay.actualThenPlanBikeATL
                    day.bikeCTL = planDay.actualThenPlanBikeCTL
                    day.runATL = planDay.actualThenPlanRunATL
                    day.runCTL = planDay.actualThenPlanRunCTL
                }
            }else{
                let planDay = planDays[planDays.count - 1]
                day.swimATL = decayATL(value: planDay.actualThenPlanSwimATL, forActivity: FixedActivity.Swim.rawValue, numberOfDays: daysSince)
                day.swimCTL = decayCTL(value: planDay.actualThenPlanSwimCTL, forActivity: FixedActivity.Swim.rawValue, numberOfDays: daysSince)
                day.bikeATL = decayATL(value: planDay.actualThenPlanBikeATL, forActivity: FixedActivity.Bike.rawValue, numberOfDays: daysSince)
                day.bikeCTL = decayCTL(value: planDay.actualThenPlanBikeCTL, forActivity: FixedActivity.Bike.rawValue, numberOfDays: daysSince)
                day.runATL = decayATL(value: planDay.actualThenPlanRunATL, forActivity: FixedActivity.Run.rawValue, numberOfDays: daysSince)
                day.runCTL = decayCTL(value: planDay.actualThenPlanRunCTL, forActivity: FixedActivity.Run.rawValue, numberOfDays: daysSince)
            }
        }
        
    }
    
    private func populateTrainingLoadFromOverrides(inDay day: PlanDay){
        day.swimATL = swimStartATL
        day.swimCTL = swimStartCTL
        day.bikeATL = bikeStartATL
        day.bikeCTL = bikeStartCTL
        day.runATL = runStartATL
        day.runCTL = runStartCTL
        
        day.actualSwimATL = swimStartATL
        day.actualSwimCTL = swimStartCTL
        day.actualBikeATL = bikeStartATL
        day.actualBikeCTL = bikeStartCTL
        day.actualRunATL = runStartATL
        day.actualRunCTL = runStartCTL
    }
    

    private func decayATL(value: Double, forActivity a: String, numberOfDays i: Int) -> Double{
        if let activity: Activity = trainingDiary?.activity(forString: a){
            return value * activity.atlDecayFactor(afterNDays: i)
        }
        return value
    }

    private func decayCTL(value: Double, forActivity a: String, numberOfDays i: Int) -> Double{
        if let activity: Activity = trainingDiary?.activity(forString: a){
            return value * activity.ctlDecayFactor(afterNDays: i)
        }
        return value
    }

}
