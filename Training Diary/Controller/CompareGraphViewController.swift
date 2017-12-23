//
//  CompareGraphViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 01/12/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Cocoa

class CompareGraphViewController: NSViewController, GraphManagementDelegate, TrainingDiaryViewController {

    @objc dynamic var trainingDiary: TrainingDiary?
    
    @IBOutlet weak var graphView: GraphView!
    @IBOutlet var graphArrayController: GraphArrayController!
    
    private var cache: [TrainingDiary: [DatedActivityGraphDefinition]] = [:]
    
    
    //MARK: - @IBActions
    
    @IBAction func activityChange(_ sender: ActivityComboBox) {
        if let a = sender.selectedActivity(){
            for g in graphs(){
                g.activityString = a.rawValue
            }
        }
    }
    
    @IBAction func periodChange(_ sender: PeriodComboBox) {
        if let p = sender.selectedPeriod(){
            for g in graphs(){
                g.periodString = p.rawValue
            }
        }
    }
    
    @IBAction func unitChange(_ sender: UnitComboBox) {
        if let u = sender.selectedUnit(){
            for g in graphs(){
                g.unitString = u.rawValue
            }
        }
    }
    
    
    //These are dates from the graph with most dates. All other graphs are mapped to this.
    private var baseDates: [Date] = []
    
    override func viewDidLoad() {
        if let gac = graphArrayController{
            gac.graphManagementDelegate = self
        }
        if graphs().count == 0{
            initialSetUp()
        }
    }
    
    //MARK: - GraphManagementDelegate implemenation
    func add(graph: ActivityGraphDefinition) {
        addObservers(forGraph: graph)
        if let gv = graphView{
            updateData(forGraph: graph as! DatedActivityGraphDefinition)
            gv.add(graph: graph.graph!)
        }
    }
    
    func setDefaults(forGraph graph: ActivityGraphDefinition) {
        let g = graph as! DatedActivityGraphDefinition
        g.from = earliestDate().addingTimeInterval(TimeInterval(-Constant.SecondsPer365Days.rawValue)).startOfYear()
        g.to = g.from.endOfYear()
        g.graph!.name = String(g.to.year())
        g.graph!.format.colour = randomColour()
        g.graph!.format.fillGradientStart = g.graph!.format.colour
        g.graph!.format.fillGradientEnd = g.graph!.format.colour
        //set activity and such like to one of the current graphs as most likely person wants to compare like with like
        if graphs().count > 0{
            g.activityString = graphs()[0].activityString
            g.periodString = graphs()[0].periodString
            g.unitString = graphs()[0].unitString
            g.graph!.type = graphs()[0].graph!.type
            g.graph!.drawZero = graphs()[0].graph!.drawZero
            g.graph!.format.size = graphs()[0].graph!.format.size
            g.graph!.format.fill = graphs()[0].graph!.format.fill
        }
    
    }
    
    func remove(graph: ActivityGraphDefinition) {
        removeObservers(forGraph: graph)
        if let gv = graphView{
            gv.remove(graph: graph.graph!)
        }
    }
    
    //MARK: - TrainingDiaryViewController implementation
    
    func set(trainingDiary td: TrainingDiary){
        let currentGraphs = graphArrayController.arrangedObjects as! [DatedActivityGraphDefinition]
        //store current graphs in to cache
        if let t = trainingDiary{
            cache[t] = currentGraphs
        }
        self.trainingDiary = td
        //remove current graphs
        graphArrayController!.remove(contentsOf: currentGraphs)
        for g in currentGraphs{
            remove(graph: g)
        }
            //check if there's a store of graphs for this training diary otherwise do initial setup of graphs
        if let graphs = cache[td]{
            graphArrayController!.add(contentsOf: graphs)
            for g in graphs{
                add(graph: g)
            }
        }else{
            initialSetUp()
        }
        
    }

