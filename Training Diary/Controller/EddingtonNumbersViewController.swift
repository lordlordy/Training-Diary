//
//  EddingtonNumbersViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 30/10/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Cocoa

class EddingtonNumbersViewController: NSViewController, TrainingDiaryViewController, NSComboBoxDataSource {

    @objc dynamic var trainingDiary: TrainingDiary?
    var mainViewController: ViewController?
    @IBOutlet var treeController: NSTreeController!
    
    private var activity: String?
    private var activityType: String?
    private var equipment: String?
    private var period: String?
    private var unit: String?
    private var year: Int?
    
    //same graphs for all so set them up here
    private let historyGraph = GraphDefinition(name: "history", axis: .Primary, type: .Line, format: GraphFormat.init(fill: false, colour: .red, fillGradientStart: .red, fillGradientEnd: .red, gradientAngle: 0.0, size: 2.0), drawZeroes: false, priority: 1)
    private let plusOneGraph = GraphDefinition(name: "plusOne", axis: .Primary, type: .Line, format: GraphFormat.init(fill: false, colour: .blue, fillGradientStart: .blue, fillGradientEnd: .blue, gradientAngle: 0.0, size: 1.0), drawZeroes: false, priority: 1)
    private let contributorsGraph = GraphDefinition(name: "contributors", axis: .Primary, type: .Point, format: GraphFormat.init(fill: false, colour: .green, fillGradientStart: .green, fillGradientEnd: .green, gradientAngle: 0.0, size: 2.0), drawZeroes: false, priority: 2)
    private let annualHistoryGraph = GraphDefinition(name: "annual", axis: .Primary, type: .Point, format: GraphFormat.init(fill: true, colour: .yellow, fillGradientStart: .yellow, fillGradientEnd: .yellow, gradientAngle: 0.0, size: 7.0), drawZeroes: false, priority: 4)
    private let maturityGraph = GraphDefinition(name: "maturity", axis: .Secondary, type: .Line, format: GraphFormat.init(fill: false, colour: .cyan, fillGradientStart: .cyan, fillGradientEnd: .cyan, gradientAngle: 0.0, size: 1.0), drawZeroes: false, priority: 5)

    @IBOutlet weak var graphView: GraphView!
    
    @IBOutlet var eddingtonNumberArrayController: NSArrayController!
    @IBOutlet var eddingtonNumberTreeController: NSTreeController!
    

    

    @IBAction func calculateTreeSelection(_ sender: Any) {
        var edNums = Set<LTDEddingtonNumber>()
        for s in treeController!.selectedObjects{
            if let node = s as? LTDEddingtonNumber{
                for e in node.getLeaves(){
                    edNums.insert(e)
                }
            }
        }
        let calculator = EddingtonNumberCalculator()
        for e in edNums{
            let result = calculator.quickCaclulation(forDayType: e.dayType!,forActivity: e.activity!, andType: e.activityType!, equipment: e.equipment!, andPeriod: Period(rawValue: e.period!)!, andUnit: Unit(rawValue: e.unit!)!, inTrainingDiary: trainingDiary!)
            trainingDiary!.addLTDEddingtonNumber(forDayType: e.dayType!, forActivity: e.activity!, type: e.activityType!, equipment: e.equipment!, period: Period(rawValue: e.period!)!, unit: Unit(rawValue: e.unit!)!, value: result.ednum, plusOne: result.plusOne, maturity: result.maturity)
            
            print("\(e.shortCode) : \(result)")
        }
    }
    
    @IBAction func outlineViewDoubleClicked(_ sender: NSOutlineView) {
        let item = sender.item(atRow: sender.clickedRow)
        
        if sender.isItemExpanded(item){
            sender.collapseItem(item)
        }else{
            sender.expandItem(item)
        }
    }
    
