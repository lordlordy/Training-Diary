//
//  GraphViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 18/11/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Cocoa


class GraphViewController: NSViewController, TrainingDiaryViewController, GraphManagementDelegate, NSComboBoxDataSource {

    fileprivate struct Constants{
        static let numberOfXAxisLabels: Int = 12
    }
    
    @IBOutlet var graphArrayController: GraphArrayController!

    //this cache is Training Diary specific so will need clearing if training diary is set different.
    private var cache: [String:[(date:Date, value:Double)]] = [:]
    private var graphCache: [TrainingDiary: [ActivityGraphDefinition]] = [:]
    private var dataCache: [TrainingDiary: [String:[(date:Date, value:Double)]]] = [:]
    private var advanceDateComponent: DateComponents?
    private var retreatDateComponent: DateComponents?
    
    @objc dynamic var trainingDiary: TrainingDiary?
    
    @IBOutlet weak var graphView: GraphView!
    @IBOutlet weak var fromDatePicker: NSDatePicker!
    @IBOutlet weak var toDatePicker: NSDatePicker!
    @IBOutlet weak var activityComboBox: NSComboBox!
    
    
    @IBAction func graphPeriodChange(_ sender: PeriodTextField) {
        if let dc = sender.getNegativeDateComponentsEquivalent(){
            if let fdp = fromDatePicker{
                if let tdp = toDatePicker{
                    fdp.dateValue = Calendar.current.date(byAdding: dc, to: tdp.dateValue)!
                    updateForDateChange()
                }
            }
        }
        advanceDateComponent = sender.getDateComponentsEquivalent()
        retreatDateComponent = sender.getNegativeDateComponentsEquivalent()
    }
    
    @IBAction func retreatAPeriod(_ sender: NSButton) {
        if let retreat = retreatDateComponent{
            advance(by: retreat)
        }
    }
    
    @IBAction func advanceAPeriod(_ sender: NSButton) {
        if let a = advanceDateComponent{
            advance(by: a)
        }
    }
    
    @IBAction func periodComboBoxChanged(_ sender: PeriodComboBox) {
        if let period = sender.selectedPeriod(){
            if let gac = graphArrayController{
                for graph in gac.arrangedObjects as! [ActivityGraphDefinition]{
                    //setting the string so the GUI updates
                    graph.periodString = period.rawValue
                }
                updateGraphs()
            }
        }
    }
    
    @IBAction func activityChanged(_ sender: NSComboBox) {
        if let gac = graphArrayController{
            for graph in gac.arrangedObjects as! [ActivityGraphDefinition]{
                graph.activity = sender.stringValue
            }
            updateGraphs()
        }
    }
    
    @IBAction func activityTypeChanged(_ sender: ActivityTypeComboBox) {
        if let gac = graphArrayController{
            for graph in gac.arrangedObjects as! [ActivityGraphDefinition]{
                graph.activityType = sender.stringValue
            }
        }
    }
    
    @IBAction func unitChanged(_ sender: UnitComboBox) {
        if let gac = graphArrayController{
            for graph in gac.arrangedObjects as! [ActivityGraphDefinition]{
                graph.unitString = sender.stringValue
            }
        }
    }
    
    @IBAction func fromDateChanged(_ sender: NSDatePicker) {
        updateForDateChange()
    }
    
    @IBAction func toDateChanged(_ sender: NSDatePicker) {
        updateForDateChange()
    }
    
    
    //MARK: - GraphManagementDelegate implementation
    func add(graph: ActivityGraphDefinition){
        addObservers(forGraph: graph)
        if let gv = graphView{
            gv.add(graph: graph.graph!)
        }
    }
    
    func setDefaults(forGraph graph: ActivityGraphDefinition){
        
    }
    
    func remove(graph: ActivityGraphDefinition){
        removeObservers(forGraph: graph)
        if let gv = graphView{
            gv.remove(graph: graph.graph!)
        }
    }
    
    func set(trainingDiary td: TrainingDiary){
        if let _ = trainingDiary{
            // we already have a diary. So first lets cache data we have
            saveCache()
            //now clear graphs
            for graph in graphs(){ remove(graph: graph) }
            if let gac = graphArrayController{ gac.remove(contentsOf: graphs()) }
        }
        self.trainingDiary = td
        if retrieveFromCache(){
            for g in graphs(){ add(graph: g)}
        } else {
            initialSetUp()
        }
        
    }
    
