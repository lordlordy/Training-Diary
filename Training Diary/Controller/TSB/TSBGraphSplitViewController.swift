//
//  TSBGraphSplitViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 16/04/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Foundation

class TSBGraphSplitViewController: TrainingDiarySplitViewController{
    
    private let tsbGraph: GraphDefinition = GraphDefinition(name: "TSB", axis: .Primary, type: .Line, format: GraphFormat.init(fill: true, colour: .black, fillGradientStart: .red, fillGradientEnd: .blue, gradientAngle: 90.0, size: 1.0, opacity: 1.0), drawZeroes: true, priority: 4)
    private let ctlGraph: GraphDefinition = GraphDefinition(name: "CTL", axis: .Primary, type: .Line, format: GraphFormat.init(fill: false, colour: .red, fillGradientStart: .red, fillGradientEnd: .red, gradientAngle: 0.0, size: 2.0, opacity: 1.0), drawZeroes: true, priority: 3)
    private let atlGraph: GraphDefinition = GraphDefinition(name: "ATL", axis: .Primary, type: .Line, format: GraphFormat.init(fill: false, colour: .green, fillGradientStart: .green, fillGradientEnd: .green, gradientAngle: 0.0, size: 2.0, opacity: 1.0), drawZeroes: true, priority: 2)
    private let tssGraph: GraphDefinition = GraphDefinition(name: "TSS", axis: .Secondary, type: .Bar, format: GraphFormat.init(fill: true, colour: .black, fillGradientStart: .yellow, fillGradientEnd: .yellow, gradientAngle: 0.0, size: 1.0, opacity: 0.5), drawZeroes: false, priority: 1)
    
    private var end: Date = Date().endOfDay()
    private var start: Date = Date().addDays(numberOfDays: -365).startOfDay()
    private var activity: String = FixedActivity.Bike.rawValue


    private var dataCache: [String: [Unit: [(x: Double, y: Double)]]] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tsbGraph.startFromOrigin = true
        
        updateGraphs()
        
        if let gv = getGraphView(){
            gv.add(graph: tsbGraph)
            gv.add(graph: ctlGraph)
            gv.add(graph: atlGraph)
            gv.add(graph: tssGraph)
        }
    }
    
    func updateStart(toDate d: Date){
        start = d.startOfDay()
        updateGraphs()
    }
    
    func updateEnd(toDate d: Date){
        end = d.endOfDay()
        updateGraphs()
    }
    
    func updateStartAndEnd(start: Date, end: Date){
        self.start = start
        self.end = end
        updateGraphs()
    }
    
    func updateActivity(toActivity a: String){
        activity = a
        updateGraphs()
    }
    
    func clearCache(forActivity a: String){
        dataCache.removeValue(forKey: a)
    }
    
    func updateGraphs(){
        let data = getData(forActivity: activity)
        
        tsbGraph.data = data[Unit.TSB]!.filter({$0.x >= start.timeIntervalSinceReferenceDate && $0.x <= end.timeIntervalSinceReferenceDate})
        ctlGraph.data = data[Unit.CTL]!.filter({$0.x >= start.timeIntervalSinceReferenceDate && $0.x <= end.timeIntervalSinceReferenceDate})
        atlGraph.data = data[Unit.ATL]!.filter({$0.x >= start.timeIntervalSinceReferenceDate && $0.x <= end.timeIntervalSinceReferenceDate})
        tssGraph.data = data[Unit.TSS]!.filter({$0.x >= start.timeIntervalSinceReferenceDate && $0.x <= end.timeIntervalSinceReferenceDate})

        //only need to add labels to one graph. GraphView uses first labels it finds in a graph it's displaying
        tsbGraph.xAxisLabels = getXAxisLabels(fromDate: start, toDate: end)

        
        if let gv = getGraphView(){
            gv.chartTitle = activity + " Training Stress Balance"
            gv.needsDisplay = true
        }
    }
    
    private func getData(forActivity a: String) -> [Unit: [(x: Double, y: Double)]]{
        if let cache = dataCache[a]{
            return cache
        }else{
            //no cached data so lets create it
            var result: [Unit: [(x: Double, y: Double)]] = [:]
            if let td = trainingDiary{
                result[Unit.CTL] = td.valuesFor(dayType: ConstantString.EddingtonAll.rawValue, activity: a, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, period: .Day, aggregationMethod: .None, unit: .CTL).map({(x: $0.date.timeIntervalSinceReferenceDate, y: $0.value)})
                result[Unit.ATL] = td.valuesFor(dayType: ConstantString.EddingtonAll.rawValue, activity: a, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, period: .Day, aggregationMethod: .None, unit: .ATL).map({(x: $0.date.timeIntervalSinceReferenceDate, y: $0.value)})
                result[Unit.TSB] = td.valuesFor(dayType: ConstantString.EddingtonAll.rawValue, activity: a, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, period: .Day, aggregationMethod: .None, unit: .TSB).map({(x: $0.date.timeIntervalSinceReferenceDate, y: $0.value)})
                result[Unit.TSS] = td.valuesFor(dayType: ConstantString.EddingtonAll.rawValue, activity: a, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, period: .Day, aggregationMethod: .None, unit: .TSS).map({(x: $0.date.timeIntervalSinceReferenceDate, y: $0.value)})
                
                dataCache[a] = result
                
            }
            return result
        }
    }
    
    private func getGraphView() -> GraphView?{
        for v in childViewControllers{
            if let gvc = v as? TSBGraphViewController{
                return gvc.graphView
            }
        }
        return nil
    }
    
    private func getXAxisLabels(fromDate from: Date, toDate to: Date) -> [(x: Double, label: String)]{
        var result: [(x: Double, label: String)] = []
        let gap: DateComponents = DateComponents(day:7)
        var d: Date = from
        while d <= to{
            result.append((x: d.timeIntervalSinceReferenceDate, label: d.dateOnlyShorterString()))
            d = Calendar.current.date(byAdding: gap, to: d)!
        }

        return result
    }
    
}