    @IBAction func saveAsHTML(_ sender: Any) {
        var html: String = ""
 
        if let tableStart = Bundle.main.url(forResource: "tableStart", withExtension: "txt"){
            do{
                let contents = try String.init(contentsOf: tableStart)
                html += contents
            }catch{
                print("tableStart.txt not loaded")
            }
        }
 
        if let edNumSet = trainingDiary?.ltdEddingtonNumbers?.allObjects as? [LTDEddingtonNumber]{
            for e in edNumSet.sorted(by: {$0.code < $1.code}){
                for l in e.getLeaves().sorted(by: {$0.code < $1.code}){
                    html += "<tr>\n"
                    html += "<td>\(l.activity!)</td>\n"
                    html += "<td>\(l.equipment!)</td>\n"
                    html += "<td>\(l.activityType!)</td>\n"
                    html += "<td>\(l.period!)</td>\n"
                    html += "<td>\(l.unit!)</td>\n"
                    html += "<td>\(l.value)</td>\n"
                    html += "<td>\(l.plusOne)</td>\n"
                    html += "</tr>"
                }
            }
        }
        
        if let tableEnd = Bundle.main.url(forResource: "tableEnd", withExtension: "txt"){
            do{
                let contents = try String.init(contentsOf: tableEnd)
                html += contents
            }catch{
                print("tableEnd.txt not loaded")
            }
        }
        
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        let saveFileName = homeDir.appendingPathComponent("ltdEddingtonNumbers.html")
        do{
            try html.write(to: saveFileName, atomically: false, encoding: .ascii)
        }catch let error as NSError{
            print(error)
        }
 
    }

    
    
    @IBAction func calculateAll(_ sender: NSButton) {
        calculatedLTD()
    }
    
    
    @IBAction func updateSelection(_ sender: NSButton) {
        let start = Date()

        mainViewController!.mainStatusField.stringValue = "EDDINGTON NUMBER UPDATE: starting..."
        DispatchQueue.global(qos: .userInitiated).async {
            var count: Double = 0.0
            let total: Double = Double(self.selectedRows().count)
            for edNum in self.selectedRows(){
                count += 1
                let secs = Int(Date().timeIntervalSince(start))
                DispatchQueue.main.sync {
                    self.mainViewController!.mainStatusField.stringValue = "EDDINGTON NUMBER UPDATE: \(Int(count)) of \(Int(total)) : \(edNum.eddingtonCode) (\(secs)s) ..."
                }
                let subStart = Date()
                let calculator = EddingtonNumberCalculator()
                calculator.update(eddingtonNumber: edNum)
                DispatchQueue.main.async {
                    
                    print("starting ednum update \(Date().timeIntervalSince(start))s from start")
                    edNum.update(forCalculator: calculator)
                    print("finished ednum update \(Date().timeIntervalSince(start))s from start")

                    self.mainViewController!.mainProgressBar!.doubleValue = 100.0 * count / total
                }
                let timeTaken = Date().timeIntervalSince(subStart)
                print("Time taken for \(edNum.eddingtonCode): \(timeTaken) seconds")
            }
            let seconds = Date().timeIntervalSince(start)
            print("Time taken for new Ed num update: \(seconds) seconds.")
            DispatchQueue.main.async {
                self.mainViewController!.mainStatusField.stringValue = "EDDINGTON NUMBER UPDATE: Update complete in \(Int(Date().timeIntervalSince(start)))s"
                print("update graph called \(Date().timeIntervalSince(start))s since start")
                self.updateGraph()
                print("graph updated  \(Date().timeIntervalSince(start))s since start")
                print("TOTAL TIME = \(Date().timeIntervalSince(start))s")
            }
        }

    }
    
