//
//  GraphViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 18/11/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Cocoa


class GraphViewController: NSViewController, TrainingDiaryViewController, GraphManagementDelegate {

    fileprivate struct Constants{
        static let numberOfXAxisLabels: Int = 12
    }
    
    @IBOutlet var graphArrayController: GraphArrayController!

    //this cache is Training Diary specific so will need clearing if training diary is set different.
    private var cache: [String:[(date:Date, value:Double)]] = [:]
    private var graphCache: [TrainingDiary: [ActivityGraphDefinition]] = [:]
    private var dataCache: [TrainingDiary: [String:[(date:Date, value:Double)]]] = [:]
    
    @objc dynamic var trainingDiary: TrainingDiary?
    
    @IBOutlet weak var graphView: GraphView!
    @IBOutlet weak var fromDatePicker: NSDatePicker!
    @IBOutlet weak var toDatePicker: NSDatePicker!
    @IBOutlet weak var fromDateSlider: NSSlider!
    @IBOutlet weak var toDateSlider: NSSlider!
    @IBOutlet weak var activityComboBox: NSComboBox!
    
    @IBAction func activityChanged(_ sender: NSComboBox) {
        if let gac = graphArrayController{
            for graph in gac.arrangedObjects as! [ActivityGraphDefinition]{
                graph.activityString = sender.stringValue
            }
            updateGraphs()
            graphView.needsDisplay = true

        }
    }
    
    @IBAction func fromSlider(_ sender: NSSlider) {
        if let dp = fromDatePicker{
            let cal = Calendar.current
            var dc = cal.dateComponents([.day,.month,.year], from: dp.dateValue)
            dc.year = sender.integerValue
            let newDate = cal.date(from: dc)
            dp.dateValue = newDate!
            updateForDateChange()
        }
    }

    @IBAction func toSlider(_ sender: NSSlider) {
        if let dp = toDatePicker{
            let cal = Calendar.current
            var dc = cal.dateComponents([.day,.month,.year], from: dp.dateValue)
            dc.year = sender.integerValue
            let newDate = cal.date(from: dc)
            dp.dateValue = newDate!
            updateForDateChange()
        }
    }
    
    
    @IBAction func fromDateChanged(_ sender: NSDatePicker) {
        if let ds = fromDateSlider{
            let year = sender.dateValue.year()
            ds.doubleValue = Double(year)
        }
        updateForDateChange()
    }
    
    @IBAction func toDateChanged(_ sender: NSDatePicker) {
        if let ds = toDateSlider{
            let year = sender.dateValue.year()
            ds.doubleValue = Double(year)
        }
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
        
        
  //      trainingDiarySet()
   //     td.addObserver(self, forKeyPath: TrainingDiaryProperty.ctlDays.rawValue, options: NSKeyValueObservingOptions.new, context: nil)
     //   td.addObserver(self, forKeyPath: TrainingDiaryProperty.atlDays.rawValue, options: NSKeyValueObservingOptions.new, context: nil)
       // td.addObserver(self, forKeyPath: TrainingDiaryProperty.swimCTLDays.rawValue, options: NSKeyValueObservingOptions.new, context: nil)
//        td.addObserver(self, forKeyPath: TrainingDiaryProperty.swimATLDays.rawValue, options: NSKeyValueObservingOptions.new, context: nil)
  //      td.addObserver(self, forKeyPath: TrainingDiaryProperty.bikeCTLDays.rawValue, options: NSKeyValueObservingOptions.new, context: nil)
    //    td.addObserver(self, forKeyPath: TrainingDiaryProperty.bikeATLDays.rawValue, options: NSKeyValueObservingOptions.new, context: nil)
      //  td.addObserver(self, forKeyPath: TrainingDiaryProperty.runCTLDays.rawValue, options: NSKeyValueObservingOptions.new, context: nil)
        //td.addObserver(self, forKeyPath: TrainingDiaryProperty.runATLDays.rawValue, options: NSKeyValueObservingOptions.new, context: nil)
    }
    

    
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
 /*           case TrainingDiaryProperty.ctlDays.rawValue?, TrainingDiaryProperty.atlDays.rawValue?:
                trainingDiary?.calcTSB(forActivity: Activity.Gym, fromDate: (trainingDiary?.firstDayOfDiary)!)
                trainingDiary?.calcTSB(forActivity: Activity.Walk, fromDate: (trainingDiary?.firstDayOfDiary)!)
                trainingDiary?.calcTSB(forActivity: Activity.Other, fromDate: (trainingDiary?.firstDayOfDiary)!)
                updateGraphs()
                gv.needsDisplay = true
            case TrainingDiaryProperty.swimCTLDays.rawValue?, TrainingDiaryProperty.swimATLDays.rawValue?:
                trainingDiary?.calcTSB(forActivity: Activity.Swim, fromDate: (trainingDiary?.firstDayOfDiary)!)
                updateGraphs()
                gv.needsDisplay = true
            case TrainingDiaryProperty.bikeCTLDays.rawValue?, TrainingDiaryProperty.bikeATLDays.rawValue?:
                trainingDiary?.calcTSB(forActivity: Activity.Bike, fromDate: (trainingDiary?.firstDayOfDiary)!)
                updateGraphs()
                gv.needsDisplay = true
            case TrainingDiaryProperty.runCTLDays.rawValue?, TrainingDiaryProperty.runATLDays.rawValue?:
                trainingDiary?.calcTSB(forActivity: Activity.Run, fromDate: (trainingDiary?.firstDayOfDiary)!)
                updateGraphs()
                gv.needsDisplay = true
 */
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
    
