//
//  EddingtonNumbersViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 30/10/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Cocoa

class EddingtonNumbersViewController: NSViewController, TrainingDiaryViewController {

    @objc dynamic var trainingDiary: TrainingDiary?
    
    private var activity: String?
    private var activityType: String?
    private var period: String?
    private var unit: String?
    private var year: Int?
    
    @IBOutlet weak var graphView: GraphView!
    
    @IBOutlet var eddingtonNumberArrayController: NSArrayController!
    @IBOutlet var ltdEdNumArrayController: NSArrayController!
    
    @IBOutlet weak var edCalcProgressBar: NSProgressIndicator!
    @IBOutlet weak var calcProgressTextField: NSTextField!
    
    @IBAction func saveAll(_ sender: NSButton) {

        var html: String = ""
        if let tableStart = Bundle.main.url(forResource: "tableStart", withExtension: "txt"){
            do{
                let contents = try String.init(contentsOf: tableStart)
                html += contents
            }catch{
                print("tableStart.txt not loaded")
            }
        }
        
        if let edNumSet = trainingDiary?.lTDEdNumbers?.allObjects as! [LTDEdNum]?{
            for e in edNumSet.sorted(by: {$0.edCode < $1.edCode}){
                html += "<tr>\n"
                html += "<td>\(e.activity!)</td>\n"
                html += "<td>\(e.activityType!)</td>\n"
                html += "<td>\(e.period!)</td>\n"
                html += "<td>\(e.unit!)</td>\n"
                html += "<td>\(e.value)</td>\n"
                html += "<td>\(e.plusOne)</td>\n"
                html += "</tr>"
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
        //this is a calculation of all possible ed nums
        let start = Date()
        //remove all ltd ed nums from training diary
        if let ltdEdNumSet = trainingDiary?.mutableSetValue(forKey: TrainingDiaryProperty.lTDEdNumbers.rawValue){
            ltdEdNumSet.removeAllObjects()
        }

        calcProgressTextField!.stringValue = "starting..."
        DispatchQueue.global(qos: .userInitiated).async {
            var totalPossible: Int = 0
            for a in Activity.allActivities{
                let validUnitsForActivity = a.validUnits()
                for at in a.validTypes(){
                    let validUnitsCount = validUnitsForActivity.intersection(at.validUnits()).count
                    totalPossible += validUnitsCount
                }
            }
            totalPossible = totalPossible * Period.eddingtonNumberPeriods.count
            
            var count: Int = 0
            let calculator = EddingtonNumberCalculator()
            var name: String = ""
            
            for a in Activity.allActivities{
 //           for a in [Activity.Bike]{
                for at in a.validTypes(){
 //                       for at in [ActivityType.All]{
                    for u in at.validUnits().intersection(a.validUnits()).sorted(by: {$0.rawValue < $1.rawValue}){
                        for p in Period.eddingtonNumberPeriods{
//                            for p in [Period.Day]{
                            count += 1
                            name = a.rawValue
                            name += ":" + at.rawValue
                            name += ":" + p.rawValue
                            name += ":" + u.rawValue
                            let result = calculator.quickCaclulation(forActivity: a, andType: at, andPeriod: p, andUnit: u, inTrainingDiary: self.trainingDiary!)
                            DispatchQueue.main.sync {
                                self.calcProgressTextField!.stringValue = "\(count) of \(totalPossible) : \(name) (\(Int(Date().timeIntervalSince(start)))s) ..."
                                self.edCalcProgressBar!.doubleValue = 100.0 * Double(count) / Double(totalPossible)
                                if result.ednum > 0{
                                    self.trainingDiary!.addLTDEddingtonNumber(forActivity: a, type: at, period: p, unit: u, value: result.ednum, plusOne: result.plusOne)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    @IBAction func updateSelection(_ sender: NSButton) {
        let start = Date()
        calcProgressTextField!.stringValue = "starting..."
        DispatchQueue.global(qos: .userInitiated).async {
            var count: Double = 0.0
            let total: Double = Double(self.selectedRows().count)
            for edNum in self.selectedRows(){
                count += 1
                let secs = Int(Date().timeIntervalSince(start))
                DispatchQueue.main.sync {
                    self.calcProgressTextField!.stringValue = "\(Int(count)) of \(Int(total)) : \(edNum.eddingtonCode) (\(secs)s) ..."
                }
                let subStart = Date()
                let calculator = EddingtonNumberCalculator()
                calculator.update(eddingtonNumber: edNum)
                DispatchQueue.main.async {
                    
                    edNum.update(forCalculator: calculator)
                    
                    //         self.prod(eddingtonNumber: edNum)
                    self.edCalcProgressBar!.doubleValue = 100.0 * count / total
                }
                let timeTaken = Date().timeIntervalSince(subStart)
                print("Time taken for \(edNum.eddingtonCode): \(timeTaken) seconds")
            }
            let seconds = Date().timeIntervalSince(start)
            print("Time taken for new Ed num update: \(seconds) seconds.")
            DispatchQueue.main.async {
                self.calcProgressTextField!.stringValue = "Update complete in \(Int(seconds))s"
            }
        }
        
        updateGraph()
    }
    
    @IBAction func calculateSelection(_ sender: NSButton) {
        
        let start = Date()
        var slowCalcs: [(code: String, seconds: TimeInterval)] = []
        calcProgressTextField!.stringValue = "starting..."
        DispatchQueue.global(qos: .userInitiated).async {
            var count: Double = 0.0
            let total: Double = Double(self.selectedRows().count)
            for edNum in self.selectedRows(){
                count += 1
                let secs = Int(Date().timeIntervalSince(start))
                DispatchQueue.main.sync {
                    self.calcProgressTextField!.stringValue = "\(Int(count)) of \(Int(total)) : \(edNum.eddingtonCode) (\(secs)s) ..."
                }
                let subStart = Date()
                let calculator = EddingtonNumberCalculator()
                calculator.calculate(eddingtonNumber: edNum)
                DispatchQueue.main.async {
                    
                    edNum.update(forCalculator: calculator)
                    
           //         self.prod(eddingtonNumber: edNum)
                    self.edCalcProgressBar!.doubleValue = 100.0 * count / total
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
                self.calcProgressTextField!.stringValue = "Calc complete in \(Int(totalSeconds))s"
            }
        }

        updateGraph()
    }
    
 /*
    @IBAction func updateEdNumber(_ sender: NSButton){
        let start = Date()
        for edNum in selectedRows(){
            let calculator = EddingtonNumberCalculator()
            calculator.updateEddingtonNumber(forEddingtonNumber: edNum)
            prod(eddingtonNumber: edNum)
 
        }
        print("Time taken for Core data Ed num update: \(Date().timeIntervalSince(start)) seconds")
        updateGraph()
    }
 */
    
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
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let eddNumAC = eddingtonNumberArrayController{
            eddNumAC.addObserver(self, forKeyPath: "selection", options: .new, context: nil)
        }
        if let gv = graphView{
            if let td = trainingDiary{
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
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        switch keyPath!{
        case "selection":
            updateGraph()

        default:
            print("why am I observing \(String(describing: keyPath))")
        }
    }
    
    private func setProgress(_ value: Double){
        if let pb = edCalcProgressBar{
            pb.increment(by: value)
            pb.display()
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
            ltdEdNumArrayController.filterPredicate = myPredicate
        }else{
            eddingtonNumberArrayController.filterPredicate = nil
            ltdEdNumArrayController.filterPredicate = nil
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
    
    private func updateGraph(){
        
        if let edNum = getSelectedEddingtonNumber(){
            if let gv = graphView{
                gv.clearGraphs()
                let historyGraph = GraphDefinition(name: "history", axis: .Primary, type: .Line, format: GraphFormat.init(fill: false, colour: .red, fillGradientStart: .red, fillGradientEnd: .red, gradientAngle: 0.0, size: 2.0), drawZeroes: false, priority: 1)
                let plusOneGraph = GraphDefinition(name: "plusOne", axis: .Primary, type: .Line, format: GraphFormat.init(fill: false, colour: .blue, fillGradientStart: .blue, fillGradientEnd: .blue, gradientAngle: 0.0, size: 1.0), drawZeroes: false, priority: 1)
                let contributorsGraph = GraphDefinition(name: "contributors", axis: .Primary, type: .Point, format: GraphFormat.init(fill: false, colour: .green, fillGradientStart: .green, fillGradientEnd: .green, gradientAngle: 0.0, size: 2.0), drawZeroes: false, priority: 2)
                let annualHistoryGraph = GraphDefinition(name: "annual", axis: .Primary, type: .Point, format: GraphFormat.init(fill: true, colour: .yellow, fillGradientStart: .yellow, fillGradientEnd: .yellow, gradientAngle: 0.0, size: 7.0), drawZeroes: false, priority: 4)
                
                
                //start with zero for first day of diary - this ensures that scales line up.
                let firstEntry = (date: trainingDiary!.firstDayOfDiary,value: 0.0)
                var history: [(date: Date, value: Double)] = [firstEntry]
                var plusOneHistory: [(date: Date, value: Double)] = [firstEntry]
                var contributors: [(date: Date, value: Double)] = [firstEntry]
                var annualHistory: [(date: Date, value: Double)] = [firstEntry]
                
                for e in edNum.getSortedHistory(){
                    history.append((date: e.date!, value: Double(e.value)))
                    plusOneHistory.append((date: e.date!, value: Double(e.value + e.plusOne)))
                }
                
                for c in edNum.getSortedContributors(){
                    contributors.append((c.date!, c.value))
                }
                
                historyGraph.data = history
                plusOneGraph.data = plusOneHistory
                contributorsGraph.data = contributors
                
                for e in edNum.getSortedAnnualHistory(){
                    annualHistory.append((date:e.date!, value: Double(e.value)))
                }
                annualHistoryGraph.data = annualHistory
                
                gv.chartTitle = edNum.eddingtonCode
                
                gv.add(graph: historyGraph)
                gv.add(graph: plusOneGraph)
                gv.add(graph: contributorsGraph)
                gv.add(graph: annualHistoryGraph)
                
                gv.backgroundGradientStartColour = .lightGray
                gv.backgroundGradientEndColour = .darkGray
                gv.backgroundGradientAngle = 45
                
                gv.needsDisplay = true
                
            }
        }
    }
    
    
    // There must be a better way to do this. once an eddington number is calculated we don't want the user changing the type - ie Activity, Unit or Period. The Combo Boxes enable is bound to eddington number 'requiresCalculation' property. When the last updated field is set the Combo Boxes are re-displayed as disabled. This method prods them
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
