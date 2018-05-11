//
//  PlanGraphViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 22/04/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class PlanGraphViewController: NSViewController{
    
    enum GraphName: String{
        case planTSB, planCTL, planATL, planTSS
        case actualTSB, actualCTL, actualATL, actualTSS
        
        static let allNames: [GraphName] = [.planTSB, .planCTL, .planATL, .planTSS,.actualTSB, .actualCTL, .actualATL, .actualTSS]
        static let planName: [GraphName] = [.planTSB, .planCTL, .planATL, .planTSS]
        static let actualName: [GraphName] = [.actualTSB, .actualCTL, .actualATL, .actualTSS]
        static let atlNames: [GraphName] = [.planATL, actualATL]
        static let ctlNames: [GraphName] = [.planCTL, actualCTL]
        static let tsbNames: [GraphName] = [.planTSB, actualTSB]
        static let tssNames: [GraphName] = [.planTSS, actualTSS]
        
    }
    
    private let tsbGraph: GraphDefinition = GraphDefinition(name: GraphName.planTSB.rawValue, axis: .Primary, type: .Line, format: GraphFormat.init(fill: true, colour: .darkGray, fillGradientStart: .red, fillGradientEnd: .blue, gradientAngle: 90.0, size: 1.0, opacity: 1.0), drawZeroes: true, priority: 8)
    private let ctlGraph: GraphDefinition = GraphDefinition(name: GraphName.planCTL.rawValue, axis: .Primary, type: .Line, format: GraphFormat.init(fill: false, colour: .red, fillGradientStart: .red, fillGradientEnd: .red, gradientAngle: 0.0, size: 2.0, opacity: 1.0), drawZeroes: true, priority: 7)
    private let atlGraph: GraphDefinition = GraphDefinition(name: GraphName.planATL.rawValue, axis: .Primary, type: .Line, format: GraphFormat.init(fill: false, colour: .blue, fillGradientStart: .blue, fillGradientEnd: .blue, gradientAngle: 0.0, size: 2.0, opacity: 1.0), drawZeroes: true, priority: 6)
    private let tssGraph: GraphDefinition = GraphDefinition(name: GraphName.planTSS.rawValue, axis: .Secondary, type: .Bar, format: GraphFormat.init(fill: true, colour: .black, fillGradientStart: .yellow, fillGradientEnd: .yellow, gradientAngle: 0.0, size: 1.0, opacity: 0.5), drawZeroes: false, priority: 5)
    
    private let tsbGraphActual: GraphDefinition = GraphDefinition(name: GraphName.actualTSB.rawValue, axis: .Primary, type: .Line, format: GraphFormat.init(fill: false, colour: .black, fillGradientStart: .red, fillGradientEnd: .blue, gradientAngle: 90.0, size: 3.0, opacity: 1.0), drawZeroes: true, priority: 4)
    private let ctlGraphActual: GraphDefinition = GraphDefinition(name: GraphName.actualCTL.rawValue, axis: .Primary, type: .Line, format: GraphFormat.init(fill: false, colour: NSColor.yellow, fillGradientStart: .systemPink, fillGradientEnd: .systemPink, gradientAngle: 0.0, size: 2.0, opacity: 1.0), drawZeroes: true, priority: 3)
    private let atlGraphActual: GraphDefinition = GraphDefinition(name: GraphName.actualATL.rawValue, axis: .Primary, type: .Line, format: GraphFormat.init(fill: false, colour: NSColor.cyan, fillGradientStart: .cyan, fillGradientEnd: .cyan, gradientAngle: 0.0, size: 2.0, opacity: 1.0), drawZeroes: true, priority: 2)
    private let tssGraphActual: GraphDefinition = GraphDefinition(name: GraphName.actualTSS.rawValue, axis: .Secondary, type: .Bar, format: GraphFormat.init(fill: true, colour: .green, fillGradientStart: .green, fillGradientEnd: .green, gradientAngle: 0.0, size: 1.0, opacity: 0.5), drawZeroes: false, priority: 1)
    
    
    private var planGraphs: [GraphDefinition] = []
    private var actualGraphs: [GraphDefinition] = []
    private var planGraphStates: [String: NSControl.StateValue ] = [:]
    private var actualGraphStates: [String: NSControl.StateValue ] = [:]

    private var cache: [PlanDay] = []
    
    @IBOutlet weak var graphView: GraphView!
    @IBOutlet weak var activityComboBox: NSComboBox!
    @IBOutlet weak var tsbComboBox: NSComboBox!
    @IBOutlet weak var planPopUpButton: NSPopUpButton!
    @IBOutlet weak var actualPopUpButton: NSPopUpButton!
    @IBOutlet weak var actualPlanButton: NSButton!
    
    @IBAction func activityChanged(_ sender: Any) {
        setGraphsToSelectedActivity()
    }
    
    @IBAction func tsbComboBoxChanged(_ sender: Any) {
        switch tsbComboBox.stringValue{
        case "ATL": switchOnOnly(graphNames: GraphName.atlNames)
        case "CTL": switchOnOnly(graphNames: GraphName.ctlNames)
        case "TSB": switchOnOnly(graphNames: GraphName.tsbNames)
        case "TSS": switchOnOnly(graphNames: GraphName.tssNames)
        default: switchOnOnly(graphNames: GraphName.allNames)
        }
        if let gv = graphView{
            gv.needsDisplay = true
        }
    }
    
    
    
    @IBAction func actualPlanButtonChanged(_ sender: Any) {
        setGraphsToSelectedActivity()
    }
    
    @objc func planPopUpSelected(_ item: NSMenuItem){
        togglePlanState(forItem: item.title)
        if let gv = graphView{
            gv.needsDisplay = true
        }
    }
    
    
    @objc func actualPopUpSelected(_ item: NSMenuItem){
        toggleActualState(forItem: item.title)
        if let gv = graphView{
            gv.needsDisplay = true
        }
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        planGraphs = [tsbGraph, atlGraph, ctlGraph, tssGraph]
        actualGraphs = [tsbGraphActual, atlGraphActual, ctlGraphActual, tssGraphActual]
        
        tsbGraph.startFromOrigin = true
        tsbGraphActual.startFromOrigin = true
        
        if let acb = activityComboBox{
            acb.stringValue = "All"
        }
        
        if let gv = graphView{
            for g in planGraphs{
                gv.add(graph: g)
            }
            for g in actualGraphs{
                gv.add(graph: g)
            }
        }
        
        createPlanPopUpMenu()
    }
    
    func setCache(planDays: [PlanDay]){
        cache = planDays.sorted(by: {$0.date! < $1.date!})
        setGraphsToSelectedActivity()
        setXAxisLabels(from: cache[0].date!, to: cache[cache.count-1].date!, numberOfLabels: 6)
        graphView!.needsDisplay = true
    }
    
    private func setXAxisLabels(from: Date, to: Date, numberOfLabels: Int){
        let interval = to.timeIntervalSince(from) / Double(numberOfLabels - 1)
        var labels: [(x: Double, label: String)] = []
        labels.append((x: from.timeIntervalSinceReferenceDate, label: from.dateOnlyShorterString()))
        for i in 1...(numberOfLabels-1){
            let d = from.addingTimeInterval(interval * Double(i))
            labels.append((x: d.timeIntervalSinceReferenceDate, label: d.dateOnlyShorterString()))
        }
        if planGraphs.count > 0{
            planGraphs[0].xAxisLabels = labels
        }
    }
    
    private func setGraphsToSelectedActivity(){
        if let a = activityComboBox?.stringValue{
            var filterOutPostToday = false
            if let b = actualPlanButton{
                if b.state == .off{
                    filterOutPostToday = true
                }
            }
            switch a{
            case "Swim":
                tsbGraph.data = getData(forProperty: .swimTSB)
                atlGraph.data = getData(forProperty: .swimATL)
                ctlGraph.data = getData(forProperty: .swimCTL)
                tssGraph.data = getData(forProperty: .swimTSS)
                tsbGraphActual.data = getData(forProperty: .actualSwimTSB, filterOutPlanFromActual: filterOutPostToday)
                atlGraphActual.data = getData(forProperty: .actualSwimATL, filterOutPlanFromActual: filterOutPostToday)
                ctlGraphActual.data = getData(forProperty: .actualSwimCTL, filterOutPlanFromActual: filterOutPostToday)
                tssGraphActual.data = getData(forProperty: .actualSwimTSS, filterOutPlanFromActual: filterOutPostToday)
            case "Bike":
                tsbGraph.data = getData(forProperty: .bikeTSB)
                atlGraph.data = getData(forProperty: .bikeATL)
                ctlGraph.data = getData(forProperty: .bikeCTL)
                tssGraph.data = getData(forProperty: .bikeTSS)
                tsbGraphActual.data = getData(forProperty: .actualBikeTSB, filterOutPlanFromActual: filterOutPostToday)
                atlGraphActual.data = getData(forProperty: .actualBikeATL, filterOutPlanFromActual: filterOutPostToday)
                ctlGraphActual.data = getData(forProperty: .actualBikeCTL, filterOutPlanFromActual: filterOutPostToday)
                tssGraphActual.data = getData(forProperty: .actualBikeTSS, filterOutPlanFromActual: filterOutPostToday)
            case "Run":
                tsbGraph.data = getData(forProperty: .runTSB)
                atlGraph.data = getData(forProperty: .runATL)
                ctlGraph.data = getData(forProperty: .runCTL)
                tssGraph.data = getData(forProperty: .runTSS)
                tsbGraphActual.data = getData(forProperty: .actualRunTSB, filterOutPlanFromActual: filterOutPostToday)
                atlGraphActual.data = getData(forProperty: .actualRunATL, filterOutPlanFromActual: filterOutPostToday)
                ctlGraphActual.data = getData(forProperty: .actualRunCTL, filterOutPlanFromActual: filterOutPostToday)
                tssGraphActual.data = getData(forProperty: .actualRunTSS, filterOutPlanFromActual: filterOutPostToday)
            case "All":
                tsbGraph.data = getData(forProperty: .allTSB)
                atlGraph.data = getData(forProperty: .allATL)
                ctlGraph.data = getData(forProperty: .allCTL)
                tssGraph.data = getData(forProperty: .allTSS)
                tsbGraphActual.data = getData(forProperty: .actualAllTSB, filterOutPlanFromActual: filterOutPostToday)
                atlGraphActual.data = getData(forProperty: .actualAllATL, filterOutPlanFromActual: filterOutPostToday)
                ctlGraphActual.data = getData(forProperty: .actualAllCTL, filterOutPlanFromActual: filterOutPostToday)
                tssGraphActual.data = getData(forProperty: .actualAllTSS, filterOutPlanFromActual: filterOutPostToday)
            default:
                print("Shouldn't be able to select \(a)")
            }
            graphView!.needsDisplay = true
        }
    }
    
    
    private func getData(forProperty p: PlanDayProperty, filterOutPlanFromActual: Bool? = false) -> [(x: Double, y: Double)]{
        if filterOutPlanFromActual!{
            return cache.filter({$0.date! < Date().endOfDay()}).map({(x: $0.date!.timeIntervalSinceReferenceDate, y: $0.value(forKey: p.rawValue) as! Double)})
        }else{
            return cache.map({(x: $0.date!.timeIntervalSinceReferenceDate, y: $0.value(forKey: p.rawValue) as! Double)})
        }
    }
    
    
    /// set up the table header context menu for choosing the columns.
    private func createPlanPopUpMenu() {
        
        if let p = planPopUpButton{
            for g in planGraphs{
                let item = p.menu!.addItem(withTitle: g.name, action: #selector(PlanGraphViewController.planPopUpSelected), keyEquivalent: "")
                item.target = self
                item.representedObject = g
                item.state = .on
                planGraphStates[g.name] = .on
            }
        }
        if let p = actualPopUpButton{
            for g in actualGraphs{
                let item = p.menu!.addItem(withTitle: g.name, action: #selector(PlanGraphViewController.actualPopUpSelected), keyEquivalent: "")
                item.target = self
                item.representedObject = g
                item.state = .on
                actualGraphStates[g.name] = .on
            }
        }
    }
    
    private func togglePlanState(forItem name: String){
        if let s = planGraphStates[name]{
            if s == .on{
                planGraphStates[name] = .off
            }else{
                planGraphStates[name] = .on
            }
        }
        for g in planGraphs{
            if let s = planGraphStates[g.name]{
                if s == .on{
                    g.display = true
                }else{
                    g.display = false
                }
            }
        }
        for i in planPopUpButton!.menu!.items{
            if let s = planGraphStates[i.title]{
                i.state = s
            }
        }
    }
    
    private func toggleActualState(forItem name: String){
        if let s = actualGraphStates[name]{
            if s == .on{
                actualGraphStates[name] = .off
            }else{
                actualGraphStates[name] = .on
            }
        }
        for g in actualGraphs{
            if let s = actualGraphStates[g.name]{
                if s == .on{
                    g.display = true
                }else{
                    g.display = false
                }
            }
        }
        for i in actualPopUpButton!.menu!.items{
            if let s = actualGraphStates[i.title]{
                i.state = s
            }
        }
    }
    
    private func switchOnOnly(graphNames names: [GraphName]){
        let nameStrings = names.map({$0.rawValue})
        for g in actualGraphs{
            if nameStrings.contains(g.name){
                g.display = true
            }else{
                g.display = false
            }
        }
        for g in planGraphs{
            if nameStrings.contains(g.name){
                g.display = true
            }else{
                g.display = false
            }
        }
    }

}
