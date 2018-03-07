//
//  DefaultsViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 06/02/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class DefaultsViewController: TrainingDiaryViewController, NSComboBoxDataSource {

//    @objc dynamic var trainingDiary: TrainingDiary?
    var mainViewController: ViewController?
    
    @IBOutlet var validationOutputTextView: NSTextView!
    
    //MARK: - IBActions
    @IBAction func adhoc(_ sender: Any) {        
    }
    

    @IBAction func duplicateDays(_ sender: Any) {
    }
    
    
    @IBAction func missingDays(_ sender: Any) {
    }
    
    
    
    @IBAction func uniqueActivities(_ sender: Any){
        let results = trainingDiary!.uniqueActivityTypePairs()
        for r in results{
            logMessage(r)
        }
        logMessage("*** Unique Activities:")
        logMessage("")
    }
    
    @IBAction func recalcMonotonyAndStrain(_ sender: Any) {
        let start = Date()
        DispatchQueue.global(qos: .userInitiated).async {

            if let td = self.trainingDiary{
                let count: Double = Double(td.activitiesArray().count)
                var i: Double = 0.0
                for a in td.activitiesArray(){
                    i += 1.0
                    DispatchQueue.main.sync {
                        self.mainViewController!.mainStatusField!.stringValue = "Calculating monotony & strain:  \(String(describing: a.name)) - \(Int(Date().timeIntervalSince(start)))s ..."
                        self.mainViewController!.mainProgressBar!.doubleValue = i * 100 / count
                    }
                    td.calculateMonotonyAndStrain(forActivity: a)
                }
            }
            DispatchQueue.main.sync {
                self.mainViewController!.mainStatusField!.stringValue = "Monotony and Strain Calculation took \(Date().timeIntervalSince(start))s"
            }
        }
        logMessage("Monotony and Strain Calculation took \(Date().timeIntervalSince(start))s")
    }
    
    @IBAction func recalcTSB(_ sender: Any) {
        DispatchQueue.global(qos: .userInitiated).async {
            
            let start = Date()
            let numberOfActivities = Double(self.trainingDiary!.activitiesArray().count)
            var i = 0.0
            
            DispatchQueue.main.async {
                if let mvc = self.mainViewController{
                    mvc.mainProgressBar!.doubleValue = 0.0
                    mvc.mainStatusField!.stringValue = "Starting TSB calc..."
                }
            }
            
            for a in self.trainingDiary!.activitiesArray(){
                
                let s = Date()
                self.trainingDiary!.calcTSB(forActivity: a, fromDate: self.trainingDiary!.firstDayOfDiary)
                
                DispatchQueue.main.async {
                    i += 1.0
                    if let mvc = self.mainViewController{
                        mvc.mainStatusField!.stringValue = "\(a.name!) TSB calculated in \(Int(Date().timeIntervalSince(s)))s"
                        mvc.mainProgressBar!.doubleValue = i * 100.0 / numberOfActivities
                    }
                }
            }
            
            DispatchQueue.main.async {
                if let mvc = self.mainViewController{
                    mvc.mainStatusField.stringValue = "TSB Calc completed in \(Int(Date().timeIntervalSince(start)))s"
                }
            }
            
        }
    }
    @IBAction func printEntityCounts(_ sender: Any) {
        for e in CoreDataStackSingleton.shared.getEntityCounts(forDiary: trainingDiary!){
            logMessage("\(e.entity) = \(e.count)")
        }
        logMessage("*** Entity Counts:")
        logMessage("")
    }
    
    @IBAction func connectActivities(_ sender: Any){
        // connects up activity objects in to workouts
        
        var activiesConnected: Int = 0
        var activityTypesConnected: Int = 0
        
        for w in trainingDiary!.workouts{
            if w.activity == nil{
                if let td = trainingDiary{
                    if let a = w.activityString{
                        w.activity = td.activity(forString: a)
                        logMessage("Connected activity  for workout \(String(describing: w.day!.date?.dateOnlyShorterString()))")
                        activiesConnected += 1
                    }
                }
            }
            if w.activityType == nil{
                w.activityType = trainingDiary!.activityType(forActivity: w.activityString!, andType: w.activityTypeString!)
                logMessage("Connected activity type for workout \(String(describing: w.day!.date?.dateOnlyShorterString()))")
                activityTypesConnected += 1
            }
        }
        
        logMessage("\(activiesConnected) workouts connected to activity")
        logMessage("\(activityTypesConnected) workouts connected to activity type")
        logMessage("*** Connecting Activities:")
        logMessage("")

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
                    logMessage("activity nil for workout \(String(describing: w.activityTypeString)) - \(w.day!.date!.dateOnlyShorterString())")
                }
                if w.activityString == nil{
                    logMessage("Workout is missing activity string \(w.day!.date!.dateOnlyShorterString())")
                }
                if w.activityTypeString == nil{
                    logMessage("Workout is missing activity string \(w.day!.date!.dateOnlyShorterString())")
                }
            }
        }
        
        let ltd = CoreDataStackSingleton.shared.ltdEdNumsMissingParentAndTrainingDiary()
        for l in ltd{
            logMessage("Missing parent and trainingDiary: \(l.code)")
        }
        
        logMessage("Workouts missing activity: \(missingActivity)")
        logMessage("Workouts missing activity type: \(missingActivityType)")
        logMessage("Workouts missing day: \(missingDaySet)")
        logMessage("Days missing training diary: \(missingTrainingDiarySet)")
        logMessage("LTDEddingtonNumber without parent or training diary: \(ltd.count)")
        logMessage("*** Missing Connections:")
        logMessage("")


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
                    if w.equipmentName == nil{
                        logMessage("setting equipment name for \(String(describing: w.day?.date?.dateOnlyShorterString())) to...")
                        if let e = w.equipment{
                            w.equipmentName = e.name
                            logMessage(w.equipmentName!)
                        }else{
                            logMessage("FAILED TO SET")
                        }
                        
                    }
                }
            }
        }
        logMessage("\(i) workouts missing equipment (ie bike) set")
        logMessage("*** Unique Bike Names and Missing Equipment")
        logMessage("")

    }
    

    

    
    //MARK: - NSComboBoxDataSource implementation  TSBTableActivityCB
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        if let identifier = comboBox.identifier{
            switch identifier.rawValue{
                
            case "TSBTableActivityCB":
                let activities = trainingDiary!.activitiesArray().map({$0.name})
                if index < activities.count{
                    return activities[index]
                }
            default:
                print("What combo box is this \(identifier.rawValue) which I'm (AdminViewController) a data source for? ")
            }
        }
        return nil
    }
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        if let identifier = comboBox.identifier{
            switch identifier.rawValue{
            case "TSBTableActivityCB":
                return trainingDiary!.activitiesArray().count
            default:
                return 0
            }
        }
        return 0
    }
    
   
    private func logMessage(_ s: String){
        print(s)
        
        if let votv = validationOutputTextView{
            let oldString = votv.string
            votv.string = s + "\n" + oldString
        }
    
        
    }

    
    
}
