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
    
    
    
    //MARK: - possibly private
    
    private func importJSON(fromURL url: URL) -> [String:Any]?{
        
        print("Loading JSON from URL = \(url) ...")
        do{
            let data: Data = try Data.init(contentsOf: url)
            let jsonData  = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
            let jsonDict = jsonData as? [String:Any]
            return jsonDict
        }catch{
            print("error initialising Training Diary for URL: " + url.absoluteString)
            return nil
        }
    }
    
    
    private func addPhysiological(fromJSON json: [String: Any], toTrainingDiary trainingDiary: TrainingDiary){
        
        let persistentContainer = CoreDataStackSingleton.shared.trainingDiaryPC
        
        let physiologicalMOSet = trainingDiary.mutableSetValue(forKey: TrainingDiaryProperty.physiologicals.rawValue)
        
        //perhaps place this in a singleton.
        let dateFormatter = ISO8601DateFormatter()
        
        let physiological = json[TrainingDiaryProperty.physiologicals.rawValue] as! [Any]
        
        for m in physiological{
            // we have a physio record. So create a Physiological ManagedObject
            let physio = NSManagedObject.init(entity: NSEntityDescription.entity(forEntityName: ENTITY.Physiological.rawValue, in: persistentContainer.viewContext)!, insertInto: persistentContainer.viewContext)
            physiologicalMOSet.add(physio)
            let pair = m as! [String: Any]
            for p in pair{
                switch p.key{
                case PhysiologicalProperty.iso8061DateString.rawValue:
                    if let date = dateFormatter.date(from: p.value as! String){
                        physio.setValue(date, forKey: PhysiologicalProperty.fromDate.rawValue)
                    }else{
                        print("failed to import physio to date: \(p.key) : \(p.value)")
                    }
                case PhysiologicalProperty.maxHR.rawValue, PhysiologicalProperty.restingHR.rawValue, PhysiologicalProperty.restingSDNN.rawValue, PhysiologicalProperty.restingRMSSD.rawValue, PhysiologicalProperty.standingHR.rawValue, PhysiologicalProperty.standingSDNN.rawValue, PhysiologicalProperty.standingRMSSD.rawValue:
                    if p.value is NSNull {
                        print("\(p) is nil")
                    }else{
                        physio.setValue(p.value, forKey: p.key)
                    }
                default:
                    print("PHYSIOLOGICAL JSON not added for Key: \(p.key) with value: \(p.value)")
                }
            }
        }
    }
    
    private func addWeight(fromJSON json: [String: Any], toTrainingDiary trainingDiary: TrainingDiary){
        
        let persistentContainer = CoreDataStackSingleton.shared.trainingDiaryPC
        
        let weightMOSet = trainingDiary.mutableSetValue(forKey: TrainingDiaryProperty.weights.rawValue)
        
        //perhaps place this in a singleton.
        let dateFormatter = ISO8601DateFormatter()
        
        let measurements = json[TrainingDiaryProperty.weights.rawValue] as! [Any]
        
        for m in measurements{
            // we have a weight record. So create a Weight ManagedObject
            let weight = NSManagedObject.init(entity: NSEntityDescription.entity(forEntityName: ENTITY.Weight.rawValue, in: persistentContainer.viewContext)!, insertInto: persistentContainer.viewContext)
            weightMOSet.add(weight)
            let pair = m as! [String: Any]
            for p in pair{
                switch p.key{
                case WeightProperty.iso8061DateString.rawValue:
                    if let date = dateFormatter.date(from: p.value as! String){
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
    }
    
    fileprivate func addWorkouts(_ workoutsItems: [Any], _ persistentContainer: NSPersistentContainer, _ workoutsMOSet: NSMutableSet, _ trainingDiary: TrainingDiary) {
        for w in workoutsItems{
            //we have a workout
            let workout = NSManagedObject.init(entity: NSEntityDescription.entity(forEntityName: ENTITY.Workout.rawValue, in: persistentContainer.viewContext)!, insertInto: persistentContainer.viewContext)
            workoutsMOSet.add(workout)
            let workoutItems = w as! [String: Any]
            for wp in workoutItems{
                switch wp.key{
                case WorkoutProperty.activityString.rawValue, WorkoutProperty.activityTypeString.rawValue, WorkoutProperty.ascentMetres.rawValue, WorkoutProperty.equipmentName.rawValue, WorkoutProperty.cadence.rawValue, WorkoutProperty.hr.rawValue, WorkoutProperty.kj.rawValue, WorkoutProperty.km.rawValue, WorkoutProperty.reps.rawValue, WorkoutProperty.rpe.rawValue, WorkoutProperty.seconds.rawValue, WorkoutProperty.tss.rawValue, WorkoutProperty.tssMethod.rawValue, WorkoutProperty.watts.rawValue, WorkoutProperty.comments.rawValue, WorkoutProperty.keywords.rawValue:
                    if wp.value is NSNull {
                        print("\(wp) is nil")
                    }else{
                        workout.setValue(wp.value, forKey: wp.key)
                    }
                case WorkoutProperty.isRace.rawValue, WorkoutProperty.brick.rawValue, WorkoutProperty.wattsEstimated.rawValue:
                    workout.setValue(wp.value, forKey: wp.key)
                default:
                    print("--JSON not added for WORKOUT & Key: \(wp.key) with value: \(wp.value)")
                }
            }
            //need to set up Activity Properties etc..
            if let wkt = workout as? Workout{
                if let a = wkt.activityString{
                    let activity = trainingDiary.addActivity(forString: a)
                    wkt.activity = activity
                    if let at = wkt.activityTypeString{
                        let activityType = trainingDiary.addActivityType(forActivity: a, andType: at)
                        wkt.activityType = activityType
                    }
                    if let e = wkt.equipmentName{
                        let equipment = trainingDiary.addEquipment(forActivity: a, andName: e)
                        wkt.equipment = equipment
                    }
                }
            }
        }
    }
    
    private func addDaysAndWorkouts(fromJSON json: [String: Any], toTrainingDiary trainingDiary: TrainingDiary){
        
        let persistentContainer = CoreDataStackSingleton.shared.trainingDiaryPC
        
        let daysMOSet = trainingDiary.mutableSetValue(forKey: TrainingDiaryProperty.days.rawValue)
        
        let dateFormatter = ISO8601DateFormatter()
        
        if let days = json[TrainingDiaryProperty.days.rawValue] as? [ Any]{
            for d in days{
                // we have a day. So create a Day ManagedObject
                let day = NSManagedObject.init(entity: NSEntityDescription.entity(forEntityName: ENTITY.Day.rawValue, in: persistentContainer.viewContext)!, insertInto: persistentContainer.viewContext)
                
                daysMOSet.add(day)
                let workoutsMOSet = day.mutableSetValue(forKey: DayProperty.workouts.rawValue)
                let pairs = d as! [String: Any]
                for p in pairs{
                    switch p.key{
                    case DayProperty.iso8061DateString.rawValue:
                        if let d = dateFormatter.date(from: p.value as! String){
                            day.setValue(d, forKey: DayProperty.date.rawValue)
                        }else{
                            print("Unable to format date from \(p.value)")
                        }
                    case DayProperty.sleep.rawValue, DayProperty.sleepQuality.rawValue, DayProperty.type.rawValue, DayProperty.motivation.rawValue, DayProperty.fatigue.rawValue:
                        day.setValue(p.value, forKey: p.key)
                    case DayProperty.comments.rawValue:
                        if p.value is NSNull {
                            print("\(p) is nil")
                        }else{
                            day.setValue(p.value, forKey: p.key)
                        }
                    case DayProperty.workouts.rawValue:
                        if let workoutsItems  = p.value as? [Any]{
                            addWorkouts(workoutsItems, persistentContainer, workoutsMOSet, trainingDiary)

                        }else{
                            print("Failed to import workouts for \(d)")
                        }
                    default:
                        print("JSON not added for Key: *\(p.key)* with value: \(p.value)")
                    }
                }
                CoreDataStackSingleton.shared.populateMetricPlaceholders(forDay: day as! Day)
            }
            let addedDays: [Day] = daysMOSet.allObjects as! [Day]
            insertYesterdayAndTomorrow(forDays: addedDays)
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
                case PlanProperty.iso8061TaperStartString.rawValue:
                    if let date = dateFormatter.date(from: p.value as! String){
                        planMO.setValue(date, forKey: PlanProperty.taperStart.rawValue)
                    }else{
                        print("failed to import Plan date: \(p.key) : \(p.value)")
                    }
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
    
    
    private func add(_ json: [String: Any], toTrainingDiary td: TrainingDiary){
    
        addDaysAndWorkouts(fromJSON: json, toTrainingDiary: td)
        addWeight(fromJSON: json, toTrainingDiary: td)
        addPhysiological(fromJSON: json, toTrainingDiary: td)
        addPlans(fromJSON: json, toTrainingDiary: td)
        
        for e in CoreDataStackSingleton.shared.getEntityCounts(forDiary: td){
            print("\(e.entity) = \(e.count)")
        }
    }
    
    
}
