//
//  DaysViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 01/11/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Cocoa

class DaysViewController: TrainingDiaryViewController, NSComboBoxDataSource, NSTableViewDelegate {

//    @objc dynamic var trainingDiary: TrainingDiary?
    
    @IBOutlet var daysArrayController: DaysArrayController!
    @IBOutlet var workoutArrayController: NSArrayController!
    
    @IBOutlet weak var dayTableView: TableViewWithColumnSort!
    @IBOutlet weak var fromDatePicker: NSDatePicker!
    @IBOutlet weak var toDatePicker: NSDatePicker!
    
    private var advanceDateComponent: DateComponents?
    private var retreatDateComponent: DateComponents?
    private var currentWorkout: Workout?
    
    

    //MARK: - Actions

    
    @IBAction func testFeature(_ sender: NSButton) {
  //      print("No test feature currently implemented")
        for d in selectedDays(){
            print(d.date!.dayOfWeekName())
        }
    }
    
    @IBAction func addDay(_ sender: Any) {
        if let dac = daysArrayController{
            dac.add(sender)
            setFilterPredicate()
        }
        toDatePicker!.dateValue = trainingDiary!.lastDayOfDiary.tomorrow()

        reload(sender)
    }
    
    @IBAction func reload(_ sender: Any) {
        if let table = dayTableView{
            table.reloadData()
        }
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
        setFilterPredicate()
       
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let key = keyPath{
            if let w = object as? Workout{
                switch key{
                case WorkoutProperty.equipmentName.rawValue:
                    if let td = trainingDiary{
                        if let workout = currentWorkout{
                            if let e = workout.equipmentName{
                                if let equipment = td.equipment(forActivity: w.activityString!, andName: e){
                                    workout.equipment = equipment
                                    print("Workout \(workout.day!.date!.dateOnlyShorterString()) added to  \(equipment.name!)")
                                }
                            }
                        }
                    }
                case WorkoutProperty.activityString.rawValue:
                    print("activityString changed ")
                        print("\(String(describing: w.activityString)):\(String(describing: w.activityTypeString)) connecting activity...")
                        if let td = w.day?.trainingDiary{
                            w.activity = td.activity(forString: w.activityString!)
                            print("DONE")
                        }else{
                            print("Failed as couldn't connect to training diary")
                        }
                    
                case WorkoutProperty.activityTypeString.rawValue:
                    print("activityTypeString changed")
                        print("\(String(describing: w.activityString)):\(String(describing: w.activityTypeString))")
                        if let td = w.day?.trainingDiary{
                            w.activityType = td.activityType(forActivity: w.activityString!, andType: w.activityTypeString!)
                            print("DONE")
                        }else{
                            print("Failed as couldn't connect to training diary")
                        }
                    
                default:
                    print("!! Didn't thinkk I set an observer for \(String(describing: keyPath))")
                }
            }
        }
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
    
    //MARK: - NSTableViewDelegate
    func tableViewSelectionDidChange(_ notification: Notification) {
        if let workout = currentWorkout{
            workout.removeObserver(self, forKeyPath: WorkoutProperty.equipmentName.rawValue)
            workout.removeObserver(self, forKeyPath: WorkoutProperty.activityString.rawValue)
            workout.removeObserver(self, forKeyPath: WorkoutProperty.activityTypeString.rawValue)
        }
        if let wac = workoutArrayController{
            let workouts = wac.selectedObjects as! [Workout]
            if workouts.count == 1{
                currentWorkout = workouts[0]
                workouts[0].addObserver(self, forKeyPath: WorkoutProperty.equipmentName.rawValue, options: NSKeyValueObservingOptions.new, context: nil)
                workouts[0].addObserver(self, forKeyPath: WorkoutProperty.activityString.rawValue, options: NSKeyValueObservingOptions.new, context: nil)
                workouts[0].addObserver(self, forKeyPath: WorkoutProperty.activityTypeString.rawValue, options: NSKeyValueObservingOptions.new, context: nil)
            }
        }
    
    }
    
    //MARK: - NSComboBoxDataSource
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        if let identifier = comboBox.identifier{
            switch identifier.rawValue{
            case "BikeComboBox":
                if let a = currentWorkout?.activityString{
                    let types = trainingDiary!.validEquipment(forActivityString: a).map({$0.name})
                    if index < types.count{
                        return types[index]
                    }
                }
            case "DaysViewActivityComboBox":
                let activities = trainingDiary!.activitiesArray().map({$0.name})
                if index < activities.count{
                    return activities[index]
                }
            case "DaysViewActivityTypeComboBox":
                if let a = currentWorkout?.activityString{
                    let types = trainingDiary!.validActivityTypes(forActivityString: a).map({$0.name})
                    if index < types.count{
                        return types[index]
                    }
                }
            default:
                print("What combo box is this \(identifier.rawValue) which I'm (DaysViewController) a data source for? ")
            }
        }
        return nil
    }

    func numberOfItems(in comboBox: NSComboBox) -> Int {
        if let identifier = comboBox.identifier{
            switch identifier.rawValue{
            case "BikeComboBox":
                return trainingDiary!.activeBikes().count
            case "DaysViewActivityComboBox":
                return trainingDiary!.activitiesArray().count
            case "DaysViewActivityTypeComboBox":
                if let a = currentWorkout?.activityString{
                    return trainingDiary!.validActivityTypes(forActivityString: a).count
                }
            default:
                return 0
            }
        }
        return 0
    }
    
    //MARK: - TrainingDiaryViewControllerProtocol
    
    override func set(trainingDiary td: TrainingDiary){
        super.set(trainingDiary: td)
        if let dac = daysArrayController{
            dac.trainingDiary = td
        }
        if let tdp = toDatePicker{
            tdp.dateValue = td.lastDayOfDiary
        }
        if let fdp = fromDatePicker{
            fdp.dateValue = td.lastDayOfDiary.addDays(numberOfDays: -20 )
        }
        setFilterPredicate()
    }


    //MARK: - Private
    
    private func setFilterPredicate(){
        if let from = fromDatePicker?.dateValue{
            if let to = toDatePicker?.dateValue{
                daysArrayController.filterPredicate = NSPredicate(format: "date >= %@ AND date <= %@", argumentArray: [from.startOfDay(),to.endOfDay()])
                print("Set predice to \(daysArrayController.filterPredicate)")
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
