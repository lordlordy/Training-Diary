//
//  GraphSplitViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 28/03/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class GraphSplitViewController: TrainingDiarySplitViewController, GraphManagementDelegate{
   
    
    fileprivate struct Constants{
        static let numberOfXAxisLabels: Int = 12
    }
    
    @IBOutlet var graphArrayController: GraphArrayController!
    @objc dynamic var graphView: GraphView! {return getGraphView()}
    
    //this cache is Training Diary specific so will need clearing if training diary is set different.
    private var cache: [String:[(date:Date, value:Double)]] = [:]
    private var graphCache: [TrainingDiary: [ActivityGraphDefinition]] = [:]
    private var dataCache: [TrainingDiary: [String:[(date:Date, value:Double)]]] = [:]
    private var advanceDateComponent: DateComponents?
    private var retreatDateComponent: DateComponents?
    
    
    
    
    func graphPeriodChange(_ sender: PeriodTextField) {
        if let dc = sender.getNegativeDateComponentsEquivalent(){
            if let fdp = getFromDatePicker(){
                if let tdp = getToDatePicker(){
                    fdp.dateValue = Calendar.current.date(byAdding: dc, to: tdp.dateValue)!
                    updateForDateChange()
                }
            }
        }
        advanceDateComponent = sender.getDateComponentsEquivalent()
        retreatDateComponent = sender.getNegativeDateComponentsEquivalent()
    }
    
    func retreatAPeriod() {
        if let retreat = retreatDateComponent{
            advance(by: retreat)
        }
    }
    
    func advanceAPeriod() {
        if let a = advanceDateComponent{
            advance(by: a)
        }
    }
    
    func periodComboBoxChanged(_ sender: PeriodComboBox) {
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
    
    func activityChanged(_ sender: NSComboBox) {
        if let gac = graphArrayController{
            for graph in gac.arrangedObjects as! [ActivityGraphDefinition]{
                graph.activity = sender.stringValue
            }
            updateGraphs()
        }
    }
    
    func activityTypeChanged(_ sender: NSComboBox) {
        if let gac = graphArrayController{
            for graph in gac.arrangedObjects as! [ActivityGraphDefinition]{
                graph.activityType = sender.stringValue
            }
        }
    }
    
    func unitChanged(_ sender: UnitComboBox) {
        if let gac = graphArrayController{
            for graph in gac.arrangedObjects as! [ActivityGraphDefinition]{
                graph.unitString = sender.stringValue
            }
        }
    }
    
    func aggregationMethodChanged(_ sender: AggregationMethodComboBox) {
        if let gac = graphArrayController{
            for graph in gac.arrangedObjects as! [ActivityGraphDefinition]{
                graph.aggregationString = sender.stringValue
            }
        }
    }
    
    func updateForDateChange(){
        if let gac = graphArrayController{
            for g in gac.arrangedObjects as! [ActivityGraphDefinition]{
                updateForDateChange(forGraph: g)
            }
        }
    }
    
    //MARK: - GraphManagementDelegate implementation
    func add(graph: ActivityGraphDefinition){
        addObservers(forGraph: graph)
        if let gv = getGraphView(){
            gv.add(graph: graph.graph!)
        }
    }
    
    func setDefaults(forGraph graph: ActivityGraphDefinition){
        
    }
    
    func remove(graph: ActivityGraphDefinition){
        removeObservers(forGraph: graph)
        if let gv = getGraphView(){
            gv.remove(graph: graph.graph!)
        }
    }
    
    override func set(trainingDiary td: TrainingDiary){
        if let _ = trainingDiary{
            // we already have a diary. So first lets cache data we have
            saveCache()
            //now clear graphs
            for graph in graphs(){ remove(graph: graph) }
            if let gac = graphArrayController{ gac.remove(contentsOf: graphs()) }
        }
        super.set(trainingDiary:td)
        if retrieveFromCache(){
            for g in graphs(){ add(graph: g)}
        } else {
            initialSetUp()
        }
        
    }
    

    //MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let gac = graphArrayController{
            gac.graphManagementDelegate = self
        }
        if graphs().count == 0{
            initialSetUp()
        }
    }
    
    
    
    //MARK: - Property Observing
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?){
        
        if let gv = getGraphView(){
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
        if let fdp = getFromDatePicker(){
            if let tdp = getToDatePicker(){
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
        if let gv = getGraphView(){
            gv.needsDisplay = true
        }
    }
    

    
    private func updateForDateChange(forGraph g: ActivityGraphDefinition){
        if let fdp = getFromDatePicker(){
            if let tdp = getToDatePicker(){
                if let graph = getGraphView(){
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
        if let fdp = getFromDatePicker(){
            if let tdp = getToDatePicker(){
                if let td = trainingDiary{
                    let to = td.lastDayOfDiary
                    let from = to.addDays(numberOfDays: -365)
                    fdp.dateValue = from
                    tdp.dateValue = to
                    
                    if let gv = getGraphView(){
                        // this shouldn't be here. Will refactor out when sort out creating axes in GraphView
                        gv.xAxisLabelStrings = getXAxisLabels(fromDate: from, toDate: to)
                        gv.numberOfPrimaryAxisLines = 6
                        gv.numberOfSecondaryAxisLines = 8
                        
                        let strainGraph = createGraphDefinition(forActivity: FixedActivity.Bike.rawValue, period: .Day, unit: .Strain, aggregationMethod: .Sum, type: .Line, axis: .Primary, drawZeroes: true, priority: 1, format: GraphFormat(fill: false, colour: .red, fillGradientStart: .green, fillGradientEnd: .red, gradientAngle: 90, size: 2.0, opacity: 1.0))
                        let tssGraph = createGraphDefinition(forActivity: FixedActivity.Bike.rawValue, period: .Day, unit: .TSS, aggregationMethod: .Sum, type: .Point, axis: .Secondary, drawZeroes: false, priority: 2, format: GraphFormat(fill: true, colour: .black, fillGradientStart: .cyan, fillGradientEnd: .cyan, gradientAngle: 90.0, size: 6.0, opacity: 1.0))
                        let tssRweekGraph = createGraphDefinition(forActivity: FixedActivity.Bike.rawValue, period: .rWeek, unit: .TSS, aggregationMethod: .Mean, type: .Bar, axis: .Secondary, drawZeroes: false, priority: 3, format: GraphFormat(fill: true, colour: .black, fillGradientStart: .green, fillGradientEnd: .red, gradientAngle: 90.0, size: 1.0, opacity: 1.0))
                        
                        strainGraph.graph!.startFromOrigin = true
                        
                        //add to array controller
                        if let gac = graphArrayController{
                            gac.add(contentsOf: [strainGraph,tssGraph, tssRweekGraph])
                        }
                        
                        add(graph: strainGraph)
                        add(graph: tssGraph)
                        add(graph: tssRweekGraph)

                    }
                }
            }
        }
    }
    
    
    private func createGraphDefinition(forActivity a: String, period p: Period, unit u: Unit, aggregationMethod ag: AggregationMethod, type t: ChartType, axis: Axis, drawZeroes: Bool, priority: Int,  format f: GraphFormat) -> ActivityGraphDefinition{
        
        let graphDetails = ActivityGraphDefinition(activity: a, unit: u, period: p)
        graphDetails.aggregationMethod = ag
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
                
                let values = td.valuesFor(dayType: ConstantString.EddingtonAll.rawValue, activity: g.activity, activityType: g.activityType, equipment: ConstantString.EddingtonAll.rawValue, period: g.period, aggregationMethod: g.aggregationMethod, unit: g.unit)
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
    
    private func getGraphView() -> GraphView?{
        for vc in childViewControllers{
            if let graphVC = vc as? GraphViewController{
                return graphVC.graphView
            }
        }
        return nil
    }
    
    private func getFromDatePicker() -> NSDatePicker?{
        for vc in childViewControllers{
            if let graphVC = vc as? GraphListViewController{
                return graphVC.fromDatePicker
            }
        }
        return nil
    }
    
    private func getToDatePicker() -> NSDatePicker?{
        for vc in childViewControllers{
            if let graphVC = vc as? GraphListViewController{
                return graphVC.toDatePicker
            }
        }
        return nil
    }
    
}
