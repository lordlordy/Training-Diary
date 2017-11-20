//
//  BaseDataViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 31/10/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Cocoa

class BaseDataViewController: NSViewController {

//    @objc dynamic var managedObjectContext: NSManagedObjectContext?
    @objc dynamic var trainingDiary: TrainingDiary?

    @IBOutlet var baseDataArrayController: NSArrayController!
    
    
    private var activity: String?
    private var activityType: String?
    private var period: String?
    private var unit: String?
    private var year: Int?
    private var activitiesToRebuild: [Activity]? = []
    private var activityTypesToRebuild: [ActivityType]? = []
    private var unitsToRebuild: [Unit]? = []
    private var periodsToRebuild: [Period]? = []
    
    @IBAction func createBaseDataNoSave(_ sender: NSButton){
        BaseDataCalculator.shared.createBaseDataNoCoreDataSave(forTrainingDiary: trainingDiary!)
    }

    
    @IBAction func rebuildBaseData(_ sender: Any) {
        let start = Date()
        CoreDataStackSingleton.shared.createBaseData(forTrainingDiary: trainingDiary!)
        print(" base data elements created in \(Date().timeIntervalSince(start)) seconds")
        CoreDataStackSingleton.shared.save()
    }
    
    @IBAction func prototypeBaseDataCreationMethod2(_ sender: NSButton){
        BaseDataCalculator.shared.createBaseDataDayFirst(forTrainingDiary: trainingDiary!)
    }

    @IBAction func prototypeBaseDataCreation(_ sender: NSButton){
        BaseDataCalculator.shared.createBaseData(forTrainingDiary: trainingDiary!)
    }
    
    /* this rebuilds for the selected activity, activityType, period and unit (per vars above)
     Rules:
     array - nil - do them all. For activityType and Unit this means asking the activity for the values
     array - empty - run through as normal but if any array is empty then nothing will happen as we
     won't enter the for loop
     array - present - do that. The only way it will be present is with a single entry! This could change in the future if I improve the GUI to allow the user to select the items to include
     REFACTOR - all this should be moved to a model class.
     */
     @IBAction func rebuildBaseDataForSelected (_ sender: NSButton){
        let start = Date()
        var activities: [Activity] = []
        if let a = activitiesToRebuild{
            // not nil
            activities = a
        }else{
            //array is nil
            activities = Activity.baseDataActivities
        }
        for activity in activities{
            var activityTypes: [ActivityType] = []
            if let ats = activityTypesToRebuild{
                // not nil
                activityTypes = ats
            }else{
                // array is nil. indicating do all
                activityTypes = activity.typesForEddingtonNumbers()
            }
            for activityType in activityTypes{
                var units: [Unit] = []
                if let u = unitsToRebuild{
                    //not nil
                    units = u
                }else{
                    // array is nil
                    units = activity.unitsForEddingtonNumbers()
                }
                for unit in units{
                    var periods: [Period] = []
                    if let p = periodsToRebuild{
                        //not nil
                        periods = p
                    }else{
                        // array is nil
                        periods = Period.baseDataPeriods
                    }
                    for period in periods{
                        if let td = trainingDiary{
                            let _ = BaseDataCalculator.shared.createBaseData(forTrainingDiary: td, activity: activity, activityType: activityType, period: period, unit: unit)

                    }
                    }
                }
            }
        }
        print("Base Data rebuild took \(Date().timeIntervalSince(start)) seconds")


    }
    

    @IBAction func activityField(_ sender: NSTextField) {
        self.activity = sender.stringValue
        if self.activity == "" {
            self.activity = nil
            activitiesToRebuild = Activity.baseDataActivities
        }else if let a = Activity(rawValue: sender.stringValue){
            //tryped a valid Activity
            activitiesToRebuild = [a]
        }else{
            activitiesToRebuild = []
            print("Invalid activity. Rebuild not possible")
        }
        updatePredicate()
    }
    
    @IBAction func activityTypeField(_ sender: NSTextField) {
        self.activityType = sender.stringValue
        if self.activityType == "" {
            self.activityType = nil
            activityTypesToRebuild = nil
        }else if let at = ActivityType(rawValue: sender.stringValue){
            activityTypesToRebuild = [at]
        }else{
            activityTypesToRebuild = []
            print("Invalid ActivityType. Rebuild not possible")
        }
        updatePredicate()
    }
    
    @IBAction func unitField(_ sender: NSTextField) {
        self.unit = sender.stringValue
        if self.unit == "" {
            self.unit = nil
            unitsToRebuild = nil
        }else if let u = Unit(rawValue: sender.stringValue){
            unitsToRebuild = [u]
        }else{
            unitsToRebuild = []
            print("Invalid Unit. Rebuild not possible")
        }
        updatePredicate()
    }
    
    @IBAction func periodField(_ sender: NSTextField) {
        self.period = sender.stringValue
        if self.period == "" {
            self.period = nil
            periodsToRebuild = nil
        }else if let p = Period(rawValue: sender.stringValue){
            periodsToRebuild = [p]
        }else{
            activityTypesToRebuild = []
            print("Invalid ActivityType. Rebuild not possible")
        }
        updatePredicate()
    }
    
    @IBAction func yearField(_ sender: NSTextField) {
        self.year = Int(sender.stringValue)
        print("Year set to \(String(describing: year))")
        updatePredicate()
    }

    
    //MARK: - Private
 
    private func updatePredicate(){
        var predicateString: String = ""
        var arguments: [Any] = []
        var isFirstPredicate = true
        if let a = activity{
            predicateString = addTo(predicateString: predicateString, withPredicateString: " activity CONTAINS %@", isFirstPredicate)
            arguments.append(a)
            isFirstPredicate = false
        }
        if let at = activityType{
            predicateString = addTo(predicateString: predicateString, withPredicateString: " activityType CONTAINS %@", isFirstPredicate)
            arguments.append(at)
            isFirstPredicate = false
        }
        if let p = period{
            predicateString = addTo(predicateString: predicateString, withPredicateString: " period CONTAINS %@", isFirstPredicate)
            arguments.append(p)
            isFirstPredicate = false
        }
        if let u = unit{
            predicateString = addTo(predicateString: predicateString, withPredicateString: " unit CONTAINS %@", isFirstPredicate)
            arguments.append(u)
            isFirstPredicate = false
        }
        if let y = year{
            predicateString = addTo(predicateString: predicateString, withPredicateString: " year CONTAINS %i", isFirstPredicate)
            arguments.append(y)
            isFirstPredicate = false
        }

        if predicateString != ""{
            let myPredicate = NSPredicate.init(format: predicateString, argumentArray: arguments)
            print(myPredicate)
            let start = Date()
            print("about to set predicate...")
            baseDataArrayController.filterPredicate = myPredicate
            print("Done in \(Date().timeIntervalSince(start)) seconds")
        }else{
            baseDataArrayController.filterPredicate = nil
            isFirstPredicate = true
        }
    }
    
    private func addTo(predicateString: String, withPredicateString: String,_ isFirstPredicate: Bool) -> String{
        if isFirstPredicate{
            return withPredicateString
        }else{
            return predicateString + " AND " + withPredicateString
        }
    }
}
