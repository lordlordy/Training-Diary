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
    @IBOutlet weak var fromDatePicker: NSDatePicker!
    @IBOutlet weak var toDatePicker: NSDatePicker!
    
    private var advanceDateComponent: DateComponents?
    private var retreatDateComponent: DateComponents?
    
    

    //MARK: - Actions
    
 /*   @IBAction func calcAllTSB(_ sender: NSButton) {
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
   */
    
    @IBAction func testFeature(_ sender: NSButton) {
        let start = Date()
        for e in trainingDiary!.eddingtonNumbers!{
            let s = Date()
            var edNum = e as! EddingtonNumber
            let calculator = EddingtonNumberCalculator()
            calculator.calculate(eddingtonNumber: edNum)
            edNum.update(forCalculator: calculator)
            print("\(edNum.eddingtonCode) - \(Date().timeIntervalSince(s))s")
        }
        print("Recalc took \(Date().timeIntervalSince(start))s")
    }
    
    
    @IBAction func periodCBChanged(_ sender: PeriodComboBox) {

        if let p = sender.selectedPeriod(){
            if p == Period.Lifetime{
                fromDatePicker!.dateValue = trainingDiary!.firstDayOfDiary
                toDatePicker!.dateValue = trainingDiary!.lastDayOfDiary
                setFilterPredicate()
            }else{
                if let d = latestSelectedDate(){
                    let range = p.periodRange(forDate: d)
                    fromDatePicker!.dateValue = range.from
                    toDatePicker!.dateValue = range.to
                    setFilterPredicate()
                }
            }
        }
    }
    
    @IBAction func periodTextFieldChange(_ sender: PeriodTextField) {
        
        if let dc = sender.getNegativeDateComponentsEquivalent(){
            fromDatePicker!.dateValue = Calendar.current.date(byAdding: dc, to: toDatePicker!.dateValue)!
            setFilterPredicate()
        }
        
        advanceDateComponent = sender.getDateComponentsEquivalent()
        retreatDateComponent = sender.getNegativeDateComponentsEquivalent()
    }
    
    @IBAction func retreatClicked(_ sender: NSButton) {
        advanceDates(by: retreatDateComponent)
    }
    
    @IBAction func advanceClicked(_ sender: NSButton) {
        advanceDates(by: advanceDateComponent)
    }
    
    @IBAction func validate(_ sender: NSButton){
        if let td = trainingDiary{
            td.findDuplicates()
            td.findMissingYesterdayOrTomorrow()
        }
    }
    
    @IBAction func printDays(_ sender: NSButton){
        let selectedDays = daysArrayController.selectedObjects as! [Day]
        for d in selectedDays{
            print(d.date!.dateOnlyString())
            print(d)
            print("-- WORKOUTS:")
            if let workouts = d.workouts{
                for w in workouts{
                    print(w)
                }
            }
        }        
    }
    
    @IBAction func exportCSV(_ sender: NSButton) {
        let exporter = CSVExporter()
        let csv = exporter.convertToCVS(forDays: arrangedDays())
        
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        var saveFileName = homeDir.appendingPathComponent("workouts.csv")
        do{
            try csv.workoutCSV.write(to: saveFileName, atomically: false, encoding: .ascii)
        }catch let error as NSError{
            print(error)
        }
        saveFileName = homeDir.appendingPathComponent("days.csv")
        do{
            try csv.dayCSV.write(to: saveFileName, atomically: false, encoding: .ascii)
        }catch let error as NSError{
            print(error)
        }
    }
    
    @IBAction func fromDateChange(_ sender: NSDatePicker)   { setFilterPredicate() }
    @IBAction func toDateChange(_ sender: NSDatePicker)     { setFilterPredicate() }
    
    @IBAction func filterDays(_ sender: NSButton){
        setFilterPredicate()
    }
    
    //MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        daysArrayController.sortDescriptors.append(NSSortDescriptor.init(key: "date", ascending: false))
        // Add Observer
  //      let notificationCentre = NotificationCenter.default
 //       notificationCentre.addObserver(self, selector: #selector(DaysViewController.notificationReceived), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: nil)
        
       
    }
    
    
    


/*    @objc func notificationReceived(notification:Notification){
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
    
 */
    
    //MARK: -
    
    func set(trainingDiary td: TrainingDiary){
        self.trainingDiary = td
        if let dac = daysArrayController{
            dac.trainingDiary = td
        }
        toDatePicker!.dateValue = td.lastDayOfDiary
        fromDatePicker!.dateValue = td.lastDayOfDiary.addDays(numberOfDays: -365)
        setFilterPredicate()
    }


    //MARK: - Private
    
    private func setFilterPredicate(){
        if let from = fromDatePicker?.dateValue{
            if let to = toDatePicker?.dateValue{
                daysArrayController.filterPredicate = NSPredicate(format: "date >= %@ AND date <= %@", argumentArray: [from.startOfDay(),to.endOfDay()])
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
    
    private func arrangedDays() -> [Day]{
        if let dac = daysArrayController{
            return dac.arrangedObjects as! [Day]
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
    
    private func advanceDates(by: DateComponents?){
        if let dc = by{
            fromDatePicker!.dateValue = Calendar.current.date(byAdding: dc, to: fromDatePicker!.dateValue)!
            toDatePicker!.dateValue = Calendar.current.date(byAdding: dc, to: toDatePicker!.dateValue)!
            setFilterPredicate()
        }
    }

}
