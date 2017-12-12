//
//  DaysViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 01/11/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Cocoa

class DaysViewController: NSViewController, TrainingDiaryViewController {

    @objc dynamic var trainingDiary: TrainingDiary?
    
    @IBOutlet var daysArrayController: DaysArrayController!
    
    @IBOutlet weak var dayTableView: TableViewWithColumnSort!
    

    @IBAction func calcAllTSB(_ sender: NSButton) {
        if let td = trainingDiary{
            for a in Activity.allActivities{
                print(a)
                td.calcTSB(forActivity: a, fromDate: td.firstDayOfDiary)
            }
        }
    }
    
    @IBAction func calcTSBFrom(_ sender: NSButton) {
        if let td = trainingDiary{
            if let d = latestSelectedDate(){
                for a in Activity.allActivities{
                    td.calcTSB(forActivity: a, fromDate: d)
                }
            }
        }
    }
    
    @IBAction func periodCBChanged(_ sender: PeriodComboBox) {
        if let p = sender.selectedPeriod(){
            if let d = latestSelectedDate(){
                var range = p.periodRange(forDate: d)
                if p == Period.Lifetime{
                    range = (from: trainingDiary!.firstDayOfDiary, to: trainingDiary!.lastDayOfDiary)
                }
                trainingDiary?.setValue(range.from, forKey: TrainingDiaryProperty.filterDaysFrom.rawValue)
                trainingDiary?.setValue(range.to, forKey: TrainingDiaryProperty.filterDaysTo.rawValue)
                setFilterPredicate()
            }
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        daysArrayController.sortDescriptors.append(NSSortDescriptor.init(key: "date", ascending: false))
    
        // Add Observer
  //      let notificationCentre = NotificationCenter.default
 //       notificationCentre.addObserver(self, selector: #selector(DaysViewController.notificationReceived), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: nil)
        
       
    }
    


    @objc func notificationReceived(notification:Notification){
        print("notification received called in DayViewController")
        let start = Date()
        if let moc = notification.object as! NSManagedObjectContext?{
            if let ui = notification.userInfo{
                if let updates = ui[NSUpdatedObjectsKey] as? Set<NSManagedObject>, updates.count > 0 {
                    for update in updates {
                        if let workout = moc.object(with: update.objectID) as? Workout{
                            if let day = workout.day{
                                day.setValue(true, forKey: DayProperty.workoutChanged.rawValue)
                            }
                        }
                    }
                }
            }
        }
        
        print("leaving notification receieved after \(Date().timeIntervalSince(start)) seconds")
        
    }
    
    
    func set(trainingDiary td: TrainingDiary){
        self.trainingDiary = td
        if let dac = daysArrayController{
            dac.trainingDiary = td
        }
    }


    //MARK: - Private
    
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
    
    private func selectedDays() -> [Day]{
        if let dac = daysArrayController{
            return dac.selectedObjects as! [Day]
        }else{
            return []
        }
    }
    
    private func latestSelectedDate() -> Date?{
        var latestDate: Date?
        for d in selectedDays(){
            if let latest = latestDate{
                if d.date! > latest{
                    latestDate = d.date
                }
            }else{
                latestDate = d.date
            }
        }
        
        return latestDate
    }
    

}
