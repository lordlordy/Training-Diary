//
//  CompareGraphViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 01/12/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Cocoa

class CompareGraphViewController: NSViewController, GraphManagementDelegate {

    @objc dynamic var trainingDiary: TrainingDiary?{
        didSet{
            initialSetUp()
        }
    }
    
    @IBOutlet weak var graphView: GraphView!
    @IBOutlet var graphArrayController: GraphArrayController!
    
    //These are dates from the graph with most dates. All other graphs are mapped to this.
    private var baseDates: [Date] = []
    
    override func viewDidLoad() {
        if let gac = graphArrayController{
            gac.graphManagementDelegate = self
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
    
    func remove(graph: ActivityGraphDefinition) {
        removeObservers(forGraph: graph)
        if let gv = graphView{
            gv.remove(graph: graph.graph!)
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
    
    private func initialSetUp(){
        if let gv = graphView{
            // this shouldn't be here. Will refactor out when sort out creating axes in GraphView
            gv.numberOfPrimaryAxisLines = 6

            let start2017 = Calendar.current.date(from: DateComponents.init( year: 2017, month: 1, day: 1))
            let end2017 = Calendar.current.date(from: DateComponents.init( year: 2017, month: 12, day: 31))
            let start2016 = Calendar.current.date(from: DateComponents.init( year: 2016, month: 1, day: 1))
            let end2016 = Calendar.current.date(from: DateComponents.init( year: 2016, month: 12, day: 31))

            let runGraph2017GD = GraphView.GraphDefinition(name: "run2017", axis: .Primary, type: .Line, format: GraphFormat.init(fill: false, colour: .blue, fillGradientStart: .blue, fillGradientEnd: .blue, gradientAngle: 0.0, size: 2.0), drawZeroes: true, priority: 1)
            let runGraph2016GD = GraphView.GraphDefinition(name: "run2016", axis: .Primary, type: .Line, format: GraphFormat.init(fill: false, colour: .red, fillGradientStart: .red, fillGradientEnd: .red, gradientAngle: 0.0, size: 2.0), drawZeroes: true, priority: 2)

            let runGraph2017 = DatedActivityGraphDefinition(graph: runGraph2017GD, activity: .Run, unit: .Miles, period: .YearToDate, fromDate: start2017!, toDate: end2017!)
            let runGraph2016 = DatedActivityGraphDefinition(graph: runGraph2016GD, activity: .Run, unit: .Miles, period: .YearToDate, fromDate: start2016!, toDate: end2016!)
            
            add(graph: runGraph2016)
            add(graph: runGraph2017)
            
            gv.xAxisLabelStrings = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
            
            if let gac = graphArrayController{
                gac.add(contentsOf: [runGraph2016, runGraph2017])
            }
        }
    }
    
}
