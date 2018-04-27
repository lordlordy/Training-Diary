//
//  DefaultsViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 06/02/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class DefaultsViewController: TrainingDiaryViewController, NSComboBoxDataSource, ReferenceToMainProtocol, NSTableViewDelegate {

    private var mainViewController: ViewController?
    private let maxDaysForActivityDecay: Int = 30

    
    @IBOutlet weak var activityGraphView: GraphView!
    @IBOutlet var activitiesArrayController: NSArrayController!
    
    @IBOutlet var validationOutputTextView: NSTextView!
    
    //MARK: - IBActions
    @IBAction func adhoc(_ sender: Any) {
        if let td = trainingDiary{
            var results: [String: Double] = [:]
            let start = Date()

            for p in Period.All{
       //     for p in [Period.Lifetime, Period.Adhoc, Period.Workout]{
                print(p.rawValue)
                let ALL = ConstantString.EddingtonAll.rawValue
                let tdValues = td.valuesFor(dayType: ALL, activity: FixedActivity.Bike.rawValue, activityType: ALL, equipment: ALL, period: p, aggregationMethod: Unit.Watts.defaultAggregator(), unit: Unit.Watts)
                let aggregator = MeanAggregator(activity: td.activity(forString: FixedActivity.Bike.rawValue)!, period: p, unit: Unit.Watts, weighting: Unit.Seconds, from: td.firstDayOfDiary, to: td.lastDayOfDiary)
                let meanAggregator = MeanAggregator(activity: td.activity(forString: FixedActivity.Bike.rawValue)!, period: p, unit: Unit.Watts, weighting: nil, from: td.firstDayOfDiary, to: td.lastDayOfDiary)
                let aggValues = aggregator.aggregate(data: td.days?.allObjects as? [Day] ?? [])
                let meanValues = meanAggregator.aggregate(data: td.days?.allObjects as? [Day] ?? [])

                var tdDict: [String: Double] = [:]
                for v in tdValues{
                    tdDict[v.date.dateOnlyString()] = v.value
                }
                
                var aggDict: [String: Double] = [:]
                for v in aggValues{
                    aggDict[v.date.dateOnlyString()] = v.value
                }

                var meanDict: [String: Double] = [:]
                for v in meanValues{
                    meanDict[v.date.dateOnlyString()] = v.value
                }
                
                var sumSquares: Double = 0.0
                var errors: Int = 0
                
                for i in tdDict{
                    var agg: Double = 0
                    if let a = aggDict[i.key]{
                        agg = a
                    }else{
                        errors += 1
                    }
                    let diff = i.value - agg
                    sumSquares += pow(diff ,2)
                }
                print("\(p.rawValue) - Sum of squares ~ Errors : \(sumSquares) ~ \(errors)")
               
                results[p.rawValue] = sumSquares

                for i in meanDict{
                    print("\(i.key) mean:weighted - \(meanDict[i.key]) : \(aggDict[i.key])")
                }
                
            }
            
            for i in results{
                print("\(i.value) - \(i.key)")
            }
            
            print("Took \(Date().timeIntervalSince(start))s")
        }
    }
    

    @IBAction func duplicateDays(_ sender: Any) {
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
        logMessage("DUPLICATE DAYS:")

        
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
                    logMessage("activityType nil for workout \(String(describing: w.activityTypeString)) - \(w.day!.date!.dateOnlyShorterString())")
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
    

    override func viewDidLoad() {
        
        updateGraphs(forActivity: trainingDiary!.activity(forString: FixedActivity.Bike.rawValue)!)
        
    }
    
    //MARK: - NSTableViewDelegate
    func tableViewSelectionDidChange(_ notification: Notification) {
       print("Activity table selection changed")
        if let ac = activitiesArrayController{
            if let selection = ac.selectedObjects{
                if selection.count > 0{
                    if let a = selection[0] as? Activity{
                        print(a.name as Any)
                        if let gv = activityGraphView{
                            gv.clearGraphs()
                            updateGraphs(forActivity: a)
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - ReferenceToMainProtocol
    func setMainViewControllerReference(to vc: ViewController){
        mainViewController = vc
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


    private func ctlReplacementData(forActivity a: Activity) -> [(date: Date, value: Double)]{
        var result: [(date: Date, value: Double)] = []
        let d = Date()
        
        for i in 0...maxDaysForActivityDecay{
            result.append((date: d.addDays(numberOfDays: i), value: 100 * a.ctlReplacementTSSFactor(afterNDays: i)))
        }
        return result
    }

    private func ctlDecayData(forActivity a: Activity) -> [(date: Date, value: Double)]{
        var result: [(date: Date, value: Double)] = []
        let d = Date()
        
        for i in 0...maxDaysForActivityDecay{
            result.append((date: d.addDays(numberOfDays: i), value: 100 * a.ctlDecayFactor(afterNDays: i)))
        }
        return result
    }
    
    private func atlReplacementData(forActivity a: Activity) -> [(date: Date, value: Double)]{
        var result: [(date: Date, value: Double)] = []
        let d = Date()
        
        for i in 0...maxDaysForActivityDecay{
            result.append((date: d.addDays(numberOfDays: i), value: 100 * a.atlReplacementTSSFactor(afterNDays: i)))
        }
        return result
    }
    
    private func atlDecayData(forActivity a: Activity) -> [(date: Date, value: Double)]{
        var result: [(date: Date, value: Double)] = []
        let d = Date()
        
        for i in 0...maxDaysForActivityDecay{
            result.append((date: d.addDays(numberOfDays: i), value: 100 * a.atlDecayFactor(afterNDays: i)))
        }
        return result
    }
    
    private func updateGraphs(forActivity a: Activity){
        if let gv = activityGraphView{
            gv.clearGraphs()
            for g in graphs(forActivity: a){
                gv.add(graph: g)
            }
            gv.xAxisLabelStrings = ["0","3","6","9","12","15","18","21","24","27","30"]
        }
    }
    
    private func graphs(forActivity a: Activity) -> [GraphDefinition]{
        
        let testCTLData = ctlReplacementData(forActivity: a)
        let testATLData = atlReplacementData(forActivity: a)
        let testCTLDecayData = ctlDecayData(forActivity: a)
        let testATLDecayData = atlDecayData(forActivity: a)
        
        var testData: [(date: Date, value: Double)] = []
        for i in 0...maxDaysForActivityDecay{
            testData.append((date: testCTLDecayData[i].date, value: testCTLDecayData[i].value - testATLDecayData[i].value))
        }
        
        let ctlGraphDefinition = GraphDefinition(name: a.name!, data: testCTLData, axis: .Primary, type: .Line, format: GraphFormat.init(fill: false, colour: .red, fillGradientStart: .red, fillGradientEnd: .red, gradientAngle: 1.0, size: 2.0, opacity: 1.0), drawZeroes: true, priority: 1)
        
        let atlGraphDefinition = GraphDefinition(name: a.name!, data: testATLData, axis: .Primary, type: .Line, format: GraphFormat.init(fill: false, colour: .green, fillGradientStart: .green, fillGradientEnd: .green, gradientAngle: 1.0, size: 2.0, opacity: 1.0), drawZeroes: true, priority: 1)
        
        let ctlDecayGraphDefinition = GraphDefinition(name: a.name!, data: testCTLDecayData, axis: .Secondary, type: .Line, format: GraphFormat.init(fill: false, colour: .red, fillGradientStart: .red, fillGradientEnd: .red, gradientAngle: 1.0, size: 2.0, opacity: 1.0), drawZeroes: true, priority: 1)
        
        let atlDecayGraphDefinition = GraphDefinition(name: a.name!, data: testATLDecayData, axis: .Secondary, type: .Line, format: GraphFormat.init(fill: false, colour: .green, fillGradientStart: .green, fillGradientEnd: .green, gradientAngle: 1.0, size: 2.0, opacity: 1.0), drawZeroes: true, priority: 1)
        
        let testGraphDefinition = GraphDefinition(name: a.name!, data: testData, axis: .Secondary, type: .Line, format: GraphFormat.init(fill: false, colour: .yellow, fillGradientStart: .yellow, fillGradientEnd: .yellow, gradientAngle: 1.0, size: 2.0, opacity: 1.0), drawZeroes: true, priority: 1)
        
        return [ctlGraphDefinition, atlGraphDefinition, ctlDecayGraphDefinition, atlDecayGraphDefinition, testGraphDefinition]
        
    }
}
