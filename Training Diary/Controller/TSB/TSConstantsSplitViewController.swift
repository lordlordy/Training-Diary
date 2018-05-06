//
//  TSConstantsSplitViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 15/04/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Foundation

class TSBConstantsSplitViewController: TrainingDiarySplitViewController{
    
    
    private let effectGraph: GraphDefinition = GraphDefinition(name: "Effect", axis: .Primary, type: .Line, format: GraphFormat.init(fill: true, colour: .black, fillGradientStart: .red, fillGradientEnd: .blue, gradientAngle: 90.0, size: 2.0, opacity: 1.0), drawZeroes: true, priority: 1)
    
    private let ctlDecayGraph: GraphDefinition = GraphDefinition(name: "CTL Decay", axis: .Primary, type: .Line, format: GraphFormat.init(fill: false, colour: .red, fillGradientStart: .red, fillGradientEnd: .red, gradientAngle: 1.0, size: 2.0, opacity: 1.0), drawZeroes: true, priority: 1)
    
    private let atlDecayGraph: GraphDefinition = GraphDefinition(name: "ATL Decay", axis: .Primary, type: .Line, format: GraphFormat.init(fill: false, colour: .green, fillGradientStart: .red, fillGradientEnd: .red, gradientAngle: 1.0, size: 2.0, opacity: 1.0), drawZeroes: true, priority: 1)
    
    private let replacementTSSGraph: GraphDefinition = GraphDefinition(name: "Replacement TSS", axis: .Primary, type: .Line, format: GraphFormat.init(fill: false, colour: .blue, fillGradientStart: .red, fillGradientEnd: .red, gradientAngle: 1.0, size: 2.0, opacity: 1.0), drawZeroes: true, priority: 1)
    
    
    private var effectDataCache: [Activity: [(x:Double, y: Double)]] = [:]
    private var ctlDecayDataCache: [Activity: [(x:Double, y: Double)]] = [:]
    private var atlDecayDataCache: [Activity: [(x:Double, y: Double)]] = [:]
    private var replacementTSSDataCache: [Activity: [(x:Double, y: Double)]] = [:]
    
    private let effectXAxisLabels = ["-91", "-84", "-77", "-70", "-63", "-56", "-49", "-42", "-35", "-28", "-21", "-14", "-7", "Race"]
    private let decayXAxisLabels = ["0", "7", "14", "21", "28", "35", "42", "49", "56", "63", "70", "77", "84", "91d"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        effectGraph.data = effectData(forActivity: trainingDiary!.activity(forString: FixedActivity.Bike.rawValue)!)
        if let gv = getGraphView(){
            gv.add(graph: effectGraph)
            gv.xAxisLabelStrings = effectXAxisLabels
        }
        
        effectGraph.startFromOrigin = true
    
        
    }
    
    
    
    func recalculateData(forActivity a: Activity){
        
        effectDataCache.removeValue(forKey: a)
        ctlDecayDataCache.removeValue(forKey: a)
        atlDecayDataCache.removeValue(forKey: a)
        replacementTSSDataCache.removeValue(forKey: a)
        
        effectGraph.data = effectData(forActivity: a)
        ctlDecayGraph.data = ctlDecayData(forActivity: a)
        atlDecayGraph.data = atlDecayData(forActivity: a)
        replacementTSSGraph.data = replacementData(forActivity: a)
        
        if let gv = getGraphView(){
            gv.needsDisplay = true
        }
    }

    
    func setGraphTo(activity a: Activity, graphType: TSBConstantsViewController.GraphType){
        
        switch graphType{
        case .decay:
            ctlDecayGraph.data = ctlDecayData(forActivity: a)
            atlDecayGraph.data = atlDecayData(forActivity: a)
            if let gv = getGraphView(){
                gv.clearGraphs()
                gv.add(graph: ctlDecayGraph)
                gv.add(graph: atlDecayGraph)
                gv.xAxisLabelStrings = decayXAxisLabels
            }
        case .effect:
            effectGraph.data = effectData(forActivity: a)
            if let gv = getGraphView(){
                gv.clearGraphs()
                gv.add(graph: effectGraph)
                gv.xAxisLabelStrings = effectXAxisLabels
            }
        case .replacement:
            replacementTSSGraph.data = replacementData(forActivity: a)
            if let gv = getGraphView(){
                gv.clearGraphs()
                gv.add(graph: replacementTSSGraph)
                gv.xAxisLabelStrings = decayXAxisLabels
            }
        }
    
    }
    
    
    
    
    private func effectData(forActivity a: Activity) -> [(x: Double, y: Double)]{
        if let r = effectDataCache[a]{
            return r
        }else{
            var result: [(x: Double, y: Double)] = []
            for i in 0...91{
                result.append((x: Date().addDays(numberOfDays: i).timeIntervalSinceReferenceDate, y: a.effect(afterDays: Double(91-i))*100))
            }
            effectDataCache[a] = result
            return result
        }
    }
    
    private func ctlDecayData(forActivity a: Activity) -> [(x: Double, y: Double)]{
        if let r = ctlDecayDataCache[a]{
            return r
        }else{
            var result: [(x: Double, y: Double)] = []
            for i in 0...91{
                result.append((x: Date().addDays(numberOfDays: i).timeIntervalSinceReferenceDate, y: a.ctlDecayFactor(afterNDays: i)))
            }
            ctlDecayDataCache[a] = result
            return result
        }
    }

    private func atlDecayData(forActivity a: Activity) -> [(x: Double, y: Double)]{
        if let r = atlDecayDataCache[a]{
            return r
        }else{
            var result: [(x: Double, y: Double)] = []
            for i in 0...91{
                result.append((x: Date().addDays(numberOfDays: i).timeIntervalSinceReferenceDate, y: a.atlDecayFactor(afterNDays: i)))
            }
            atlDecayDataCache[a] = result
            return result
        }
    }

    private func replacementData(forActivity a: Activity) -> [(x: Double, y: Double)]{
        if let r = replacementTSSDataCache[a]{
            return r
        }else{
            var result: [(x: Double, y: Double)] = []
            for i in 0...91{
                result.append((x: Date().addDays(numberOfDays: i).timeIntervalSinceReferenceDate, y: a.ctlReplacementTSSFactor(afterNDays: i)))
            }
            replacementTSSDataCache[a] = result
            return result
        }
    }
    
    private func getGraphView() -> GraphView?{
        for vc in childViewControllers{
            if let gvc = vc as? ActivityGraphViewController{
                return gvc.activityConstantsGraphView
            }
        }
        return nil
    }
}
