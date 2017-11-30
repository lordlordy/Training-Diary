//
//  GraphViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 18/11/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Cocoa


class GraphViewController: NSViewController {

    fileprivate struct Constants{
        static let numberOfXAxisLabels: Int = 12
    }
    
    //for the moment this is just to see if I can get table to work for the graphs
    @objc dynamic var dataArray: [ActivityGraphDefinition] = []{
        willSet{ oldArray = dataArray}
        didSet{ dataArrayChanged() }
    }
    //this is here for want of a better way to react to additions and removals from the data array.
    private var oldArray: [ActivityGraphDefinition]?
    //this cache is Training Diary specific so will need clearing if training diary is set different.
    private var cache: [String:[(date:Date, value:Double)]] = [:]
    
    @objc dynamic var trainingDiary: TrainingDiary?{
        didSet{
            trainingDiarySet()
            setUpSliders()
        }
    }
    
    @IBOutlet @objc weak var graphView: GraphView!
    @IBOutlet weak var fromDatePicker: NSDatePicker!
    @IBOutlet weak var toDatePicker: NSDatePicker!
    @IBOutlet weak var fromDateSlider: NSSlider!
    @IBOutlet weak var toDateSlider: NSSlider!
    @IBOutlet weak var activityComboBox: NSComboBox!
    