    //MARK: - NSComboBoxDataSource
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        if let identifier = comboBox.identifier{
            switch identifier.rawValue{
            case "TableActivityComboBox", "ActivityComboBox":
                let activities = trainingDiary!.activitiesArray().map({$0.name!})
                if index < activities.count{
                    return activities[index]
                }
            case "TableActivityTypeComboBox":
                guard let c = comboBox.superview as? NSTableCellView else{
                    return nil
                }
                if let graph = c.objectValue as? ActivityGraphDefinition{
                    let types = trainingDiary!.validActivityTypes(forActivityString: graph.activity).map({$0.name!})
                    if index < types.count{
                        return types[index]
                    }
                }
            case "ActivityTypeComboBox":
                if let acb = activityComboBox{
                    if let types = trainingDiary?.validActivityTypes(forActivityString: acb.stringValue){
                        if index < types.count{
                            return types[index].name
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
            case "TableActivityComboBox", "ActivityComboBox":
                return trainingDiary!.activitiesArray().count
            case "TableActivityTypeComboBox":
                guard let c = comboBox.superview as? NSTableCellView else{
                    return 0
                }
                if let graph = c.objectValue as? ActivityGraphDefinition{
                    return trainingDiary!.validActivityTypes(forActivityString: graph.activity).count
                }
            case "ActivityTypeComboBox":
                if let acb = activityComboBox{
                    if let types = trainingDiary?.validActivityTypes(forActivityString: acb.stringValue){
                        return types.count
                    }
                }
            default:
                return 0
            }
        }
        return 0
    }
    
    //MARK: -
    
    override func viewDidLoad() {
        if let gac = graphArrayController{
            gac.graphManagementDelegate = self
        }
        if graphs().count == 0{
            initialSetUp()
        }
    }
    

    
    //MARK: - Property Observing
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?){
        
        if let gv = graphView{
            switch keyPath{
            case "name"?:
                if let graphDefinition = object as? ActivityGraphDefinition{
                    updateData(forGraph: graphDefinition)
                    gv.needsDisplay = true
                }
            default:
                print("~~~~~~~ Am I meant to be observing key path \(String(describing: keyPath))")
            }
        }
    }

    //MARK: - Private
    
    private func advance(by dc: DateComponents){
        if let fdp = fromDatePicker{
            if let tdp = toDatePicker{
                fdp.dateValue = Calendar.current.date(byAdding: dc, to: fdp.dateValue)!
                tdp.dateValue = Calendar.current.date(byAdding: dc, to: tdp.dateValue)!
                updateForDateChange()
            }
        }
    }
    
    private func updateGraphs(){
        if let gac = graphArrayController{
            for graph in gac.arrangedObjects as! [ActivityGraphDefinition]{
                updateData(forGraph: graph)
            }
        }
        graphView!.needsDisplay = true
    }
    
    private func updateForDateChange(){
        if let gac = graphArrayController{
            for g in gac.arrangedObjects as! [ActivityGraphDefinition]{
                updateForDateChange(forGraph: g)
            }
        }
    }
    
    private func updateForDateChange(forGraph g: ActivityGraphDefinition){
        if let fdp = fromDatePicker{
            if let tdp = toDatePicker{
                if let graph = graphView{
                    let filteredData = g.cache.filter({$0.date >= fdp.dateValue && $0.date <= tdp.dateValue})
                    g.graph?.data = filteredData
                    graph.xAxisLabelStrings = getXAxisLabels(fromDate: fdp.dateValue, toDate: tdp.dateValue)
                    graph.needsDisplay = true
                }
            }
        }
    }


    
    //sets up to a standard TSB view
    private func initialSetUp(){
        if let fdp = fromDatePicker{
            if let tdp = toDatePicker{
                if let td = trainingDiary{
                    let to = td.lastDayOfDiary
                    let from = to.addDays(numberOfDays: -365)
                    fdp.dateValue = from
                    tdp.dateValue = to
                
                    if let gv = graphView{
                        // this shouldn't be here. Will refactor out when sort out creating axes in GraphView
                        gv.xAxisLabelStrings = getXAxisLabels(fromDate: from, toDate: to)
                        gv.numberOfPrimaryAxisLines = 6
                        gv.numberOfSecondaryAxisLines = 8

                        let tsbGraph = createGraphDefinition(forActivity: FixedActivity.Bike.rawValue, period: .Day, unit: .TSB, type: .Line, axis: .Primary, drawZeroes: true, priority: 4, format: GraphFormat(fill: true, colour: .blue, fillGradientStart: .red, fillGradientEnd: .blue, gradientAngle: 90.0, size: 1.0))
                        let ctlGraph = createGraphDefinition(forActivity: FixedActivity.Bike.rawValue, period: .Day, unit: .CTL, type: .Line, axis: .Primary, drawZeroes: true, priority: 3, format: GraphFormat(fill: false, colour: .red, fillGradientStart: .red, fillGradientEnd: .red, gradientAngle: 0.0, size: 1.0))
                        let atlGraph = createGraphDefinition(forActivity: FixedActivity.Bike.rawValue, period: .Day, unit: .ATL, type: .Line, axis: .Primary, drawZeroes: true, priority: 2, format: GraphFormat(fill: false, colour: .green, fillGradientStart: .green, fillGradientEnd: .green, gradientAngle: 0.0, size: 1.0))
                        let tssGraph = createGraphDefinition(forActivity: FixedActivity.Bike.rawValue, period: .Day, unit: .TSS, type: .Point, axis: .Secondary, drawZeroes: false, priority: 1, format: GraphFormat(fill: true, colour: .yellow, fillGradientStart: .yellow, fillGradientEnd: .yellow, gradientAngle: 0.0, size: 1.0))
                        
                        tsbGraph.graph!.startFromOrigin = true
                        ctlGraph.graph!.startFromOrigin = true
                        atlGraph.graph!.startFromOrigin = true
                        
                        //add to array controller
                        if let gac = graphArrayController{
                            gac.add(contentsOf: [tsbGraph,ctlGraph,atlGraph,tssGraph])
                        }
                        
                        add(graph: tsbGraph)
                        add(graph: ctlGraph)
                        add(graph: atlGraph)
                        add(graph: tssGraph)
                        
                    }
                }
            }
        }
    }

    
    private func createGraphDefinition(forActivity a: String, period p: Period, unit u: Unit, type t: ChartType, axis: Axis, drawZeroes: Bool, priority: Int,  format f: GraphFormat) -> ActivityGraphDefinition{
        
        let graphDetails = ActivityGraphDefinition(activity: a, unit: u, period: p)
        graphDetails.graph = GraphDefinition(name: graphDetails.name, axis: axis, type: t, format: f,drawZeroes: drawZeroes, priority: priority)
        //NOTE must sort out removing this observer when we remove the graph.
        updateData(forGraph: graphDetails)
        return graphDetails
        
    }
    


    
    private func addObservers(forGraph g: ActivityGraphDefinition){
        //if name changes we need to get new data
        g.addObserver(self, forKeyPath: "name", options: .new, context: nil)
    }
    
    private func removeObservers(forGraph g: ActivityGraphDefinition){
        g.removeObserver(self, forKeyPath: "name")
    }
    
    private func updateData(forGraph g:  ActivityGraphDefinition){
        if let td = trainingDiary{
            //check cache first
            if let cachedValues = cache[g.name]{
                g.cache = cachedValues
            }else{
                
                let values = td.valuesFor(activity: g.activity, activityType: g.activityType, equipment: ConstantString.EddingtonAll.rawValue, period: g.period, unit: g.unit)
                g.cache = values
                self.cache[g.name] = values
        
            }            
            updateForDateChange(forGraph: g)
        }
    }

    private func getXAxisLabels(fromDate from: Date, toDate to: Date) -> [String]{
        let gap = to.timeIntervalSince(from) / Double(Constants.numberOfXAxisLabels)
        var result: [String] = []
        result.append(from.dateOnlyShorterString())
        for i in 1...Constants.numberOfXAxisLabels{
            result.append(from.addingTimeInterval(TimeInterval.init(gap*Double(i))).dateOnlyShorterString())
        }
        return result
    }
    
    private func graphs() -> [ActivityGraphDefinition]{
        if let gac = graphArrayController{
            return gac.arrangedObjects as! [ActivityGraphDefinition]
        }else{
            return []
        }
    }
 
    private func saveCache(){
        let currentGraphs = graphArrayController.arrangedObjects as! [ActivityGraphDefinition]
        //store current graphs in to cache
        if currentGraphs.count > 0{
            if let t = trainingDiary{
                graphCache[t] = currentGraphs
                dataCache[t] = cache
            }
        }
    }
    
    //returns true if data was retreived from cache
    private func retrieveFromCache() -> Bool{
        if let t = trainingDiary{
            if let data = dataCache[t]{
                cache = data
            }
            if let graphs = graphCache[t]{
                if let gac = graphArrayController{
                    gac.add(contentsOf: graphs)
                    return true
                }
            }
        }
        
        return false
    }
    
}