    //MARK: - Property observing
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?){
        
        switch keyPath{
        case ActivityGraphDefinition.ObserveKey.name.rawValue?, DatedActivityGraphDefinition.ObserveKey.to.rawValue?, DatedActivityGraphDefinition.ObserveKey.from.rawValue?:
            if let graphDefinition = object as? DatedActivityGraphDefinition{
                updateData(forGraph: graphDefinition)
                graphView.needsDisplay = true
            }
        default:
            print("~~~~~~~ Am I meant to be observing key path \(String(describing: keyPath))")
        }
        
        
    }
    
    //MARK: - Private Functions
    
    private func addObservers(forGraph g: ActivityGraphDefinition){
        //if name changes we need to get new data
        g.addObserver(self, forKeyPath: ActivityGraphDefinition.ObserveKey.name.rawValue, options: .new, context: nil)
        g.addObserver(self, forKeyPath: DatedActivityGraphDefinition.ObserveKey.to.rawValue, options: .new, context: nil)
        g.addObserver(self, forKeyPath: DatedActivityGraphDefinition.ObserveKey.from.rawValue, options: .new, context: nil)
    }
    
    private func removeObservers(forGraph g: ActivityGraphDefinition){
        g.removeObserver(self, forKeyPath: ActivityGraphDefinition.ObserveKey.name.rawValue)
        g.removeObserver(self, forKeyPath: DatedActivityGraphDefinition.ObserveKey.to.rawValue)
        g.removeObserver(self, forKeyPath: DatedActivityGraphDefinition.ObserveKey.from.rawValue)
    }
    
    private func updateData(forGraph graph: DatedActivityGraphDefinition){
        if let td = trainingDiary{
            if let g = graph.graph{
                let values = td.getValues(forActivity: graph.activity, andPeriod: graph.period, andUnit: graph.unit, fromDate: graph.from, toDate: graph.to)
                g.data = values
                if values.count > baseDates.count{
                    baseDates =  values.map({$0.date})
                    //changed base dates so need to update all graphs
                    mapToBaseDatesForAllGraphs()
                }else{
                    mapToBaseDates(forGraph: graph)
                }
               
            }
        }
        if let gv = graphView {gv.needsDisplay = true}
    }
    
    private func mapToBaseDatesForAllGraphs(){
        if let gac = graphArrayController{
            for graph in gac.arrangedObjects as! [DatedActivityGraphDefinition]{
                mapToBaseDates(forGraph: graph)
            }
        }
    }
    
    private func mapToBaseDates(forGraph graph: DatedActivityGraphDefinition){
        if baseDates.count > 0{
            if let g = graph.graph{
                let currentValues = g.data
                if currentValues.count > 0{
                    let gap = baseDates[0].timeIntervalSince(currentValues[0].date)
                    g.data = currentValues.map({($0.date.addingTimeInterval(gap), $0.value)})
                }
            }
        }
    }
    
    private func graphs() -> [DatedActivityGraphDefinition]{
        if let gac = graphArrayController{
            return gac.arrangedObjects as! [DatedActivityGraphDefinition]
        }else{
            return []
        }
    }
    
    private func initialSetUp(){
        if let gv = graphView{
            // this shouldn't be here. Will refactor out when sort out creating axes in GraphView
            gv.numberOfPrimaryAxisLines = 6

            let start2017 = Calendar.current.date(from: DateComponents.init( year: 2017, month: 1, day: 1))
            let end2017 = Calendar.current.date(from: DateComponents.init( year: 2017, month: 12, day: 31))
            let start2016 = Calendar.current.date(from: DateComponents.init( year: 2016, month: 1, day: 1))
            let end2016 = Calendar.current.date(from: DateComponents.init( year: 2016, month: 12, day: 31))

            let runGraph2017GD = GraphView.GraphDefinition(name: "2017", axis: .Primary, type: .Line, format: GraphFormat.init(fill: false, colour: .blue, fillGradientStart: .blue, fillGradientEnd: .blue, gradientAngle: 0.0, size: 2.0), drawZeroes: true, priority: 1)
            let runGraph2016GD = GraphView.GraphDefinition(name: "2016", axis: .Primary, type: .Line, format: GraphFormat.init(fill: false, colour: .red, fillGradientStart: .red, fillGradientEnd: .red, gradientAngle: 0.0, size: 2.0), drawZeroes: true, priority: 2)

            let runGraph2017 = DatedActivityGraphDefinition(graph: runGraph2017GD, activity: .Run, unit: .Miles, period: .YearToDate, fromDate: start2017!, toDate: end2017!)
            let runGraph2016 = DatedActivityGraphDefinition(graph: runGraph2016GD, activity: .Run, unit: .Miles, period: .YearToDate, fromDate: start2016!, toDate: end2016!)
            
            runGraph2016.graph!.drawZero = false
            runGraph2017.graph!.drawZero = false
           
            // add to ArrayController first so they are here when we add into plot - this is needed to adjust dates to
            // same axis.
            if let gac = graphArrayController{
                gac.add(contentsOf: [runGraph2017, runGraph2016 ])
            }
            
            add(graph: runGraph2017)
            add(graph: runGraph2016)
            
            gv.xAxisLabelStrings = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
            

        }
    }
    
    private func earliestDate() -> Date{
        var earliest: Date = Date()
        
        for g in graphs(){
            if g.from < earliest{ earliest = g.from}
        }
        
        return earliest
    }
    
    private func randomColour() -> NSColor{
        return NSColor(calibratedRed: random(), green: random(), blue: random(), alpha: 1.0)
    }
    
    private func random() -> CGFloat{
        let r = CGFloat(arc4random()) / CGFloat(UInt32.max)
        print(r)
        return r
    }
    
    
}
