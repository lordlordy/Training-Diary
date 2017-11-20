//
//  EddingtonNumbersViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 30/10/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Cocoa

class EddingtonNumbersViewController: NSViewController {

//    @objc dynamic var managedObjectContext: NSManagedObjectContext?
    @objc dynamic var trainingDiary: TrainingDiary?
    
     var activities: [Activity] = Activity.allActivities
    
    private var activity: String?
    private var activityType: String?
    private var period: String?
    private var unit: String?
    private var year: Int?
    
    @IBOutlet var eddingtonNumberArrayController: NSArrayController!
    
    @IBAction func tester(_ sender: NSButton) {
        let start = Date()
        for edNum in selectedRows(){
            let days = trainingDiary!.days!.allObjects as! [Day]
            let sortedDays = days.sorted(by: {$0.date! < $1.date!})
            for d in sortedDays{
                let value = d.valueFor(period: Period(rawValue:edNum.period!)!, activity: Activity(rawValue: edNum.activity!)!, activityType: ActivityType(rawValue: edNum.activityType!)!, unit: Unit(rawValue: edNum.unit!)!)
                print("\(d.date!.dateOnlyString()) - \(value)")
            }
        }
        print("Time take: \(Date().timeIntervalSince(start)) seconds")
    }
    
    
    @IBAction func activityField(_ sender: NSTextField) {
        print("Activity set to \(sender.stringValue)")
        self.activity = sender.stringValue
        if self.activity == "" {self.activity = nil}
        updatePredicate()
    }
    @IBAction func activityTypeField(_ sender: NSTextField) {
        print("ActivityType set to \(sender.stringValue)")
        self.activityType = sender.stringValue
        if self.activityType == "" {self.activityType = nil}
        updatePredicate()
    }

    @IBAction func periodField(_ sender: NSTextField) {
        print("Period set to \(sender.stringValue)")
        self.period = sender.stringValue
        if self.period == "" {self.period = nil}
        updatePredicate()
    }
    
    @IBAction func unitField(_ sender: NSTextField) {
        print("unit set to \(sender.stringValue)")
        self.unit = sender.stringValue
        if self.unit == "" {self.unit = nil}
        updatePredicate()
    }
    
    @IBAction func yearField(_ sender: NSTextField) {
        self.year = Int(sender.stringValue)
        print("Year set to \(String(describing: year))")
        updatePredicate()
    }
    
    @IBAction func calcSelectedEddingtonNumer(_ sender: NSButton) {
        EddingtonNumberCalculator.shared.calculate(forEddingtonNumbers: eddingtonNumberArrayController.selectedObjects as! [EddingtonNumber], forTrainingDiary: trainingDiary!)
    }
    

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
            eddingtonNumberArrayController.filterPredicate = myPredicate
        }else{
            eddingtonNumberArrayController.filterPredicate = nil
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
    
    private func selectedRows() -> [EddingtonNumber]{
        if let selectedObjects = eddingtonNumberArrayController.selectedObjects{
            return selectedObjects as! [EddingtonNumber]
        }else{
            return []
        }
        
    }
    
    
}
