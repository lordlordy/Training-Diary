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
    @objc dynamic var dataArray: [ActivityGraphDefinition] = []
    private var graphDataCache: [String: ActivityGraphDefinition] = [:]

    
    @objc dynamic var trainingDiary: TrainingDiary?{
        didSet{
            trainingDiarySet()
            setUpSliders()
        }
    }
    
    @IBOutlet weak var graphView: GraphView!
    @IBOutlet weak var fromDatePicker: NSDatePicker!
    @IBOutlet weak var toDatePicker: NSDatePicker!
    @IBOutlet weak var fromDateSlider: NSSlider!
    @IBOutlet weak var toDateSlider: NSSlider!
    @IBOutlet weak var activityComboBox: NSComboBox!
    

    @IBAction func activityChanged(_ sender: NSComboBox) {
        for key in graphDataCache.keys{
            graphDataCache[key]?.activityString = sender.stringValue
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
        trainingDiarySet()
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
            if fromDatePicker!.dateValue < td.firstDayOfDiary! || fromDatePicker!.dateValue > td.lastDayOfDiary!{
                fromDatePicker!.dateValue  = td.firstDayOfDiary!
            }
            if toDatePicker!.dateValue < td.firstDayOfDiary! || toDatePicker!.dateValue > td.lastDayOfDiary!{
                toDatePicker!.dateValue  = td.lastDayOfDiary!
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
        for key in graphDataCache.keys{
            updateData(forGraph: graphDataCache[key]!)
        }
    }
    
    private func updateForDateChange(){
        if let fdp = fromDatePicker{
            if let tdp = toDatePicker{
                if let graph = graphView{
                    for key in graphDataCache.keys{
                        if let filteredData = graphDataCache[key]?.cache.filter({$0.date >= fdp.dateValue && $0.date <= tdp.dateValue}){
                            graphDataCache[key]?.graph?.data = filteredData
                            graph.needsDisplay = true
                        }
                    }
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

                        let tsbGraph = createGraphDefinition(forActivity: .All, period: .Day, unit: .TSB, type: .Line, axis: .Primary, priority: 4, format: GraphFormat(fill: true, colour: .blue, fillGradientStart: .red, fillGradientEnd: .blue, gradientAngle: 90.0, size: 1.0))
                        let ctlGraph = createGraphDefinition(forActivity: .All, period: .Day, unit: .CTL, type: .Line, axis: .Primary, priority: 3, format: GraphFormat(fill: false, colour: .red, fillGradientStart: .red, fillGradientEnd: .red, gradientAngle: 0.0, size: 1.0))
                        let atlGraph = createGraphDefinition(forActivity: .All, period: .Day, unit: .ATL, type: .Line, axis: .Primary, priority: 2, format: GraphFormat(fill: false, colour: .green, fillGradientStart: .green, fillGradientEnd: .green, gradientAngle: 0.0, size: 1.0))
                        let tssGraph = createGraphDefinition(forActivity: .All, period: .Day, unit: .TSS, type: .Point, axis: .Secondary, priority: 1, format: GraphFormat(fill: true, colour: .yellow, fillGradientStart: .yellow, fillGradientEnd: .yellow, gradientAngle: 0.0, size: 1.0))
                        
                        add(graph: tsbGraph)
                        add(graph: ctlGraph)
                        add(graph: atlGraph)
                        add(graph: tssGraph)
                    }
                }
            }
        }
    }

    
    private func createGraphDefinition(forActivity a: Activity, period p: Period, unit u: Unit, type t: GraphView.ChartType, axis: GraphView.Axis, priority: Int,  format f: GraphFormat) -> ActivityGraphDefinition{
        
        let graphDetails = ActivityGraphDefinition(activity: a, unit: u, period: p)
        graphDetails.graph = GraphView.GraphDefinition(name: graphDetails.name, axis: axis, type: t, format: f, priority: priority)
        //NOTE must sort out removing this observer when we remove the graph.
        updateData(forGraph: graphDetails)
        return graphDetails
        
    }
    
    private func add(graph g: ActivityGraphDefinition){
        addObservers(forGraph: g)
        //test for table
        dataArray.append(g)
        if let gv = graphView{
            gv.add(graph: g.graph!)
        }
    }
    
    private func addObservers(forGraph g: ActivityGraphDefinition){
        //if name changes we need to get new data
        g.addObserver(self, forKeyPath: "name", options: .new, context: nil)
    }
    
    private func updateData(forGraph g:  ActivityGraphDefinition){
        if let td = trainingDiary{
            if let _ = g.graph{
                let values = td.getValues(forActivity: g.activity, andUnit: g.unit)
                g.cache = values
                g.graph?.data = values
            }
        }
    }

    
    //this gets all data in the diary irrelevant of dates user selected. We will cache the data
    private func populate(graph: inout GraphView.GraphDefinition, forActivity a: Activity, unit u: Unit){
        if let td = trainingDiary{
            graph.data = td.getValues(forActivity: a, andUnit: u)
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