    @IBAction func calculateSelection(_ sender: NSButton) {
        
        let start = Date()
        var slowCalcs: [(code: String, seconds: TimeInterval)] = []
        mainViewController!.mainStatusField!.stringValue = "EDDINGTON NUMBER CALCULATION: starting..."
        DispatchQueue.global(qos: .userInitiated).async {
            var count: Double = 0.0
            let total: Double = Double(self.selectedRows().count)
            for edNum in self.selectedRows(){
                count += 1
                let secs = Int(Date().timeIntervalSince(start))
                DispatchQueue.main.sync {
                    self.mainViewController!.mainStatusField!.stringValue = "EDDINGTON NUMBER CALCULATION: \(Int(count)) of \(Int(total)) : \(edNum.eddingtonCode) (\(secs)s) ..."
                }
                let subStart = Date()
                let calculator = EddingtonNumberCalculator()
                calculator.calculate(eddingtonNumber: edNum)
                DispatchQueue.main.async {
                    
                    edNum.update(forCalculator: calculator)
                    
                    self.mainViewController!.mainProgressBar!.doubleValue = 100.0 * count / total
                }
                let timeTaken = Date().timeIntervalSince(subStart)
                if timeTaken > 1.0{
                    slowCalcs.append((edNum.eddingtonCode, timeTaken))
                }
                print("Time taken for \(edNum.eddingtonCode): \(timeTaken) seconds")
            }
            print("Slow calculations:")
            var totalSlowSeconds = 0.0
            for s in slowCalcs.sorted(by: {$0.seconds > $1.seconds}) {
                print(s)
                totalSlowSeconds += s.seconds
            }
            print("Slow calculations totaled \(totalSlowSeconds) seconds")
            let slowAverage = totalSlowSeconds / Double(slowCalcs.count)
            let totalSeconds = Date().timeIntervalSince(start)
            let otherAverage = (totalSeconds - totalSlowSeconds) / (total - Double(slowCalcs.count))
            print("Slow average = \(slowAverage) other average = \(otherAverage)")
            print("Time taken for new Ed num calculation: \(totalSeconds) seconds.")
            DispatchQueue.main.async {
                self.mainViewController!.mainStatusField!.stringValue = "EDDINGTON NUMBER CALCULATION: Calc complete in \(Int(totalSeconds))s"
                print("TOTAL TIME = \(Date().timeIntervalSince(start))")
            }
        }

        updateGraph()
    }
    

    
    @IBAction func equipmentField(_ sender: NSTextField) {
        self.equipment = sender.stringValue
        if self.equipment == "" {self.equipment = nil}
        updatePredicate()
    }
    @IBAction func activityField(_ sender: NSTextField) {
        self.activity = sender.stringValue
        if self.activity == "" {self.activity = nil}
        updatePredicate()
    }
    @IBAction func activityTypeField(_ sender: NSTextField) {
        self.activityType = sender.stringValue
        if self.activityType == "" {self.activityType = nil}
        updatePredicate()
    }

    @IBAction func periodField(_ sender: NSTextField) {
        self.period = sender.stringValue
        if self.period == "" {self.period = nil}
        updatePredicate()
    }
    
    @IBAction func unitField(_ sender: NSTextField) {
        self.unit = sender.stringValue
        if self.unit == "" {self.unit = nil}
        updatePredicate()
    }
    

