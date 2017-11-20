//
//  DaysViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 01/11/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Cocoa

class DaysViewController: NSViewController {

    @objc dynamic var trainingDiary: TrainingDiary?
    
    @IBOutlet var daysArrayController: DaysArrayController!
    


    @IBAction func calcAllTSB(_ sender: NSButton) {
        if let td = trainingDiary{
            for a in Activity.allActivities{
                td.calcTSB(forActivity: a, fromDate: td.firstDayOfDiary!)
            }
        }
    }
    
    
    @IBAction func createBaseDataForSelectionMethod2(_ sender: NSButton) {
        let start = Date()
        if let days = daysArrayController.selectedObjects{
            print("\(days.count) days selected")
            for d in days{
                BaseDataCalculator.shared.createBaseDataMethod2(forDay: d as! Day)
            }
        }else{
            print("No days selected")
        }
        print("Time take: \(Date().timeIntervalSince(start)) seconds")
    }
    
    @IBAction func createBaseDataForSelection(_ sender: NSButton){
        let start = Date()
        if let days = daysArrayController.selectedObjects{
            print("\(days.count) days selected")
            for d in days{
                BaseDataCalculator.shared.createBaseData(forDay: d as! Day)
            }
        }else{
            print("No days selected")
        }
        print("Time take: \(Date().timeIntervalSince(start)) seconds")
    }
    
    @IBAction func periodComboBoxChanged(_ sender: NSComboBox) {
        var s: String = ""
        switch sender.stringValue.lowercased(){
        case "day":     s = "Day"
        case "week":    s = "Week"
        case "month":   s = "Month"
        case "rweek":   s = "RWeek"
        case "rmonth":  s = "RMonth"
        case "ryear":   s = "RYear"
        case "wtd":     s = "WTD"
        case "mtd":     s = "MTD"
        case "ytd":     s = "YTD"
        default:        s = sender.stringValue
        }
        sender.stringValue = s
        if let p = Period(rawValue: s){
            if let d = trainingDiary?.filterDaysTo{
                let range = p.periodRange(forDate: d)
                trainingDiary?.setValue(range.from, forKey: TrainingDiaryProperty.filterDaysFrom.rawValue)
                trainingDiary?.setValue(range.to, forKey: TrainingDiaryProperty.filterDaysTo.rawValue)
                setFilterPredicate()
            }
        }else{
            sender.stringValue = ""
        }
    }
    
    @IBAction func findDuplicateDates(_ sender: NSButton){
        var results: [Date] = []
        if let allObjects = trainingDiary?.days?.allObjects{
            let days = allObjects as! [Day]
            let dates = days.map{$0.date!}.sorted(by: {$0 > $1})
            print(dates.count)
            var previousDate: Date?
            for d in dates{
                if previousDate != nil && d.isSameDate(asDate: previousDate!){
                    results.append(d)
                }
                previousDate = d
            }

        }
        print("\(results.count) duplicates found.")
        if results.count > 0{
            print("Dates are:")
            for r in results{
                print(r)
            }

        }
    }
    
    @IBAction func printDays(_ sender: NSButton){
        let selectedDays = daysArrayController.selectedObjects as! [Day]
        for d in selectedDays{
            print(d.date!.dateOnlyString())
            print(d)
            print("---------------------- WORKOUTS --------------------")
            if let workouts = d.workouts{
                for w in workouts{
                    print(w)
                }
            }
        }        
    }
    
    @IBAction func setFilterToToToday(_ sender: NSButton){
        trainingDiary?.setValue(Date().startOfDay(), forKey: TrainingDiaryProperty.filterDaysTo.rawValue)
    }
    

    @IBAction func filterDays(_ sender: NSButton){
        trainingDiary?.setValue(trainingDiary?.filterDaysFrom?.startOfDay(), forKey: TrainingDiaryProperty.filterDaysFrom.rawValue)
        trainingDiary?.setValue(trainingDiary?.filterDaysTo?.endOfDay(), forKey: TrainingDiaryProperty.filterDaysTo.rawValue)
        setFilterPredicate()
    }
    
    @IBAction func showAllDays(_sender: NSButton){
        clearFilterPredicate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        daysArrayController.sortDescriptors.append(NSSortDescriptor.init(key: "date", ascending: false))
        
   //     if let td = trainingDiary {
            print("Adding observer")
            // Add Observer
            let notificationCentre = NotificationCenter.default
        notificationCentre.addObserver(self, selector: #selector(DaysViewController.notificationReceived), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: nil)

    //   }
    }
    


    @objc func notificationReceived(notification:Notification){
        
        if let moc = notification.object as! NSManagedObjectContext?{
            if let ui = notification.userInfo{
                if let updates = ui[NSUpdatedObjectsKey] as? Set<NSManagedObject>, updates.count > 0 {
             //       print("--- UPDATES ---")
                    for update in updates {
                        if let workout = moc.object(with: update.objectID) as? Workout{
                            if let day = workout.day{
                                day.setValue(true, forKey: DayProperty.workoutChanged.rawValue)
                            }
                        }
               //         print(update.changedValues())
                    }
                   // print("+++++++++++++++")
                }
            }
        }
        
        
        
    }
    
    func managedObjectContextObjectsDidChange(notification: NSNotification) {
        print("********************change with notification: \(notification)")
    }

    



    @IBAction func rebuildBaseDataDaysVC(_ sender: Any?){
        print("About to rebuild for \(String(describing: trainingDiary?.name))")
    
    }
    

    private func setFilterPredicate(){
        if let from = trainingDiary?.filterDaysFrom{
            if let to = trainingDiary?.filterDaysTo{
                daysArrayController.filterPredicate = NSPredicate(format: "date >= %@ AND date <= %@", argumentArray: [from,to])
            }
        }
    }
    
    private func clearFilterPredicate(){
        daysArrayController.filterPredicate = nil
    }
    
}
