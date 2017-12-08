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
            createManagedObjectModelFrom(json: json)
        }
    }
    
    public func merge(fromURL url: URL, intoDiary td: TrainingDiary){
        if let json = importJSON(fromURL: url){
            addDaysAndWorkouts(fromJSON: json, toTrainingDiary: td)
            addWeight(fromJSON: json, toTrainingDiary: td)
            addPhysiological(fromJSON: json, toTrainingDiary: td)
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
    
    
    private func addPhysiological(fromJSON json: [String: Any], toTrainingDiary trainingDiary: NSManagedObject){
        
        let persistentContainer = CoreDataStackSingleton.shared.trainingDiaryPC
        
        let physiologicalMOSet = trainingDiary.mutableSetValue(forKey: TrainingDiaryProperty.physiologicals.rawValue)
        
        //perhaps place this in a singleton.
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone.init(secondsFromGMT: 0)
        
        let physiological = json[FPMJSONString.Physiological.fmpString()] as! [String: Any]
        let measurements = physiological[FPMJSONString.Measurement.fmpString()] as! [Any]
        
        for m in measurements{
            // we have a weight record. So create a Weight ManagedObject
            let physio = NSManagedObject.init(entity: NSEntityDescription.entity(forEntityName: ENTITY.Physiological.rawValue, in: persistentContainer.viewContext)!, insertInto: persistentContainer.viewContext)
            physiologicalMOSet.add(physio)
            let pair = m as! [String: Any]
            for p in pair{
                switch p.key{
                case PhysiologicalProperty.fromDate.fmpString():
                    if let date = dateFormatter.date(from: p.value as! String){
                        physio.setValue(date.startOfDay(), forKey: PhysiologicalProperty.fromDate.rawValue)
                    }else{
                        print("failed to import physio to date: \(p.key) : \(p.value)")
                    }
                case PhysiologicalProperty.toDate.fmpString():
                    if let date = dateFormatter.date(from: p.value as! String){
                        physio.setValue(date.endOfDay(), forKey: PhysiologicalProperty.toDate.rawValue)
                    }else{
                        print("failed to import physio from date: \(p.key) : \(p.value)")
                    }
                case PhysiologicalProperty.maxHR.fmpString():
                    physio.setValue(p.value, forKey: PhysiologicalProperty.maxHR.rawValue)
                case PhysiologicalProperty.restingHR.fmpString():
                    physio.setValue(p.value, forKey: PhysiologicalProperty.restingHR.rawValue)
                case PhysiologicalProperty.restingSDNN.fmpString():
                    physio.setValue(p.value, forKey: PhysiologicalProperty.restingSDNN.rawValue)
                case PhysiologicalProperty.restingRMSSD.fmpString():
                    physio.setValue(p.value, forKey: PhysiologicalProperty.restingRMSSD.rawValue)
                case PhysiologicalProperty.standingHR.fmpString():
                    physio.setValue(p.value, forKey: PhysiologicalProperty.standingHR.rawValue)
                case PhysiologicalProperty.standingSDNN.fmpString():
                    physio.setValue(p.value, forKey: PhysiologicalProperty.standingSDNN.rawValue)
                case PhysiologicalProperty.standingRMSSD.fmpString():
                    physio.setValue(p.value, forKey: PhysiologicalProperty.standingRMSSD.rawValue)
                default:
                    if p.key == FPMJSONString.Created.rawValue{
                        //do nothing as intentionally not importing this
                    }else{
                        //       print("PHYSIOLOGICAL JSON not added for Key: \(p.key) with value: \(p.value)")
                    }
                }
            }
        }
    }
    
    private func addWeight(fromJSON json: [String: Any], toTrainingDiary trainingDiary: NSManagedObject){
        
        let persistentContainer = CoreDataStackSingleton.shared.trainingDiaryPC
        
        let weightMOSet = trainingDiary.mutableSetValue(forKey: "weights")
        
        //perhaps place this in a singleton.
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone.init(secondsFromGMT: 0)
        
        let weights = json[FPMJSONString.Weight.fmpString()] as! [String: Any]
        let measurements = weights[FPMJSONString.Measurement.fmpString()] as! [Any]
        
        for m in measurements{
            // we have a weight record. So create a Weight ManagedObject
            let weight = NSManagedObject.init(entity: NSEntityDescription.entity(forEntityName: ENTITY.Weight.rawValue, in: persistentContainer.viewContext)!, insertInto: persistentContainer.viewContext)
            weightMOSet.add(weight)
            let pair = m as! [String: Any]
            for p in pair{
                switch p.key{
                case WeightProperty.fromDate.fmpString():
                    if let date = dateFormatter.date(from: p.value as! String){
                        weight.setValue(date.startOfDay() , forKey: WeightProperty.fromDate.rawValue)
                    }else{
                        print("failed to import weight from date: \(p.key) : \(p.value)")
                    }
                case WeightProperty.toDate.fmpString():
                    if let date = dateFormatter.date(from: p.value as! String){
                        weight.setValue(date.endOfDay(), forKey: WeightProperty.toDate.rawValue)
                    }else{
                        print("failed to import weight to date: \(p.key) : \(p.value)")
                    }
                case WeightProperty.kg.fmpString():
                    weight.setValue(p.value, forKey: WeightProperty.kg.rawValue)
                case WeightProperty.fatPercent.fmpString():
                    weight.setValue(p.value, forKey: WeightProperty.fatPercent.rawValue)
                default:
                    if p.key == FPMJSONString.Created.fmpString(){
                        // do notihng - intentionally not importing this key
                    }else{
                        //     print("WEIGHT JSON not added for Key: \(p.key) with value: \(p.value)")
                    }
                }
            }
        }
    }
    
    private func addDaysAndWorkouts(fromJSON json: [String: Any], toTrainingDiary trainingDiary: NSManagedObject){
        
        let persistentContainer = CoreDataStackSingleton.shared.trainingDiaryPC
        
        let daysMOSet = trainingDiary.mutableSetValue(forKey: TrainingDiaryProperty.days.rawValue)
        
        //perhaps place this in a singleton.
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone.init(secondsFromGMT: 0)
        
        let dayDictionary = json[TrainingDiaryProperty.days.fmpString()] as! [String: Any]
        let days = dayDictionary[FPMJSONString.Day.fmpString()] as! [ Any]
        
        for d in days{
            // we have a day. So create a Day ManagedObject
            let day = NSManagedObject.init(entity: NSEntityDescription.entity(forEntityName: ENTITY.Day.rawValue, in: persistentContainer.viewContext)!, insertInto: persistentContainer.viewContext)
            daysMOSet.add(day)
            let workoutsMOSet = day.mutableSetValue(forKey: DayProperty.workouts.rawValue)
            let pairs = d as! [String: Any]
            for p in pairs{
                switch p.key{
                case DayProperty.date.fmpString():
                    day.setValue(dateFormatter.date(from: p.value as! String), forKey: DayProperty.date.rawValue)
                case DayProperty.sleep.fmpString():
                    day.setValue(p.value, forKey: DayProperty.sleep.rawValue)
                case DayProperty.sleepQuality.fmpString():
                    day.setValue(p.value, forKey: DayProperty.sleepQuality.rawValue)
                case DayProperty.type.fmpString():
                    day.setValue(p.value, forKey: DayProperty.type.rawValue)
                case DayProperty.motivation.fmpString():
                    day.setValue(p.value, forKey: DayProperty.motivation.rawValue)
                case DayProperty.fatigue.fmpString():
                    day.setValue(p.value, forKey: DayProperty.fatigue.rawValue)
                case DayProperty.comments.fmpString():
                    day.setValue(p.value, forKey: DayProperty.comments.rawValue)
                case DayProperty.workouts.fmpString():
                    let workoutsItems  = p.value as! [String : Any]
                    let workouts = workoutsItems[FPMJSONString.Workout.rawValue] as! [Any]
                    for w in workouts{
                        //we have a workout
                        let workout = NSManagedObject.init(entity: NSEntityDescription.entity(forEntityName: ENTITY.Workout.rawValue, in: persistentContainer.viewContext)!, insertInto: persistentContainer.viewContext)
                        workoutsMOSet.add(workout)
                        let workoutItems = w as! [String: Any]
                        for wp in workoutItems{
                            switch wp.key{
                            case WorkoutProperty.activity.fmpString():
                                workout.setValue(wp.value, forKey: WorkoutProperty.activity.rawValue)
                            case WorkoutProperty.activityType.fmpString():
                                //need to remove whites spaces. In FPM JSON we get 'Open Water' and 'Off Road'
                                if let stringValue = wp.value as? String{
                                    workout.setValue(stringValue.removeWhitespaces(), forKey: WorkoutProperty.activityType.rawValue)
                                }else{
                                    workout.setValue(wp.value, forKey: WorkoutProperty.activityType.rawValue)
                                }
                            case WorkoutProperty.ascentMetres.fmpString():
                                workout.setValue(wp.value, forKey: WorkoutProperty.ascentMetres.rawValue)
                            case WorkoutProperty.bike.fmpString():
                                workout.setValue(wp.value as! String, forKey: WorkoutProperty.bike.rawValue)
                            case WorkoutProperty.isRace.fmpString():
                                if let isRace = wp.value as? String{
                                    if isRace == "1" || isRace.uppercased() == "YES" || isRace.uppercased() == "Y"{
                                        workout.setValue(true, forKey: WorkoutProperty.isRace.rawValue)
                                    }else{
                                        workout.setValue(false, forKey: WorkoutProperty.isRace.rawValue)
                                    }
                                }else{
                                    print("could not set isRace: \(wp.value)")
                                }
                            case WorkoutProperty.brick.fmpString():
                                if let brick = wp.value as? String{
                                    if brick == "1" || brick.uppercased() == "YES" || brick.uppercased() == "Y"{
                                        workout.setValue(true, forKey: WorkoutProperty.brick.rawValue)
                                    }else{
                                        workout.setValue(false, forKey: WorkoutProperty.brick.rawValue)
                                    }
                                }else{
                                    print("could not set Brick: \(wp.value)")
                                }
                            case WorkoutProperty.cadence.fmpString():
                                workout.setValue(wp.value, forKey: WorkoutProperty.cadence.rawValue)
                            case WorkoutProperty.comments.fmpString():
                                workout.setValue(wp.value as! String, forKey: WorkoutProperty.comments.rawValue)
                            case WorkoutProperty.hr.fmpString():
                                workout.setValue(wp.value, forKey: WorkoutProperty.hr.rawValue)
                            case WorkoutProperty.keywords.fmpString():
                                workout.setValue(wp.value as! String, forKey: WorkoutProperty.keywords.rawValue)
                            case WorkoutProperty.kj.fmpString():
                                workout.setValue(wp.value, forKey: WorkoutProperty.kj.rawValue)
                            case WorkoutProperty.km.fmpString():
                                workout.setValue(wp.value, forKey: WorkoutProperty.km.rawValue)
                            case WorkoutProperty.reps.fmpString():
                                workout.setValue(wp.value, forKey: WorkoutProperty.reps.rawValue)
                            case WorkoutProperty.rpe.fmpString():
                                workout.setValue(wp.value, forKey: WorkoutProperty.rpe.rawValue)
                            case WorkoutProperty.seconds.fmpString():
                                workout.setValue(wp.value, forKey: WorkoutProperty.seconds.rawValue)
                            case WorkoutProperty.tss.fmpString():
                                workout.setValue(wp.value, forKey: WorkoutProperty.tss.rawValue)
                            case WorkoutProperty.tssMethod.fmpString():
                                workout.setValue(wp.value, forKey: WorkoutProperty.tssMethod.rawValue)
                            case WorkoutProperty.watts.fmpString():
                                workout.setValue(wp.value, forKey: WorkoutProperty.watts.rawValue)
                            case WorkoutProperty.wattsEstimated.fmpString():
                                if let estimate = wp.value as? String{
                                    if estimate == "1" || estimate.uppercased() == "YES" || estimate.uppercased() == "Y"{
                                        workout.setValue(true, forKey: WorkoutProperty.wattsEstimated.rawValue)
                                    }else{
                                        workout.setValue(false, forKey: WorkoutProperty.wattsEstimated.rawValue)
                                    }
                                }else{
                                    print("could not set Brick: \(wp.value)")
                                }
                            default:
                                if wp.key == FPMJSONString.Date.fmpString(){
                                    //we're ok. Don't need to import date. In DB model this is used for a relationship
                                    // in this model the workout is a member of the Day - so date implied
                                }else{
                                    //    print("--JSON not added for WORKOUT & Key: \(wp.key) with value: \(wp.value)")
                                }
                            }
                        }
                    }
                default:
                    if !(p.key == FPMJSONString.Created.fmpString()){
                        // we're not importing created.
                        print("JSON not added for Key: *\(p.key)* with value: \(p.value)")
                    }
                }
            }
        }
        let addedDays: [Day] = daysMOSet.allObjects as! [Day]
        insertYesterdayAndTomorrow(forDays: addedDays)
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
    
    private func createManagedObjectModelFrom(json: [String: Any]){
        //create the base Object - TrainingDiary
        let trainingDiary: NSManagedObject = NSEntityDescription.insertNewObject(forEntityName: "TrainingDiary", into: CoreDataStackSingleton.shared.trainingDiaryPC.viewContext)
        
        trainingDiary.setValue(json["Created"], forKey: "name")
        
        print("Adding days and workouts to managed object model...")
        addDaysAndWorkouts(fromJSON: json, toTrainingDiary: trainingDiary)
        print("days and workouts added")
        print("Adding weights to managed object model...")
        addWeight(fromJSON: json, toTrainingDiary: trainingDiary)
        print("weights added")
        print("Adding physiologicals to managed object model...")
        addPhysiological(fromJSON: json, toTrainingDiary: trainingDiary)
        print("physiologicals added")
        //     printEntities()
        print("Added:")
        CoreDataStackSingleton.shared.printEntityCounts(forDiary: trainingDiary as! TrainingDiary)
        
    }
    
    
}
