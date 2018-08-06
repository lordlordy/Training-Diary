//
//  JSONImporter.swift
//  Training Diary
//
//  Created by Steven Lord on 09/11/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Cocoa

class JSONImporter{
    
    
    public func importDiary(fromURL url: URL){
        if let json = importJSON(fromURL: url) {
            let td = CoreDataStackSingleton.shared.newTrainingDiary()
            
            for i in json{
                if TrainingDiaryProperty.jsonProperties.map({$0.rawValue}).contains(i.key){
                    td.setValue(i.value, forKey: i.key)
                }
            }
            
            td.setValue("JSON IMPORT - \(Date().dateOnlyShorterString())", forKey: "name")
            add(json, toTrainingDiary: td )
        }
    }
    
    public func merge(fromURL url: URL, intoDiary td: TrainingDiary){
        if let json = importJSON(fromURL: url){
            add(json, toTrainingDiary: td)
        }
    }
    
    
    
    //MARK: - Private
    
    private func importJSON(fromURL url: URL) -> [String:Any]?{
        
        print("Loading JSON from URL = \(url) ...")
        do{
            let data: Data = try Data.init(contentsOf: url)
            let jsonData  = try JSONSerialization.jsonObject(with: data, options: [.allowFragments, .mutableContainers])
            let jsonDict = jsonData as? [String:Any]
            return jsonDict
        }catch{
            print("error initialising Training Diary for URL: " + url.absoluteString)
            return nil
        }
    }
    
    private func add(_ json: [String: Any], toTrainingDiary td: TrainingDiary){
        
        addDaysAndWorkouts(fromJSON: json, toTrainingDiary: td)
        addWeights(fromJSON: json, toTrainingDiary: td)
        addPhysiologicals(fromJSON: json, toTrainingDiary: td)
        addPlans(fromJSON: json, toTrainingDiary: td)
        
        for e in CoreDataStackSingleton.shared.getEntityCounts(forDiary: td){
            print("\(e.entity) = \(e.count)")
        }
    }
    
    
    private func addDaysAndWorkouts(fromJSON json: [String: Any], toTrainingDiary td: TrainingDiary){
        
        let trainingDiaryDateString: [String] = td.ascendingOrderedDays().map({$0.date!.dateOnlyString()})
        var addedCount: Int = 0
        
        if let days = json[TrainingDiaryProperty.days.rawValue] as? [[String:Any]]{
            for dayDict in days{
                if let dateString = dayDict[DayProperty.iso8061DateString.rawValue] as? String{
                    let dateOnly = dateString.split(separator: "T")[0]
                    if trainingDiaryDateString.contains(String(dateOnly)){
                        print("TrainingDiary already includes day for \(dateOnly)")
                    }else{
                        // add this day
                        addDay(td, dayDict)
                        addedCount += 1
                    }
                }else{
                    print("No iso8061DateString value so can't add \(dayDict)")
                }
            }
            let addedDays: [Day] = td.mutableSetValue(forKey: TrainingDiaryProperty.days.rawValue).allObjects as! [Day]
            insertYesterdayAndTomorrow(forDays: addedDays)
        }
        
        print("Added \(addedCount) days")
        
    }

    fileprivate func addDay(_ td: TrainingDiary, _ dayDict: [String : Any]) {
        // Create a Day ManagedObject
        let day = NSManagedObject.init(entity: NSEntityDescription.entity(forEntityName: ENTITY.Day.rawValue, in: CoreDataStackSingleton.shared.trainingDiaryPC.viewContext)!, insertInto: CoreDataStackSingleton.shared.trainingDiaryPC.viewContext)
        // add to training diary
        td.mutableSetValue(forKey: TrainingDiaryProperty.days.rawValue).add(day)
        
        for p in dayDict{
            switch p.key{
            case DayProperty.iso8061DateString.rawValue:
                if let d = ISO8601DateFormatter().date(from: p.value as! String){
                    day.setValue(d, forKey: DayProperty.date.rawValue)
                }else{
                    print("Unable to format date from \(p.value)")
                }
            case DayProperty.sleep.rawValue, DayProperty.sleepQuality.rawValue, DayProperty.type.rawValue, DayProperty.motivation.rawValue, DayProperty.fatigue.rawValue:
                day.setValue(p.value, forKey: p.key)
            case DayProperty.comments.rawValue:
                if p.value is NSNull {
                    //      print("\(p) is nil")
                }else{
                    day.setValue(p.value, forKey: p.key)
                }
            case DayProperty.workouts.rawValue:
                if let workouts  = p.value as? [[String:Any]]{
                    addWorkouts(workouts, toDay: day, CoreDataStackSingleton.shared.trainingDiaryPC, td)
                    
                }else{
                    print("Failed to import workouts for \(dayDict)")
                }
            default:
                print("JSON not added for Key: *\(p.key)* with value: \(p.value)")
            }
        }
        CoreDataStackSingleton.shared.populateMetricPlaceholders(forDay: day as! Day)
    }
    
