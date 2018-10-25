//
//  ValidationViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 30/07/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class ValidationViewController: TrainingDiaryViewController{
   
    
    @IBOutlet var validationOutputTextView: NSTextView!
    

    //MARK: - IBActions
    @IBAction func adhoc(_ sender: Any) {
        
        if let service = NSSharingService(named: NSSharingService.Name.composeEmail){
            service.recipients = ["stevenlord@me.com"]
            service.subject = "Test"
            service.perform(withItems: ["Items","another"])
        }
        
    }
    
    
    @IBAction func duplicateDays(_ sender: Any) {
        
        logMessage("DUPLICATE DAYS:")
        
        var days: [Date] = []
        var duplicates: [Day] = []
        if let td = trainingDiary{
            if let ds = td.days?.allObjects as? [Day]{
                for d in ds{
                    if days.contains(d.date!.startOfDay()){
                        //duplicate
                        duplicates.append(d)
                        logMessage("\(d.date!) is a duplicate")
                    }else{
                        days.append(d.date!.startOfDay())
                    }
                }
            }
        }
        
        logMessage("Duplicated count = \(duplicates.count)")
        logMessage("---------------------------------------------------------------------")
        
    }
    
    
    @IBAction func missingDays(_ sender: Any) {
    }
    
    
    
    @IBAction func uniqueActivities(_ sender: Any){
        logMessage("*** Unique Activities:")
        let results = trainingDiary!.uniqueActivityTypePairs()
        for r in results{
            logMessage(r)
        }
    }
    

    
    
    @IBAction func printEntityCounts(_ sender: Any) {
        logMessage("*** Entity Counts:")
        for e in CoreDataStackSingleton.shared.getEntityCounts(forDiary: trainingDiary!){
            logMessage("\(e.entity) = \(e.count)")
        }
    }
    
    @IBAction func connectActivities(_ sender: Any){
        // connects up activity objects in to workouts
        logMessage("shouldn't need to connect activities now")
//        var activiesConnected: Int = 0
//        var activityTypesConnected: Int = 0
//
//        for w in trainingDiary!.workouts{
//            if w.activity == nil{
//                if let td = trainingDiary{
//                    if let a = w.activityString{
//                        w.activity = td.activity(forString: a)
//                        logMessage("Connected activity  for workout \(String(describing: w.day!.date?.dateOnlyShorterString()))")
//                        activiesConnected += 1
//                    }
//                }
//            }
//            if w.activityType == nil{
//                w.activityType = trainingDiary!.activityType(forActivity: w.activityString!, andType: w.activityTypeString!)
//                logMessage("Connected activity type for workout \(String(describing: w.day!.date?.dateOnlyShorterString()))")
//                activityTypesConnected += 1
//            }
//        }
//
//        logMessage("*** Connecting Activities:")
//        logMessage("\(activiesConnected) workouts connected to activity")
//        logMessage("\(activityTypesConnected) workouts connected to activity type")
//        logMessage("---------------------------------------------------------------------")
        
    }
    
    @IBAction func listMissingConnections(_ sender: Any){
        var missingActivity: Int = 0
        var missingActivityType: Int = 0
        var missingDaySet: Int = 0
        var missingTrainingDiarySet: Int = 0
        
        let days: [Day] = CoreDataStackSingleton.shared.getAllEntities(ofType: ENTITY.Day) as! [Day]
        let workouts: [Workout] = CoreDataStackSingleton.shared.getAllEntities(ofType: ENTITY.Workout) as! [Workout]
        
        for d in days{
            if d.trainingDiary == nil{
                missingTrainingDiarySet += 1
                logMessage("Training diary nil for day \(d.date!.dateOnlyShorterString()).")
            }
        }
        
        for w in workouts{
            if w.day == nil{
                missingDaySet += 1
                logMessage("day nil for workout \(String(describing: w.activityString)):\(String(describing: w.activityTypeString)) ")
                
            }else{
                
                if w.activity == nil{
                    missingActivity += 1
                    logMessage("activity nil for workout \(String(describing: w.activityString)) - \(w.day!.date!.dateOnlyShorterString())")
                }
                if w.activityType == nil{
                    missingActivityType += 1
                    logMessage("activityType nil for workout \(String(describing: w.activityTypeString)) - \(w.day!.date!.dateOnlyShorterString())")
                }
     //           if w.activityString == nil{
       //             logMessage("Workout is missing activity string \(w.day!.date!.dateOnlyShorterString())")
         //       }
           //     if w.activityTypeString == nil{
             //       logMessage("Workout is missing activity string \(w.day!.date!.dateOnlyShorterString())")
               // }
            }
        }
        
        let ltd = CoreDataStackSingleton.shared.ltdEdNumsMissingParentAndTrainingDiary()
        for l in ltd{
            logMessage("Missing parent and trainingDiary: \(l.code)")
        }
        
        logMessage("*** Missing Connections:")
        logMessage("Workouts missing activity: \(missingActivity)")
        logMessage("Workouts missing activity type: \(missingActivityType)")
        logMessage("Workouts missing day: \(missingDaySet)")
        logMessage("Days missing training diary: \(missingTrainingDiarySet)")
        logMessage("LTDEddingtonNumber without parent or training diary: \(ltd.count)")
        logMessage("---------------------------------------------------------------------")
        
        
    }
    
    @IBAction func deleleteEntitiesWithMissingConnections(_ sender: Any){
        var missingDaySet: Int = 0
        var missingTrainingDiarySet: Int = 0
        
        let days: [Day] = CoreDataStackSingleton.shared.getAllEntities(ofType: ENTITY.Day) as! [Day]
        let workouts: [Workout] = CoreDataStackSingleton.shared.getAllEntities(ofType: ENTITY.Workout) as! [Workout]
        
        for d in days{
            if d.trainingDiary == nil{
                missingTrainingDiarySet += 1
                logMessage("Training diary nil for day \(d.date!.dateOnlyShorterString()). Removing...")
                CoreDataStackSingleton.shared.delete(entity: d)
                logMessage("DONE")
            }
        }
        
        for w in workouts{
            if w.day == nil{
                missingDaySet += 1
                logMessage("day nil for workout \(String(describing: w.activityString)):\(String(describing: w.activityTypeString)) ... ")
                CoreDataStackSingleton.shared.delete(entity: w)
                logMessage("DONE")
                
            }
        }
        
        let ltd = CoreDataStackSingleton.shared.ltdEdNumsMissingParentAndTrainingDiary()
        for l in ltd{
            CoreDataStackSingleton.shared.delete(entity: l)
            logMessage("Deleting LTDEddingtonNumber: \(l.code)")
        }
    }
    
    @IBAction func printUniqueBikeNames(_ sender: Any){
        var i: Int = 0
        if let td = trainingDiary{
            for bike in td.uniqueBikeNames(){
                logMessage(bike)
            }
            for w in td.workouts{
                if w.activity?.name == FixedActivity.Bike.rawValue{
                    if w.equipment == nil{
                        logMessage("Equipment not set for bike workout \(String(describing: w.day?.date?.dateOnlyShorterString()))")
                        i += 1
                    }
//                    if w.equipmentName == nil{
//                        logMessage("setting equipment name for \(String(describing: w.day?.date?.dateOnlyShorterString())) to...")
//                        if let e = w.equipment{
//                            w.equipmentName = e.name
//                            logMessage(w.equipmentName!)
//                        }else{
//                            logMessage("FAILED TO SET")
//                        }
//                        
//                    }
                }
            }
        }
        logMessage("\(i) workouts missing equipment (ie bike) set")
        logMessage("*** Unique Bike Names and Missing Equipment")
        logMessage("")
        
    }
    
    
    private func logMessage(_ s: String){
        print(s)
        
        if let votv = validationOutputTextView{
            //            let oldString = votv.string
            votv.string += "\n" + s
        }
        
    }

}
