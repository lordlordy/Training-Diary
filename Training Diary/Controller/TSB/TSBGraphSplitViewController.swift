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
    private let ctlGraph: GraphDefinition = GraphDefinition(name: "CTL", axis: .Primary, type: .Line, format: GraphFormat.init(fill: false, colour: .red, fillGradientStart: .red, fillGradientEnd: .red, gradientAngle: 0.0, size: 2.0, opacity: 1.0), drawZeroes: true, priority: 1)
    private let atlGraph: GraphDefinition = GraphDefinition(name: "ATL", axis: .Primary, type: .Line, format: GraphFormat.init(fill: false, colour: .green, fillGradientStart: .green, fillGradientEnd: .green, gradientAngle: 0.0, size: 2.0, opacity: 1.0), drawZeroes: true, priority: 2)
    private let tssGraph: GraphDefinition = GraphDefinition(name: "TSS", axis: .Secondary, type: .Bar, format: GraphFormat.init(fill: true, colour: .black, fillGradientStart: .yellow, fillGradientEnd: .yellow, gradientAngle: 0.0, size: 1.0, opacity: 0.5), drawZeroes: false, priority: 3)
    
    private var end: Date = Date().endOfDay()
    private var start: Date = Calendar.current.date(byAdding: DateComponents.init(month: -6), to: Date())!.startOfDay()
//    private var start: Date = Date().addDays(numberOfDays: -365).startOfDay()
    private var activity: String = ConstantString.EddingtonAll.rawValue

    private var dataCache: [String: [Unit: [(x: Double, y: Double)]]] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tsbGraph.startFromOrigin = true
        
        var start: Date = Date()
        updateGraphs()
        print("Updating TSB graphs took \(Date().timeIntervalSince(start))s")
        start = Date()
        
        if let gv = getGraphView(){
            gv.add(graph: tsbGraph)
            gv.add(graph: ctlGraph)
            gv.add(graph: atlGraph)
            gv.add(graph: tssGraph)
        }
        print("Adding TSB graphs to GraphView took \(Date().timeIntervalSince(start))s")
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
        
        tsbGraph.data = data[Unit.tsb]!.filter({$0.x >= start.timeIntervalSinceReferenceDate && $0.x <= end.timeIntervalSinceReferenceDate})
        ctlGraph.data = data[Unit.ctl]!.filter({$0.x >= start.timeIntervalSinceReferenceDate && $0.x <= end.timeIntervalSinceReferenceDate})
        atlGraph.data = data[Unit.atl]!.filter({$0.x >= start.timeIntervalSinceReferenceDate && $0.x <= end.timeIntervalSinceReferenceDate})
        tssGraph.data = data[Unit.tss]!.filter({$0.x >= start.timeIntervalSinceReferenceDate && $0.x <= end.timeIntervalSinceReferenceDate})

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
                var start: Date = Date()
                result[Unit.ctl] = td.valuesFor(dayType: ConstantString.EddingtonAll.rawValue, activity: a, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, period: .Day, aggregationMethod: .None, unit: .ctl).map({(x: $0.date.timeIntervalSinceReferenceDate, y: $0.value)})
                print("Getting \(a):CTL data took \(Date().timeIntervalSince(start))s")
                start = Date()
                result[Unit.atl] = td.valuesFor(dayType: ConstantString.EddingtonAll.rawValue, activity: a, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, period: .Day, aggregationMethod: .None, unit: .atl).map({(x: $0.date.timeIntervalSinceReferenceDate, y: $0.value)})
                print("Getting \(a):ATL data took \(Date().timeIntervalSince(start))s")
                start = Date()
                result[Unit.tsb] = td.valuesFor(dayType: ConstantString.EddingtonAll.rawValue, activity: a, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, period: .Day, aggregationMethod: .None, unit: .tsb).map({(x: $0.date.timeIntervalSinceReferenceDate, y: $0.value)})
                print("Getting \(a):TSB data took \(Date().timeIntervalSince(start))s")
                start = Date()
                result[Unit.tss] = td.valuesFor(dayType: ConstantString.EddingtonAll.rawValue, activity: a, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, period: .Day, aggregationMethod: .None, unit: .tss).map({(x: $0.date.timeIntervalSinceReferenceDate, y: $0.value)})
                print("Getting \(a):TSS data took \(Date().timeIntervalSince(start))s")

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