    fileprivate func addWorkouts(_ workouts: [[String:Any]], toDay day: NSManagedObject, _ persistentContainer: NSPersistentContainer, _ trainingDiary: TrainingDiary) {
        for workoutDict in workouts{
            //we have a workout
            let workout = NSManagedObject.init(entity: NSEntityDescription.entity(forEntityName: ENTITY.Workout.rawValue, in: persistentContainer.viewContext)!, insertInto: persistentContainer.viewContext)
            day.mutableSetValue(forKey: DayProperty.workouts.rawValue).add(workout)
            
            // these need to be set after activity is set
            var finalProperties: [String: Any] = [:]
            
            for wp in workoutDict{
                switch wp.key{
                case WorkoutProperty.activityTypeString.rawValue, WorkoutProperty.equipmentName.rawValue:
                    finalProperties[wp.key] = wp.value
                case WorkoutProperty.activityString.rawValue, WorkoutProperty.ascentMetres.rawValue, WorkoutProperty.cadence.rawValue, WorkoutProperty.hr.rawValue, WorkoutProperty.kj.rawValue, WorkoutProperty.km.rawValue, WorkoutProperty.reps.rawValue, WorkoutProperty.rpe.rawValue, WorkoutProperty.seconds.rawValue, WorkoutProperty.tss.rawValue, WorkoutProperty.tssMethod.rawValue, WorkoutProperty.watts.rawValue, WorkoutProperty.comments.rawValue, WorkoutProperty.keywords.rawValue:
                    if wp.value is NSNull {
                        //     print("\(wp) is nil")
                    }else{
                        workout.setValue(wp.value, forKey: wp.key)
                    }
                case WorkoutProperty.isRace.rawValue, WorkoutProperty.brick.rawValue, WorkoutProperty.wattsEstimated.rawValue:
                    workout.setValue(wp.value, forKey: wp.key)
                default:
                    print("--JSON not added for WORKOUT & Key: \(wp.key) with value: \(wp.value)")
                }
            }
            
            for p in finalProperties{
                if p.value is NSNull {
                     print("\(p) is nil")
                }else{
                    workout.setValue(p.value, forKey: p.key)
                }
            }
            

        }
    }
    
    
    private func addWeights(fromJSON json: [String: Any], toTrainingDiary td: TrainingDiary){
        
        let trainingDiaryWeightDateStrings: [String] = td.weightsArray().map({$0.fromDate!.dateOnlyString()})
        var addedCount: Int = 0
        
        if json.count > 0{
            for mDict in json[TrainingDiaryProperty.weights.rawValue] as! [[String:Any]]{
                if let dateString = mDict[WeightProperty.iso8061DateString.rawValue] as? String{
                    let dateOnly = dateString.split(separator: "T")[0]
                    if trainingDiaryWeightDateStrings.contains(String(dateOnly)){
                        print("TrainingDiary already includes Weight for \(dateOnly)")
                    }else{
                        addWeight(td, mDict)
                        addedCount += 1
                    }
                }else{
                    print("No iso8061DateString value for Weight so can't add \(mDict)")
                }
            }
        }
        print("Added \(addedCount) Weights ")
    }
    
    
    fileprivate func addWeight(_ td: TrainingDiary, _ mDict: [String : Any]) {
        // add this Weight
        // we have a weight record. So create a Weight ManagedObject
        let weight = NSManagedObject.init(entity: NSEntityDescription.entity(forEntityName: ENTITY.Weight.rawValue, in: CoreDataStackSingleton.shared.trainingDiaryPC.viewContext)!, insertInto: CoreDataStackSingleton.shared.trainingDiaryPC.viewContext)
        td.mutableSetValue(forKey: TrainingDiaryProperty.weights.rawValue).add(weight)
        for p in mDict{
            switch p.key{
            case WeightProperty.iso8061DateString.rawValue:
                if let date = ISO8601DateFormatter().date(from: p.value as! String){
                    weight.setValue(date, forKey: WeightProperty.fromDate.rawValue)
                }else{
                    print("failed to import weight from date: \(p.key) : \(p.value)")
                }
            case WeightProperty.kg.rawValue, WeightProperty.fatPercent.rawValue:
                weight.setValue(p.value, forKey: p.key)
            default:
                print("WEIGHT JSON not added for Key: \(p.key) with value: \(p.value)")
            }
        }
    }
    