    @IBAction func activityChanged(_ sender: NSComboBox) {
        for graph in dataArray{
            graph.activityString = sender.stringValue
        }
        updateGraphs()
        graphView.needsDisplay = true
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
    
    
    override func viewWillAppear() {
        // need to figure out the switching of tabs / switching of training diaries. For now this will do
        if dataArray.count == 0{
            trainingDiarySet()
        }
    }
    
    
    //this observing needs to be moved in to TrainingDiary itself. Not sure at what point the observer can be added.
    func setTrainingDiary(_ td: TrainingDiary){
        self.trainingDiary = td
        td.addObserver(self, forKeyPath: TrainingDiaryProperty.ctlDays.rawValue, options: NSKeyValueObservingOptions.new, context: nil)
        td.addObserver(self, forKeyPath: TrainingDiaryProperty.atlDays.rawValue, options: NSKeyValueObservingOptions.new, context: nil)
        td.addObserver(self, forKeyPath: TrainingDiaryProperty.swimCTLDays.rawValue, options: NSKeyValueObservingOptions.new, context: nil)
        td.addObserver(self, forKeyPath: TrainingDiaryProperty.swimATLDays.rawValue, options: NSKeyValueObservingOptions.new, context: nil)
        td.addObserver(self, forKeyPath: TrainingDiaryProperty.bikeCTLDays.rawValue, options: NSKeyValueObservingOptions.new, context: nil)
        td.addObserver(self, forKeyPath: TrainingDiaryProperty.bikeATLDays.rawValue, options: NSKeyValueObservingOptions.new, context: nil)
        td.addObserver(self, forKeyPath: TrainingDiaryProperty.runCTLDays.rawValue, options: NSKeyValueObservingOptions.new, context: nil)
        td.addObserver(self, forKeyPath: TrainingDiaryProperty.runATLDays.rawValue, options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?){
        
        switch keyPath{
        case TrainingDiaryProperty.ctlDays.rawValue?, TrainingDiaryProperty.atlDays.rawValue?:
            trainingDiary?.calcTSB(forActivity: Activity.Gym, fromDate: (trainingDiary?.firstDayOfDiary!)!)
            trainingDiary?.calcTSB(forActivity: Activity.Walk, fromDate: (trainingDiary?.firstDayOfDiary!)!)
            trainingDiary?.calcTSB(forActivity: Activity.Other, fromDate: (trainingDiary?.firstDayOfDiary!)!)
            updateGraphs()
            graphView.needsDisplay = true
        case TrainingDiaryProperty.swimCTLDays.rawValue?, TrainingDiaryProperty.swimATLDays.rawValue?:
            trainingDiary?.calcTSB(forActivity: Activity.Swim, fromDate: (trainingDiary?.firstDayOfDiary!)!)
            updateGraphs()
            graphView.needsDisplay = true
        case TrainingDiaryProperty.bikeCTLDays.rawValue?, TrainingDiaryProperty.bikeATLDays.rawValue?:
            trainingDiary?.calcTSB(forActivity: Activity.Bike, fromDate: (trainingDiary?.firstDayOfDiary!)!)
            updateGraphs()
            graphView.needsDisplay = true
        case TrainingDiaryProperty.runCTLDays.rawValue?, TrainingDiaryProperty.runATLDays.rawValue?:
            trainingDiary?.calcTSB(forActivity: Activity.Run, fromDate: (trainingDiary?.firstDayOfDiary!)!)
            updateGraphs()
            graphView.needsDisplay = true
        case "name"?:
            if let graphDefinition = object as? ActivityGraphDefinition{
                updateData(forGraph: graphDefinition)
                graphView.needsDisplay = true
            }
        default:
            print("~~~~~~~ Am I meant to be observing key path \(String(describing: keyPath))")
        }
        
        
    }


    private func trainingDiarySet(){
        if let td = trainingDiary{
            if let fdp = fromDatePicker{
                if let tdp = toDatePicker{
                    if fdp.dateValue < td.firstDayOfDiary! || fdp.dateValue > td.lastDayOfDiary!{
                        fdp.dateValue  = td.firstDayOfDiary!
                    }
                    if tdp.dateValue < td.firstDayOfDiary! || tdp.dateValue > td.lastDayOfDiary!{
                        tdp.dateValue  = td.lastDayOfDiary!
                    }
                }
            }
        }
        initialSetUp()
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
    
    private func updateGraphs(){
        for graph in dataArray{
            updateData(forGraph: graph)
        }
    }
    
    private func updateForDateChange(){
        for g in dataArray{
            updateForDateChange(forGraph: g)
        }
    }
    
    private func updateForDateChange(forGraph g: ActivityGraphDefinition){
        if let fdp = fromDatePicker{
            if let tdp = toDatePicker{
                if let graph = graphView{
                    let filteredData = g.cache.filter({$0.date >= fdp.dateValue && $0.date <= tdp.dateValue})
                    g.graph?.data = filteredData
                    graph.xAxisLabelStrings = getXAxisLabels(fromDate: fdp.dateValue, toDate: tdp.dateValue)
            //        graph.updatePlotBounds()
                    graph.needsDisplay = true
                }
            }
        }
    }


    
    //sets up to a standard TSB view
    private func initialSetUp(){
        if let fdp = fromDatePicker{
            if let tdp = toDatePicker{
                if let _ = trainingDiary{
                    if let gv = graphView{
                        // this shouldn't be here. Will refactor out when sort out creating axes in GraphView
                        gv.xAxisLabelStrings = getXAxisLabels(fromDate: fdp.dateValue, toDate: tdp.dateValue)
                        gv.numberOfPrimaryAxisLines = 6
                        gv.numberOfSecondaryAxisLines = 8

                        let tsbGraph = createGraphDefinition(forActivity: .All, period: .Day, unit: .TSB, type: .Line, axis: .Primary, drawZeroes: true, priority: 4, format: GraphFormat(fill: true, colour: .blue, fillGradientStart: .red, fillGradientEnd: .blue, gradientAngle: 90.0, size: 1.0))
                        let ctlGraph = createGraphDefinition(forActivity: .All, period: .Day, unit: .CTL, type: .Line, axis: .Primary, drawZeroes: true, priority: 3, format: GraphFormat(fill: false, colour: .red, fillGradientStart: .red, fillGradientEnd: .red, gradientAngle: 0.0, size: 1.0))
                        let atlGraph = createGraphDefinition(forActivity: .All, period: .Day, unit: .ATL, type: .Line, axis: .Primary, drawZeroes: true, priority: 2, format: GraphFormat(fill: false, colour: .green, fillGradientStart: .green, fillGradientEnd: .green, gradientAngle: 0.0, size: 1.0))
                        let tssGraph = createGraphDefinition(forActivity: .All, period: .Day, unit: .TSS, type: .Point, axis: .Secondary, drawZeroes: false, priority: 1, format: GraphFormat(fill: true, colour: .yellow, fillGradientStart: .yellow, fillGradientEnd: .yellow, gradientAngle: 0.0, size: 1.0))
                        
                        
                        dataArray.append(tsbGraph)
                        dataArray.append(ctlGraph)
                        dataArray.append(atlGraph)
                        dataArray.append(tssGraph)
                        
                    }
                }
            }
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
    private func dataArrayChanged(){
        print("Array of graphs has changed. There were \(String(describing: oldArray?.count)) graphs")
        print("there are now \(dataArray.count) graphs")
        if (oldArray?.count)! > dataArray.count{
            //item removed
            for old in oldArray!{
                if !dataArray.contains(old){
                    print("\(old.name) removed")
                    remove(graph: old)
                }
            }
        }else{
            //item added
            for new in dataArray{
                if !(oldArray?.contains(new))!{
                    print("\(new.name) added")
                    add(graph: new)
                    updateData(forGraph: new)
                }
            }
        }
     }
    
    private func add(graph g: ActivityGraphDefinition){
        addObservers(forGraph: g)
        //test for table
        if let gv = graphView{
            gv.add(graph: g.graph!)
        }
    }
    
    private func remove(graph g: ActivityGraphDefinition){
        removeObservers(forGraph: g)
        if let gv = graphView{
            gv.remove(graph: g.graph!)
        }
        
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
    
 
}
