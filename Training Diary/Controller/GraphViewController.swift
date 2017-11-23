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
                print("Observation made on ActivityGraphDefinition with name: \(graphDefinition.name)")
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
        tsbGraphSetUp()
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
    private func tsbGraphSetUp(){
        if let fdp = fromDatePicker{
            if let tdp = toDatePicker{
                if let _ = trainingDiary{
                    if let gv = graphView{

                        let graph1Details = ActivityGraphDefinition(activity: .All, unit: .TSB, period: .Day)
                        let graph2Details = ActivityGraphDefinition(activity: .All, unit: .ATL, period: .Day)
                        let graph3Details = ActivityGraphDefinition(activity: .All, unit: .CTL, period: .Day)
                        let graph4Details = ActivityGraphDefinition(activity: .All, unit: .TSS, period: .Day)

                        
                        //NOTE must sort out removing this observer when we remove the graph.
                        graph1Details.addObserver(self, forKeyPath: "name", options: .new, context: nil)
                        graph2Details.addObserver(self, forKeyPath: "name", options: .new, context: nil)
                        graph3Details.addObserver(self, forKeyPath: "name", options: .new, context: nil)
                        graph4Details.addObserver(self, forKeyPath: "name", options: .new, context: nil)
                        
                        
                        graph1Details.graph = GraphView.GraphDefinition( axis: .Primary, type: .Line, fill: true, colour: NSColor.blue, fillGradientStart: NSColor.red, fillGradientEnd: NSColor.blue, gradientAngle: 90.0, name: graph1Details.name, lineWidth: 1.0, priority: 1)
                        graph2Details.graph = GraphView.GraphDefinition( axis: .Primary, type: .Line, fill: false, colour: NSColor.green, fillGradientStart: NSColor.green, fillGradientEnd: NSColor.green, gradientAngle: 0.0 , name: graph2Details.name, lineWidth: 1.0 , priority: 2)
                        graph3Details.graph = GraphView.GraphDefinition( axis: .Primary, type: .Line, fill: false, colour: NSColor.red, fillGradientStart: NSColor.red, fillGradientEnd: NSColor.red, gradientAngle: 0.0, name: graph3Details.name, lineWidth: 1.0, priority: 3)
                        graph4Details.graph = GraphView.GraphDefinition( axis: .Secondary, type: .Point, fill: true, colour: NSColor.yellow, fillGradientStart: NSColor.yellow, fillGradientEnd: NSColor.yellow, gradientAngle: 0.0, name: graph4Details.name, lineWidth: 1.0, priority: 1)
                        
                        updateData(forGraph: graph1Details)
                        updateData(forGraph: graph2Details)
                        updateData(forGraph: graph3Details)
                        updateData(forGraph: graph4Details)
                        
                        graphDataCache[graph1Details.name] = graph1Details
                        graphDataCache[graph2Details.name] = graph2Details
                        graphDataCache[graph3Details.name] = graph3Details
                        graphDataCache[graph4Details.name] = graph4Details
                        
                        //test for table
                        dataArray.append(graph1Details)
                        dataArray.append(graph2Details)
                        dataArray.append(graph3Details)
                        dataArray.append(graph4Details)

                        gv.xAxisLabelStrings = getXAxisLabels(fromDate: fdp.dateValue, toDate: tdp.dateValue)
                        gv.add(graph: graph1Details.graph!)
                        gv.add(graph: graph2Details.graph!)
                        gv.add(graph: graph3Details.graph!)
                        gv.add(graph: graph4Details.graph!)
                        
                    
                        
                    }
                }
            }
        }
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