    private func addPhysiologicals(fromJSON json: [String: Any], toTrainingDiary td: TrainingDiary){
        
        let trainingDiaryPhysiologicalDateStrings: [String] = td.physiologicalArray().map({$0.fromDate!.dateOnlyString()})
        var addedCount: Int = 0
        
        for pDict in json[TrainingDiaryProperty.physiologicals.rawValue] as! [[String:Any]]{
            if let dateString = pDict[PhysiologicalProperty.iso8061DateString.rawValue] as? String{
                let dateOnly = dateString.split(separator: "T")[0]
                if trainingDiaryPhysiologicalDateStrings.contains(String(dateOnly)){
                    print("TrainingDiary already includes Physiological for \(dateOnly)")
                }else{
                    addPhysiological(td, pDict)
                    addedCount += 1
                }
            }else{
                print("No iso8061DateString value for Physiological so can't add \(pDict)")
            }
        }
        print("Added \(addedCount) Physiologicals")
    }
    
    fileprivate func addPhysiological(_ td: TrainingDiary, _ pDict: [String : Any]) {
        // we have a physio record. So create a Physiological ManagedObject
        let physio = NSManagedObject.init(entity: NSEntityDescription.entity(forEntityName: ENTITY.Physiological.rawValue, in: CoreDataStackSingleton.shared.trainingDiaryPC.viewContext)!, insertInto: CoreDataStackSingleton.shared.trainingDiaryPC.viewContext)
        td.mutableSetValue(forKey: TrainingDiaryProperty.physiologicals.rawValue).add(physio)
        for p in pDict{
            switch p.key{
            case PhysiologicalProperty.iso8061DateString.rawValue:
                if let date = ISO8601DateFormatter().date(from: p.value as! String){
                    physio.setValue(date, forKey: PhysiologicalProperty.fromDate.rawValue)
                }else{
                    print("failed to import physio to date: \(p.key) : \(p.value)")
                }
            case PhysiologicalProperty.maxHR.rawValue, PhysiologicalProperty.restingHR.rawValue, PhysiologicalProperty.restingSDNN.rawValue, PhysiologicalProperty.restingRMSSD.rawValue, PhysiologicalProperty.standingHR.rawValue, PhysiologicalProperty.standingSDNN.rawValue, PhysiologicalProperty.standingRMSSD.rawValue:
                if p.value is NSNull {
                    //    print("\(p) is nil")
                }else{
                    physio.setValue(p.value, forKey: p.key)
                }
            default:
                print("PHYSIOLOGICAL JSON not added for Key: \(p.key) with value: \(p.value)")
            }
        }
    }
    


    
    private func addPlans(fromJSON json: [String: Any], toTrainingDiary trainingDiary: TrainingDiary){
        
        let persistentContainer = CoreDataStackSingleton.shared.trainingDiaryPC
        
        let plansMOSet = trainingDiary.mutableSetValue(forKey: TrainingDiaryProperty.plans.rawValue)
        
        //perhaps place this in a singleton.
        let dateFormatter = ISO8601DateFormatter()
        
        let plans = json[TrainingDiaryProperty.plans.rawValue] as! [Any]
        
        for plan in plans{
            // we have a plam record. So create a Plan ManagedObject
            let planMO = NSManagedObject.init(entity: NSEntityDescription.entity(forEntityName: ENTITY.Plan.rawValue, in: persistentContainer.viewContext)!, insertInto: persistentContainer.viewContext)
            plansMOSet.add(planMO)
            
            let basicWeekMOSet = planMO.mutableSetValue(forKey: PlanProperty.basicWeek.rawValue)
            let planDaysMOSet = planMO.mutableSetValue(forKey: PlanProperty.planDays.rawValue)
            
            let pairs = plan as! [String: Any]
            for p in pairs{
                switch p.key{
                case PlanProperty.iso8061FromString.rawValue:
                    if let date = dateFormatter.date(from: p.value as! String){
                        planMO.setValue(date, forKey: PlanProperty.from.rawValue)
                    }else{
                        print("failed to import Plan date: \(p.key) : \(p.value)")
                    }
                case PlanProperty.iso8061ToString.rawValue:
                    if let date = dateFormatter.date(from: p.value as! String){
                        planMO.setValue(date, forKey: PlanProperty.to.rawValue)
                    }else{
                        print("failed to import Plan date: \(p.key) : \(p.value)")
                    }
//                case PlanProperty.iso8061TaperStartString.rawValue:
//                    if let date = dateFormatter.date(from: p.value as! String){
//                        planMO.setValue(date, forKey: PlanProperty.taperStart.rawValue)
//                    }else{
//                        print("failed to import Plan date: \(p.key) : \(p.value)")
//                    }
                case PlanProperty.bikeStartATL.rawValue, PlanProperty.bikeStartCTL.rawValue, PlanProperty.locked.rawValue, PlanProperty.name.rawValue, PlanProperty.runStartATL.rawValue, PlanProperty.runStartCTL.rawValue, PlanProperty.swimStartATL.rawValue, PlanProperty.swimStartCTL.rawValue:
                    planMO.setValue(p.value, forKey: p.key)
                case PlanProperty.basicWeek.rawValue:
                    if let basicWeekDays = p.value as? [Any]{
                        for day in basicWeekDays{
                            //have a basic week day - so create a basic week day
                            let basicWeekDay = NSManagedObject.init(entity: NSEntityDescription.entity(forEntityName: ENTITY.BasicWeekDay.rawValue, in: persistentContainer.viewContext)!, insertInto: persistentContainer.viewContext)
                            basicWeekMOSet.add(basicWeekDay)
                            if let dayDict = day as? [String:Any]{
                                for d in dayDict{
                                    if BasicWeekDayProperty.jsonProperties.map({$0.rawValue}).contains(d.key){
                                        if d.value is NSNull {
                                          //  print("\(d) is nil")
                                        }else{
                                            basicWeekDay.setValue(d.value, forKey: d.key)
                                        }
                                    }else{
                                        print("Not importing \(d) in to \(day)")
                                    }
                                }
                            }
                        }
                    }else{
                        print("Failed to import Basic Week for \(plan)")
                    }
                case PlanProperty.planDays.rawValue:
                    if let planDays = p.value as? [Any]{
                        for day in planDays{
                            // have a plan day to create one
                            let planDay = NSManagedObject.init(entity: NSEntityDescription.entity(forEntityName: ENTITY.PlanDay.rawValue, in: persistentContainer.viewContext)!, insertInto: persistentContainer.viewContext)
                            planDaysMOSet.add(planDay)
                            if let dayDict = day as? [String:Any]{
                                for d in dayDict{
                                    if d.key == PlanDayProperty.iso8061DateString.rawValue{
                                        if let date = ISO8601DateFormatter().date(from: d.value as! String){
                                            planDay.setValue(date, forKey: PlanDayProperty.date.rawValue)
                                        }
                                    }else if PlanDayProperty.jsonProperties.map({$0.rawValue}).contains(d.key){
                                        if d.value is NSNull {
                                     //       print("\(d) is nil")
                                        }else{
                                            planDay.setValue(d.value, forKey: d.key)
                                        }
                                    }else{
                                        print("not importing \(d) in to \(day)")
                                    }
                                }
                            }
                        }
                    }else{
                        print("Failed to import plans days for \(plan)")
                    }
                default:
                    print("PLAN JSON not added for Key: \(p.key) with value: \(p.value)")
                }
            }
        }
    }
    
    
    private func insertYesterdayAndTomorrow(forDays days: [Day]){
        let sortedDays = days.sorted(by: {$0.date! < $1.date!})
        var previousDay: Day?
        for s in sortedDays{
            if let pd = previousDay{
                if s.isYesterday(day: pd){
                    s.yesterday = pd
                }
                if pd.isTomorrow(day: s){
                    pd.tomorrow = s
                }
            }
            previousDay = s
        }
    }
    
    

    
    
}
