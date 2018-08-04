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
        case actualThenPlanTSB, actualThenPlanCTL, actualThenPlanATL
        case actualTSB, actualCTL, actualATL, actualTSS
        
        static let allNames: [GraphName] = [.planTSB, .planCTL, .planATL, .planTSS,.actualThenPlanTSB, .actualThenPlanCTL, .actualThenPlanATL, .actualTSS, actualTSB, actualCTL, actualATL]
        static let planName: [GraphName] = [.planTSB, .planCTL, .planATL, .planTSS]
        static let actualThenPlanName: [GraphName] = [.actualThenPlanTSB, .actualThenPlanCTL, .actualThenPlanATL]
        static let actualName: [GraphName] = [.actualTSB, .actualCTL, .actualATL, .actualTSS]
        static let atlNames: [GraphName] = [.planATL, actualThenPlanATL, .actualATL]
        static let ctlNames: [GraphName] = [.planCTL, actualThenPlanCTL, .actualCTL]
        static let tsbNames: [GraphName] = [.planTSB, actualThenPlanTSB, actualTSB]
        static let tssNames: [GraphName] = [.planTSS, actualTSS]
        
    }
    
    enum ActualThenPlanNames: String{
        case all = "All"
        case actualOnly = "Actual Only"
        case actualThenPlan = "Actual Then Plan"
        case actualThenDecay = "Actual Then Decay"
    }
    
    private let tsbGraph: GraphDefinition = GraphDefinition(name: GraphName.planTSB.rawValue, axis: .Primary, type: .Line, format: GraphFormat.init(fill: true, colour: .darkGray, fillGradientStart: .red, fillGradientEnd: .blue, gradientAngle: 90.0, size: 1.0, opacity: 1.0), drawZeroes: true, priority: 8)
    private let ctlGraph: GraphDefinition = GraphDefinition(name: GraphName.planCTL.rawValue, axis: .Primary, type: .Line, format: GraphFormat.init(fill: false, colour: .red, fillGradientStart: .red, fillGradientEnd: .red, gradientAngle: 0.0, size: 2.0, opacity: 1.0), drawZeroes: true, priority: 7)
    private let atlGraph: GraphDefinition = GraphDefinition(name: GraphName.planATL.rawValue, axis: .Primary, type: .Line, format: GraphFormat.init(fill: false, colour: .blue, fillGradientStart: .blue, fillGradientEnd: .blue, gradientAngle: 0.0, size: 2.0, opacity: 1.0), drawZeroes: true, priority: 6)
    private let tssGraph: GraphDefinition = GraphDefinition(name: GraphName.planTSS.rawValue, axis: .Secondary, type: .Bar, format: GraphFormat.init(fill: true, colour: .black, fillGradientStart: .yellow, fillGradientEnd: .yellow, gradientAngle: 0.0, size: 1.0, opacity: 0.5), drawZeroes: false, priority: 5)
    
    private let tsbGraphActualThenPlan: GraphDefinition = GraphDefinition(name: GraphName.actualThenPlanTSB.rawValue, axis: .Primary, type: .Line, format: GraphFormat.init(fill: false, colour: .black, fillGradientStart: .red, fillGradientEnd: .blue, gradientAngle: 90.0, size: 3.0, opacity: 1.0), drawZeroes: true, priority: 4)
    private let ctlGraphActualThenPlan: GraphDefinition = GraphDefinition(name: GraphName.actualThenPlanCTL.rawValue, axis: .Primary, type: .Line, format: GraphFormat.init(fill: false, colour: NSColor.white, fillGradientStart: .systemPink, fillGradientEnd: .systemPink, gradientAngle: 0.0, size: 2.0, opacity: 1.0), drawZeroes: true, priority: 3)
    private let atlGraphActualThenPlan: GraphDefinition = GraphDefinition(name: GraphName.actualThenPlanATL.rawValue, axis: .Primary, type: .Line, format: GraphFormat.init(fill: false, colour: NSColor.cyan, fillGradientStart: .cyan, fillGradientEnd: .cyan, gradientAngle: 0.0, size: 2.0, opacity: 1.0), drawZeroes: true, priority: 2)

    
    
    private let tsbGraphActual: GraphDefinition = GraphDefinition(name: GraphName.actualTSB.rawValue, axis: .Primary, type: .Line, format: GraphFormat.init(fill: false, colour: .black, fillGradientStart: .red, fillGradientEnd: .blue, gradientAngle: 90.0, size: 3.0, opacity: 1.0), drawZeroes: true, priority: 4)
    private let ctlGraphActual: GraphDefinition = GraphDefinition(name: GraphName.actualCTL.rawValue, axis: .Primary, type: .Line, format: GraphFormat.init(fill: false, colour: NSColor.white, fillGradientStart: .systemPink, fillGradientEnd: .systemPink, gradientAngle: 0.0, size: 2.0, opacity: 1.0), drawZeroes: true, priority: 3)
    private let atlGraphActual: GraphDefinition = GraphDefinition(name: GraphName.actualATL.rawValue, axis: .Primary, type: .Line, format: GraphFormat.init(fill: false, colour: NSColor.cyan, fillGradientStart: .cyan, fillGradientEnd: .cyan, gradientAngle: 0.0, size: 2.0, opacity: 1.0), drawZeroes: true, priority: 2)
    private let tssGraphActual: GraphDefinition = GraphDefinition(name: GraphName.actualTSS.rawValue, axis: .Secondary, type: .TBar, format: GraphFormat.init(fill: true, colour: .systemPink, fillGradientStart: .green, fillGradientEnd: .green, gradientAngle: 0.0, size: 2.0, opacity: 1.0), drawZeroes: false, priority: 1)
    
    
    private var planGraphs: [GraphDefinition] = []
    private var actualThenPlanGraphs: [GraphDefinition] = []
    private var actualGraphs: [GraphDefinition] = []
    private var planGraphStates: [String: NSControl.StateValue ] = [:]
    private var actualThenPlanGraphStates: [String: NSControl.StateValue ] = [:]
    private var actualGraphStates: [String: NSControl.StateValue] = [:]

    private var cache: [PlanDay] = []
    
    @IBOutlet weak var graphView: GraphView!
    @IBOutlet weak var activityComboBox: NSComboBox!
    @IBOutlet weak var tsbComboBox: NSComboBox!
    @IBOutlet weak var planPopUpButton: NSPopUpButton!
    @IBOutlet weak var actualPopUpButton: NSPopUpButton!
    @IBOutlet weak var actualThenPlanComboBox: NSComboBox!
    
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
    
    @IBAction func actualThenPlanComboBoxChanged(_ sender: NSComboBox) {
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
        actualThenPlanGraphs = [tsbGraphActualThenPlan, atlGraphActualThenPlan, ctlGraphActualThenPlan, tssGraphActual]
        actualGraphs = [tsbGraphActual, atlGraphActual, ctlGraphActual]

        tsbGraph.startFromOrigin = true
//        tsbGraphActualThenPlan.startFromOrigin = true
//        tsbGraphActual.startFromOrigin = true
        
        tsbGraphActual.dash = [2.0, 2.0]
        atlGraphActual.dash = [3.0, 3.0]
        ctlGraphActual.dash = [4.0, 4.0]
        
        if let acb = activityComboBox{
            acb.stringValue = ActualThenPlanNames.all.rawValue
        }
        
    
        
        if let gv = graphView{
            for g in planGraphs{
                gv.add(graph: g)
            }
            for g in actualThenPlanGraphs{
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
        if cache.count > 0 {
            setXAxisLabels(from: cache[0].date!, to: cache[cache.count-1].date!, numberOfLabels: 6)
        }
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
            var filterOutPlanPostToday = false
            var filterOutDecayPostToday = false
            if let atpcb = actualThenPlanComboBox{
                switch atpcb.stringValue{
                case ActualThenPlanNames.all.rawValue:
                    filterOutPlanPostToday = false
                    filterOutDecayPostToday = false
                case ActualThenPlanNames.actualOnly.rawValue:
                    filterOutPlanPostToday = true
                    filterOutDecayPostToday = true
                case ActualThenPlanNames.actualThenDecay.rawValue:
                    filterOutPlanPostToday = true
                    filterOutDecayPostToday = false
                case ActualThenPlanNames.actualThenPlan.rawValue:
                    filterOutPlanPostToday = false
                    filterOutDecayPostToday = true
                default:
                    print("Unknow value for ActualThenPlanComboBox: \(atpcb.stringValue)")
                }
            }
            switch a{
            case "Swim":
                tsbGraph.data = getData(forProperty: .swimTSB)
                atlGraph.data = getData(forProperty: .swimATL)
                ctlGraph.data = getData(forProperty: .swimCTL)
                tssGraph.data = getData(forProperty: .swimTSS)
                
                tsbGraphActual.data = getData(forProperty: .actualSwimTSB, filterOutPostToday: filterOutDecayPostToday)
                atlGraphActual.data = getData(forProperty: .actualSwimATL, filterOutPostToday: filterOutDecayPostToday)
                ctlGraphActual.data = getData(forProperty: .actualSwimCTL, filterOutPostToday: filterOutDecayPostToday)
                tssGraphActual.data = getData(forProperty: .actualSwimTSS)

                tsbGraphActualThenPlan.data = getData(forProperty: .actualThenPlanSwimTSB, filterOutPostToday: filterOutPlanPostToday)
                atlGraphActualThenPlan.data = getData(forProperty: .actualThenPlanSwimATL, filterOutPostToday: filterOutPlanPostToday)
                ctlGraphActualThenPlan.data = getData(forProperty: .actualThenPlanSwimCTL, filterOutPostToday: filterOutPlanPostToday)
            case "Bike":
                tsbGraph.data = getData(forProperty: .bikeTSB)
                atlGraph.data = getData(forProperty: .bikeATL)
                ctlGraph.data = getData(forProperty: .bikeCTL)
                tssGraph.data = getData(forProperty: .bikeTSS)

                tsbGraphActual.data = getData(forProperty: .actualBikeTSB, filterOutPostToday: filterOutDecayPostToday)
                atlGraphActual.data = getData(forProperty: .actualBikeATL, filterOutPostToday: filterOutDecayPostToday)
                ctlGraphActual.data = getData(forProperty: .actualBikeCTL, filterOutPostToday: filterOutDecayPostToday)
                tssGraphActual.data = getData(forProperty: .actualBikeTSS)

                tsbGraphActualThenPlan.data = getData(forProperty: .actualThenPlanBikeTSB, filterOutPostToday: filterOutPlanPostToday)
                atlGraphActualThenPlan.data = getData(forProperty: .actualThenPlanBikeATL, filterOutPostToday: filterOutPlanPostToday)
                ctlGraphActualThenPlan.data = getData(forProperty: .actualThenPlanBikeCTL, filterOutPostToday: filterOutPlanPostToday)
            case "Run":
                tsbGraph.data = getData(forProperty: .runTSB)
                atlGraph.data = getData(forProperty: .runATL)
                ctlGraph.data = getData(forProperty: .runCTL)
                tssGraph.data = getData(forProperty: .runTSS)
                
                tsbGraphActual.data = getData(forProperty: .actualRunTSB, filterOutPostToday: filterOutDecayPostToday)
                atlGraphActual.data = getData(forProperty: .actualRunATL, filterOutPostToday: filterOutDecayPostToday)
                ctlGraphActual.data = getData(forProperty: .actualRunCTL, filterOutPostToday: filterOutDecayPostToday)
                tssGraphActual.data = getData(forProperty: .actualRunTSS)

                tsbGraphActualThenPlan.data = getData(forProperty: .actualThenPlanRunTSB, filterOutPostToday: filterOutPlanPostToday)
                atlGraphActualThenPlan.data = getData(forProperty: .actualThenPlanRunATL, filterOutPostToday: filterOutPlanPostToday)
                ctlGraphActualThenPlan.data = getData(forProperty: .actualThenPlanRunCTL, filterOutPostToday: filterOutPlanPostToday)
            case "All":
                tsbGraph.data = getData(forProperty: .allTSB)
                atlGraph.data = getData(forProperty: .allATL)
                ctlGraph.data = getData(forProperty: .allCTL)
                tssGraph.data = getData(forProperty: .allTSS)
                
                tsbGraphActual.data = getData(forProperty: .actualAllTSB, filterOutPostToday: filterOutDecayPostToday)
                atlGraphActual.data = getData(forProperty: .actualAllATL, filterOutPostToday: filterOutDecayPostToday)
                ctlGraphActual.data = getData(forProperty: .actualAllCTL, filterOutPostToday: filterOutDecayPostToday)
                tssGraphActual.data = getData(forProperty: .actualAllTSS)

                tsbGraphActualThenPlan.data = getData(forProperty: .actualThenPlanAllTSB, filterOutPostToday: filterOutPlanPostToday)
                atlGraphActualThenPlan.data = getData(forProperty: .actualThenPlanAllATL, filterOutPostToday: filterOutPlanPostToday)
                ctlGraphActualThenPlan.data = getData(forProperty: .actualThenPlanAllCTL, filterOutPostToday: filterOutPlanPostToday)
            default:
                print("Shouldn't be able to select \(a)")
            }
            graphView!.needsDisplay = true
        }
    }
    
    
    private func getData(forProperty p: PlanDayProperty, filterOutPostToday: Bool? = false) -> [(x: Double, y: Double)]{
        if filterOutPostToday!{
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
            for g in actualThenPlanGraphs{
                let item = p.menu!.addItem(withTitle: g.name, action: #selector(PlanGraphViewController.actualPopUpSelected), keyEquivalent: "")
                item.target = self
                item.representedObject = g
                item.state = .on
                actualThenPlanGraphStates[g.name] = .on
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
        if let s = actualThenPlanGraphStates[name]{
            if s == .on{
                actualThenPlanGraphStates[name] = .off
            }else{
                actualThenPlanGraphStates[name] = .on
            }
        }
        for g in actualThenPlanGraphs{
            if let s = actualThenPlanGraphStates[g.name]{
                if s == .on{
                    g.display = true
                }else{
                    g.display = false
                }
            }
        }
        for i in actualPopUpButton!.menu!.items{
            if let s = actualThenPlanGraphStates[i.title]{
                i.state = s
            }
        }
    }
    
    private func switchOnOnly(graphNames names: [GraphName]){
        let nameStrings = names.map({$0.rawValue})
        for g in actualThenPlanGraphs{
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
        for g in actualGraphs{
            if nameStrings.contains(g.name){
                g.display = true
            }else{
                g.display = false
            }
        }
    }

}