 /*   private func trainingDiarySet(){
        if let td = trainingDiary{
            if let fdp = fromDatePicker{
                if let tdp = toDatePicker{
                    if fdp.dateValue < td.firstDayOfDiary || fdp.dateValue > td.lastDayOfDiary{
                        fdp.dateValue  = td.firstDayOfDiary
                    }
                    if tdp.dateValue < td.firstDayOfDiary || tdp.dateValue > td.lastDayOfDiary{
                        tdp.dateValue  = td.lastDayOfDiary
                    }
                }
            }
        }
        initialSetUp()
    }
   */

    
    private func updateGraphs(){
        if let gac = graphArrayController{
            for graph in gac.arrangedObjects as! [ActivityGraphDefinition]{
                updateData(forGraph: graph)
            }

        }
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
                    let from = td.firstDayOfDiary
                    let to = td.lastDayOfDiary
                    fdp.dateValue = from
                    tdp.dateValue = to
                    //date picker dates set. Now set up sliders
                    setUpSliders()
                    if let gv = graphView{
                        // this shouldn't be here. Will refactor out when sort out creating axes in GraphView
                        gv.xAxisLabelStrings = getXAxisLabels(fromDate: from, toDate: to)
                        gv.numberOfPrimaryAxisLines = 6
                        gv.numberOfSecondaryAxisLines = 8

                        let tsbGraph = createGraphDefinition(forActivity: .All, period: .Day, unit: .TSB, type: .Line, axis: .Primary, drawZeroes: true, priority: 4, format: GraphFormat(fill: true, colour: .blue, fillGradientStart: .red, fillGradientEnd: .blue, gradientAngle: 90.0, size: 1.0))
                        let ctlGraph = createGraphDefinition(forActivity: .All, period: .Day, unit: .CTL, type: .Line, axis: .Primary, drawZeroes: true, priority: 3, format: GraphFormat(fill: false, colour: .red, fillGradientStart: .red, fillGradientEnd: .red, gradientAngle: 0.0, size: 1.0))
                        let atlGraph = createGraphDefinition(forActivity: .All, period: .Day, unit: .ATL, type: .Line, axis: .Primary, drawZeroes: true, priority: 2, format: GraphFormat(fill: false, colour: .green, fillGradientStart: .green, fillGradientEnd: .green, gradientAngle: 0.0, size: 1.0))
                        let tssGraph = createGraphDefinition(forActivity: .All, period: .Day, unit: .TSS, type: .Point, axis: .Secondary, drawZeroes: false, priority: 1, format: GraphFormat(fill: true, colour: .yellow, fillGradientStart: .yellow, fillGradientEnd: .yellow, gradientAngle: 0.0, size: 1.0))
                        
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

    private func setUpSliders(){
        let firstYear = trainingDiary!.firstYear()
        let lastYear = trainingDiary!.lastYear()
        let range = lastYear - firstYear
        if let fds = fromDateSlider{
            fds.maxValue = Double(lastYear)
            fds.minValue = Double(firstYear)
            fds.numberOfTickMarks = range + 1
            fds.doubleValue = fds.minValue
        }
        if let tds = toDateSlider{
            tds.maxValue = Double(lastYear)
            tds.minValue = Double(firstYear)
            tds.numberOfTickMarks = range + 1
            tds.doubleValue = tds.maxValue
        }
    }
    
    private func createGraphDefinition(forActivity a: Activity, period p: Period, unit u: Unit, type t: GraphView.ChartType, axis: GraphView.Axis, drawZeroes: Bool, priority: Int,  format f: GraphFormat) -> ActivityGraphDefinition{
        
        let graphDetails = ActivityGraphDefinition(activity: a, unit: u, period: p)
        graphDetails.graph = GraphView.GraphDefinition(name: graphDetails.name, axis: axis, type: t, format: f,drawZeroes: drawZeroes, priority: priority)
        //NOTE must sort out removing this observer when we remove the graph.
        updateData(forGraph: graphDetails)
        return graphDetails
        
    }
    
    // this is called when the dataArray is changed. So need to update our set of graphs
 /*   private func dataArrayChanged(){
        if (oldArray?.count)! > graphArray.count{
            //item removed
            for old in oldArray!{
                if !graphArray.contains(old){
                    print("\(old.name) removed")
                    remove(graph: old)
                }
            }
        }else{
            //item added
            for new in graphArray{
                if !(oldArray?.contains(new))!{
                    print("\(new.name) added")
                    add(graph: new)
                    updateData(forGraph: new)
                }
            }
        }
     }
  */

    
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
                let values = td.getValues(forActivity: g.activity, andPeriod: g.period, andUnit: g.unit)
                g.cache = values
                cache[g.name] = values
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