    func set(trainingDiary td: TrainingDiary){
        self.trainingDiary = td
        if let gv = graphView{
            let range = td.lastDayOfDiary.timeIntervalSince(td.firstDayOfDiary)
            let numberOfLabels = 6
            let gap = range / Double(numberOfLabels - 1)
            var labels: [String] = []
            labels.append(td.firstDayOfDiary.dateOnlyShorterString())
            for i in 1...(numberOfLabels-1){
                labels.append(td.firstDayOfDiary.addingTimeInterval(TimeInterval(gap*Double(i))).dateOnlyShorterString())
            }
            gv.xAxisLabelStrings = labels
        }


    }
    
    
    //MARK: - NSComboBoxDataSource
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        if let identifier = comboBox.identifier{
            switch identifier.rawValue{

            case "EdNumActivityComboBox":
                let activities = trainingDiary!.eddingtonActivities()
                if index < activities.count{
                    return activities[index]
                }
            case "EdNumActivityTypeComboBox":
                guard let c = comboBox.superview as? NSTableCellView else{ return 0 }
                if let e = c.objectValue as? EddingtonNumber{
                    if let a = e.activity{
                        let types = trainingDiary!.eddingtonActivityTypes(forActivityString: a)
                        if index < types.count{
                            return types[index]
                        }
                    }
                }
            case "EdNumEquipmentComboBox":
                guard let c = comboBox.superview as? NSTableCellView else{ return 0 }
                if let e = c.objectValue as? EddingtonNumber{
                    if let a = e.activity{
                        let types = trainingDiary!.eddingtonEquipment(forActivityString: a)
                        if index < types.count{
                            return types[index]
                        }
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

            case "EdNumActivityComboBox":
                return trainingDiary!.eddingtonActivities().count
            case "EdNumActivityTypeComboBox":
                guard let c = comboBox.superview as? NSTableCellView else{ return 0 }
                if let e = c.objectValue as? EddingtonNumber{
                    return trainingDiary!.eddingtonActivityTypes(forActivityString: e.activity!).count
                }
            case "EdNumEquipmentComboBox":
                guard let c = comboBox.superview as? NSTableCellView else{ return 0 }
                if let e = c.objectValue as? EddingtonNumber{
                    return trainingDiary!.eddingtonEquipment(forActivityString: e.activity!).count
                }

            default:
                return 0
            }
        }
        return 0
    }

    //MARK: - Override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpGraphs()
        if let eddNumAC = eddingtonNumberArrayController{
            eddNumAC.addObserver(self, forKeyPath: "selection", options: .new, context: nil)
        }
        if let tc = treeController{
            tc.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        }
    }

