//
//  CompareGraphSplitViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 28/03/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class CompareGraphSplitViewController: TrainingDiarySplitViewController, GraphManagementDelegate {
    
    @IBOutlet var graphArrayController: GraphArrayController!
    
    //These are dates from the graph with most dates. All other graphs are mapped to this.
    private var baseDates: [Date] = []
    private var xAxisLabels: [(x: Double, label: String)] = []
    private var cache: [TrainingDiary: [DatedActivityGraphDefinition]] = [:]
    private var advanceDateComponent: DateComponents?
    private var retreatDateComponent: DateComponents?

    
    func retreatAPeriod() {
        if let retreat = retreatDateComponent{
            advanceGraphs(by: retreat)
        }
    }
    
    func advanceAPeriod() {
        if let advance = advanceDateComponent{
            advanceGraphs(by: advance)
        }
    }
    
    func graphLengthChange(dcEquiv: DateComponents, negativeDCEquiv: DateComponents) {
        
        updateGraphPeriodTo(dcEquiv)
        advanceDateComponent = dcEquiv
        retreatDateComponent = negativeDCEquiv
        
    }
    
    
    func activityChange(activity: String) {
        for g in graphs(){
            g.activity = activity
        }
    }
    
    func activityTypeChange(activityType: String) {
        for g in graphs(){
            g.activityType = activityType
        }
    }
    
    
    func periodChange(period: String) {
        for g in graphs(){
            g.periodString = period
        }
    }

    func aggregationMethodChange(aggregationMethod: String) {
        for g in graphs(){
            g.aggregationString = aggregationMethod
        }
    }
    
    func unitChange(unit: String) {
        for g in graphs(){
            g.unitString = unit
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let gac = graphArrayController{
            gac.graphManagementDelegate = self
        }
        initialSetUp()

    }
 
    //MARK: - TrainingDiaryViewController implementation
    
    override func set(trainingDiary td: TrainingDiary){
        super.set(trainingDiary: td)
        let currentGraphs = graphArrayController.arrangedObjects as! [DatedActivityGraphDefinition]
        //store current graphs in to cache
        if let t = trainingDiary{
            cache[t] = currentGraphs
        }
        super.set(trainingDiary: td)
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
    
    //MARK: - GraphManagementDelegate implemenation
    func add(graph: ActivityGraphDefinition) {
        addObservers(forGraph: graph)
        if let gv = getGraphView(){
            updateData(forGraph: graph as! DatedActivityGraphDefinition)
            gv.add(graph: graph.graph!)
        }
    }
    
    func setDefaults(forGraph graph: ActivityGraphDefinition) {
        if let g = graph as? DatedActivityGraphDefinition{
            g.from = earliestDate().addingTimeInterval(TimeInterval(-Constant.SecondsPer365Days.rawValue)).startOfYear()
            //      g.to = g.from.endOfYear()
            g.graph!.name = String(g.from.year())
            g.graph!.format.colour = randomColour()
            g.graph!.format.fillGradientStart = g.graph!.format.colour
            g.graph!.format.fillGradientEnd = g.graph!.format.colour
            //set activity and such like to one of the current graphs as most likely person wants to compare like with like
            if graphs().count > 0{
                g.activity = graphs()[0].activity
                g.activityType = graphs()[0].activityType
                g.periodString = graphs()[0].periodString
                g.unitString = graphs()[0].unitString
                g.aggregationString = graphs()[0].aggregationString
                g.graph!.type = graphs()[0].graph!.type
                g.graph!.drawZero = graphs()[0].graph!.drawZero
                g.graph!.format.size = graphs()[0].graph!.format.size
                g.graph!.format.fill = graphs()[0].graph!.format.fill
                g.to = g.from.addingTimeInterval(graphs()[0].to.timeIntervalSince(graphs()[0].from))
            }
        }
    }
    
    func remove(graph: ActivityGraphDefinition) {
        removeObservers(forGraph: graph)
        if let gv = getGraphView(){
            gv.remove(graph: graph.graph!)
        }
    }
    
    
    //MARK: - Property observing
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?){
        
        switch keyPath{
        case ActivityGraphDefinition.ObserveKey.name.rawValue?, DatedActivityGraphDefinition.ObserveKey.to.rawValue?, DatedActivityGraphDefinition.ObserveKey.from.rawValue?:
            if let graphDefinition = object as? DatedActivityGraphDefinition{
                updateData(forGraph: graphDefinition)
                if let gv = getGraphView(){
                    gv.needsDisplay = true
                }

            }
        default:
            print("~~~~~~~ Am I meant to be observing key path \(String(describing: keyPath))")
        }
        
        
    }
    
    //MARK: - Private
    
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
    
    
    private func getGraphView() -> GraphView?{
    
        for vc in children{
            if let graphVC = vc as? CompareGraphViewController{
                return graphVC.graphView
            }
        }
        
        return nil
    }
    
    private func graphs() -> [DatedActivityGraphDefinition]{
        if let gac = graphArrayController{
            return gac.arrangedObjects as! [DatedActivityGraphDefinition]
        }else{
            return []
        }
    }
    
    private func initialSetUp(){

        
        var end: Date = Date()
        if let td = trainingDiary{
            end = td.lastDayOfDiary
        }
        let start = end.startOfYear()
        let end2 = Calendar.current.date(byAdding: DateComponents(year:-1), to: end)!
        let start2 = end2.startOfYear()
        
        let hoursGraph = GraphDefinition(name: String(end.year()), axis: .Primary, type: .Line, format: GraphFormat.init(fill: true, colour: .red, fillGradientStart: .magenta, fillGradientEnd: .blue, gradientAngle: 90.0, size: 3.0, opacity: 1.0), drawZeroes: true, priority: 2)
        let hoursGraph2 = GraphDefinition(name: String(end2.year()), axis: .Primary, type: .Line, format: GraphFormat.init(fill: false, colour: .green, fillGradientStart: .blue, fillGradientEnd: .blue, gradientAngle: 0.0, size: 3.0, opacity: 1.0), drawZeroes: true, priority: 1)
        
        let datedHoursGraph = DatedActivityGraphDefinition(graph: hoursGraph, activity: ConstantString.EddingtonAll.rawValue, unit: .hours, period: .rWeek, fromDate: start, toDate: end)
        let datedHoursGraph2 = DatedActivityGraphDefinition(graph: hoursGraph2, activity: ConstantString.EddingtonAll.rawValue, unit: .hours, period: .rWeek, fromDate: start2, toDate: end2)
        
        // add to ArrayController first so they are here when we add into plot - this is needed to adjust dates to
        // same axis.
        if let gac = graphArrayController{
            gac.add(contentsOf: [datedHoursGraph, datedHoursGraph2 ])
        }
        
        add(graph: datedHoursGraph)
        add(graph: datedHoursGraph2)
        
        
    }
    
    private func earliestDate() -> Date{
        var earliest: Date = Date()
        
        for g in graphs(){
            if g.from < earliest{ earliest = g.from}
        }
        
        return earliest
    }
    
/*    private func setXAxisLabels(from: Date, to: Date){
        if let gv = getGraphView(){
            let gap = to.timeIntervalSince(from) / 12.0
            var labels: [String] = []
            let formatter: DateFormatter = DateFormatter()
            formatter.dateFormat = "dd-MMM"
            
            for i in 0...12{
                let d = from.addingTimeInterval(gap*Double(i))
                labels.append(formatter.string(from: d))
            }
            
            gv.xAxisLabelStrings = labels
        }
        
    }
  */
    private func randomColour() -> NSColor{
        return NSColor(calibratedRed: random(), green: random(), blue: random(), alpha: 1.0)
    }
    
    private func random() -> CGFloat{
        let r = CGFloat(arc4random()) / CGFloat(UInt32.max)
        return r
    }
    
    private func updateData(forGraph graph: DatedActivityGraphDefinition){
        if let td = trainingDiary{
            if let g = graph.graph{
                let values = td.valuesFor(dayType: ConstantString.EddingtonAll.rawValue, activity: graph.activity, activityType: graph.activityType, equipment: graph.equipment, period: graph.period, aggregationMethod: graph.aggregationMethod, unit: graph.unit, from: graph.from, to: graph.to)
                g.data = values.map({(x: $0.date.timeIntervalSinceReferenceDate, y: $0.value)})
                if values.count > baseDates.count{
                    baseDates =  values.map({$0.date})
                    //changed base dates so need to update all graphs
                    mapToBaseDatesForAllGraphs()
                }else{
                    mapToBaseDates(forGraph: graph)
                }
            }
        }
        graph.updateXAxisLabels()
        if let gv = getGraphView() {gv.needsDisplay = true}
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
                    let gap = baseDates[0].timeIntervalSinceReferenceDate - currentValues[0].x
                    g.data = currentValues.map({($0.x + gap, $0.y)})
                }
            }
        }
    }
    
    private func updateGraphPeriodTo(_ dc: DateComponents){
        for g in graphs(){
            g.to = Calendar.current.date(byAdding: dc, to: g.from) ?? g.to
        }        
    }
    
    private func advanceGraphs(by dc: DateComponents){
        for g in graphs(){
            g.to = Calendar.current.date(byAdding: dc, to: g.to) ?? g.to
            g.from = Calendar.current.date(byAdding: dc, to: g.from) ?? g.from
        }
    }

    
}