    //MARK: - value observing
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath!{
        case "selection":
            updateGraph()

        default:
            print("why am I observing \(String(describing: keyPath))")
        }
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
        if let e = equipment{
            predicateString = addTo(predicateString: predicateString, withPredicateString: " equipment CONTAINS %@", isFirstPredicate)
            arguments.append(e)
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
    
    private func getSelectedEddingtonNumber() -> EddingtonNumber?{
        if selectedRows().count > 0{
            return selectedRows()[0]
        }
        return nil
    }
    
    private func setUpGraphs(){
        if let gv = graphView{
            
            gv.add(graph: historyGraph)
            gv.add(graph: plusOneGraph)
            gv.add(graph: contributorsGraph)
            gv.add(graph: annualHistoryGraph)
            gv.add(graph: maturityGraph)

            gv.backgroundGradientStartColour = .lightGray
            gv.backgroundGradientEndColour = .darkGray
            gv.backgroundGradientAngle = 45
            
            //create the labels - create six
            var xAxisLabels: [String] = []
            if let td = trainingDiary{
                let from = td.firstDayOfDiary
                let to = td.lastDayOfDiary
                let gap = to.timeIntervalSince(from) / 5.0
                xAxisLabels.append(from.dateOnlyShorterString())
                for i in 1...5{
                    xAxisLabels.append(from.addingTimeInterval(gap * Double(i)).dateOnlyShorterString())
                }
            }
            
            gv.xAxisLabelStrings = xAxisLabels
            
            let formatter = NumberFormatter()
            formatter.format = "#,##0.00"
            gv.secondaryAxisNumberFormatter = formatter
            
            
        }
    }
    
    private func updateGraph(){
        if let edNum = getSelectedEddingtonNumber(){
            if let gv = graphView{

                //start with zero for first day of diary - this ensures that scales line up.
                let firstEntry = (date: trainingDiary!.firstDayOfDiary,value: 0.0)
                var history: [(date: Date, value: Double)] = [firstEntry]
                var plusOneHistory: [(date: Date, value: Double)] = [firstEntry]
                var contributors: [(date: Date, value: Double)] = [firstEntry]
                var annualHistory: [(date: Date, value: Double)] = [firstEntry]
                var maturityHistory: [(date: Date, value: Double)] = [firstEntry]

                for e in edNum.getSortedHistory(){
                    history.append((date: e.date!, value: Double(e.value)))
                    plusOneHistory.append((date: e.date!, value: Double(e.value + e.plusOne)))
                    maturityHistory.append((date: e.date!, value: e.maturity))

                }
                historyGraph.data = history
                plusOneGraph.data = plusOneHistory
                maturityGraph.data = maturityHistory
                
                for c in edNum.getSortedContributors(){
                    contributors.append((c.date!, c.value))
                }
                

                contributorsGraph.data = contributors
                
                for e in edNum.getSortedAnnualHistory(){
                    annualHistory.append((date:e.date!, value: Double(e.value)))
                }
                annualHistoryGraph.data = annualHistory
                
                gv.chartTitle = edNum.eddingtonCode
                
                gv.needsDisplay = true
                
            }
        }
    }
    
    private func calculatedLTD(){
        //this is a calculation of all possible ed nums
        var total = 0
        
        let timeRemainingFormatter = DateComponentsFormatter()
        timeRemainingFormatter.allowedUnits = [ .hour, .minute, .second]
        timeRemainingFormatter.unitsStyle = .abbreviated
        timeRemainingFormatter.includesApproximationPhrase = true
        timeRemainingFormatter.includesTimeRemainingPhrase = true
        timeRemainingFormatter.maximumUnitCount = 2
        
        let timeTakenFormatter = DateComponentsFormatter()
        timeTakenFormatter.allowedUnits = [ .hour, .minute, .second]
        timeTakenFormatter.unitsStyle = .abbreviated
        
        mainViewController!.mainStatusField!.stringValue = "EDDINGTON LTD CALCULATION OF ALL: estimating total to be calculated... "

        //test approach - need to evaluate if this is worth doing
        let localWorkoutCopy: [Workout] = trainingDiary!.allWorkouts()
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            //count how many we're calculting
           for dt in self.trainingDiary!.eddingtonDayTypes(){
                var periods: [Period] = [Period.Day]
                if dt == ConstantString.EddingtonAll.rawValue{
                    periods = Period.eddingtonNumberPeriods
                }
                for a in self.trainingDiary!.eddingtonActivities(){
                    for e in self.trainingDiary!.eddingtonEquipment(forActivityString: a){
                        for at in self.trainingDiary!.eddingtonActivityTypes(forActivityString: a){
                            
                            var units = Unit.activityUnits
                            
                            if (a == ConstantString.EddingtonAll.rawValue && at == ConstantString.EddingtonAll.rawValue && e == ConstantString.EddingtonAll.rawValue){
                                units = Unit.allUnits
                            }else if (at == ConstantString.EddingtonAll.rawValue && e == ConstantString.EddingtonAll.rawValue){
                                //metrics only calculated on the activity for ALL types and ALL Equipment
                                units.append(contentsOf: Unit.metrics)
                            }
                            
                            // lets check if worth doing any calcs
                            
                            let workoutCount = localWorkoutCopy.filter({ (w: Workout) -> Bool in
                                let aCorrect    = a == "All" || w.activityString == a
                                let atCorrect   = at == "All" || w.activityTypeString == at
                                let eCorrect    = e == "All" || w.equipmentName == e
                                return aCorrect && atCorrect && eCorrect}).count
                            
                            if workoutCount > Int(Constant.WorkoutThresholdForEdNumberCount.rawValue){
                                for _ in units.sorted(by: {$0.rawValue < $1.rawValue}){
                                    for _ in periods{
                                        total += 1
                                    }// end Period loop
                                }// end unit loop
                            }//end else on workout count chedk
                        }// end type loop
                    }// end equipment loop
                }// end activity loop
            }//end dayType loop

            let start = Date()

            var count: Int = 0
            let calculator = EddingtonNumberCalculator()
            var name: String = ""
            
            for dt in self.trainingDiary!.eddingtonDayTypes(){
                var periods: [Period] = [Period.Day]
                if dt == ConstantString.EddingtonAll.rawValue{
                    periods = Period.eddingtonNumberPeriods
                }
                for a in self.trainingDiary!.eddingtonActivities(){
                    for e in self.trainingDiary!.eddingtonEquipment(forActivityString: a){
                        for at in self.trainingDiary!.eddingtonActivityTypes(forActivityString: a){
                            
                            var units = Unit.activityUnits
                            
                            if (a == ConstantString.EddingtonAll.rawValue && at == ConstantString.EddingtonAll.rawValue && e == ConstantString.EddingtonAll.rawValue){
                                units = Unit.allUnits
                            }else if (at == ConstantString.EddingtonAll.rawValue && e == ConstantString.EddingtonAll.rawValue){
                                //metrics only calculated on the activity for ALL types and ALL Equipment
                                units.append(contentsOf: Unit.metrics)
                            }
                            
                            // lets check if worth doing any calcs
                            let workoutCount = localWorkoutCopy.filter({ (w: Workout) -> Bool in
                                let aCorrect    = a == "All" || w.activityString == a
                                let atCorrect   = at == "All" || w.activityTypeString == at
                                let eCorrect    = e == "All" || w.equipmentName == e
                                return aCorrect && atCorrect && eCorrect}).count
                            
                            if workoutCount <= Int(Constant.WorkoutThresholdForEdNumberCount.rawValue){
                                print("Only \(workoutCount) workouts for \(dt):\(a):\(e):\(at) so not bothering to calculate eddington numbers")
                            }else{
                                
                                for u in units.sorted(by: {$0.rawValue < $1.rawValue}){
                                    for p in periods{
                                        count += 1
                                        name = dt
                                        name += ":" + a
                                        name += ":" + e
                                        name += ":" + at
                                        name += ":" + p.rawValue
                                        name += ":" + u.rawValue
                                        autoreleasepool{ // added for memory management
                                            let result = calculator.quickCaclulation(forDayType: dt, forActivity: a, andType: at, equipment: e, andPeriod: p, andUnit: u, inTrainingDiary: self.trainingDiary!)
                                            
                                            DispatchQueue.main.sync {
                                                let time = Date().timeIntervalSince(start)
                                                let stillToCalculate = total - count
                                                let estimatedRemaining = Double(stillToCalculate) * time / Double(count)
                                                let remaining = timeRemainingFormatter.string(from: estimatedRemaining) ?? ""
                                                let taken = timeTakenFormatter.string(from: time) ?? ""
                                                print("\(remaining) of EDNUM LTD CALC: \(count) of \(total) : \(name) (\(taken)s...")
                                                self.mainViewController!.mainStatusField!.stringValue = "\(remaining) of EDNUM LTD CALC: \(count) of \(total) : \(name) (\(taken))..."
                                                self.mainViewController!.mainProgressBar!.doubleValue = 100.0 * Double(count) / Double(total)
                                                if result.ednum > 0{
                                                    self.trainingDiary!.addLTDEddingtonNumber(forDayType: dt, forActivity: a, type: at, equipment: e, period: p, unit: u, value: result.ednum, plusOne: result.plusOne, maturity: result.maturity)
                                                }
                                            }// end autoreleasepool
                                        }// end DispatchQueue.main
                                    }// end Period loop
                                }// end unit loop
                            }//end else on workout count chedk
                        }// end type loop
                    }// end equipment loop
                }// end activity loop
            }// end of dayType loop

            DispatchQueue.main.async {
                let timeTaken = timeTakenFormatter.string(from: Date().timeIntervalSince(start)) ?? ""
                self.mainViewController!.mainStatusField.stringValue = "EDDINGTON LTD CALCULATION OF ALL: ALL LTD complete in \(timeTaken)"
                self.mainViewController!.mainProgressBar!.doubleValue = 100.0
            }
        }// end DispatchGlobal
    }


    
    // There must be a better way to do this. once an eddington number is calculated we don't want the user changing the type - ie Activity, Unit or Period. The Combo Boxes enabled is bound to eddington number 'requiresCalculation' property. When the last updated field is set the Combo Boxes are re-displayed as disabled. This method prods them
    private func prod(eddingtonNumber ed: EddingtonNumber){
        let a = ed.activity
        let at = ed.activityType
        let p = ed.period
        let u = ed.unit
        
        ed.activity = a
        ed.activityType = at
        ed.period = p
        ed.unit = u
        
    }
}
