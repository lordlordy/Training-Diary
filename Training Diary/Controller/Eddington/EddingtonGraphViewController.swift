//
//  EddingtonGraphViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 08/03/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class EddingtonGraphViewController: TrainingDiaryViewController{
    
    //same graphs for all so set them up here
    private let historyGraph = GraphDefinition(name: "history", axis: .Primary, type: .Line, format: GraphFormat.init(fill: false, colour: .red, fillGradientStart: .red, fillGradientEnd: .red, gradientAngle: 0.0, size: 2.0, opacity: 1.0), drawZeroes: false, priority: 1)
    private let plusOneGraph = GraphDefinition(name: "plusOne", axis: .Primary, type: .Line, format: GraphFormat.init(fill: false, colour: .blue, fillGradientStart: .blue, fillGradientEnd: .blue, gradientAngle: 0.0, size: 1.0, opacity: 1.0), drawZeroes: false, priority: 1)
    private let contributorsGraph = GraphDefinition(name: "contributors", axis: .Primary, type: .Point, format: GraphFormat.init(fill: false, colour: .green, fillGradientStart: .green, fillGradientEnd: .green, gradientAngle: 0.0, size: 2.0, opacity: 1.0), drawZeroes: false, priority: 2)
    private let annualHistoryGraph = GraphDefinition(name: "annual", axis: .Primary, type: .Point, format: GraphFormat.init(fill: true, colour: .yellow, fillGradientStart: .yellow, fillGradientEnd: .yellow, gradientAngle: 0.0, size: 7.0, opacity: 1.0), drawZeroes: false, priority: 4)
    private let maturityGraph = GraphDefinition(name: "maturity", axis: .Secondary, type: .Line, format: GraphFormat.init(fill: false, colour: .cyan, fillGradientStart: .cyan, fillGradientEnd: .cyan, gradientAngle: 0.0, size: 1.0, opacity: 1.0), drawZeroes: false, priority: 5)
    
    private var graphs: [GraphDefinition] = []
    private var xAxisLabels: [(x: Double, label: String)] = []
    

    @IBOutlet weak var graphView: GraphView!
    
    override func set(trainingDiary td: TrainingDiary){
        super.set(trainingDiary: td)
        updateXAxisLabels()
    }
    
    //MARK: - Override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        graphs = [historyGraph, plusOneGraph, contributorsGraph, annualHistoryGraph, maturityGraph]
        setUpGraphs()
        updateGraph()
    }
    
    func updateGraph(){
        if let edNum = getSelectedEddingtonNumber(){
            if let gv = graphView{
                
                //start with zero for first day of diary - this ensures that scales line up.
                let firstEntry = (x: trainingDiary!.firstDayOfDiary.timeIntervalSinceReferenceDate,y: 0.0)
                var history: [(x: Double, y: Double)] = [firstEntry]
                var plusOneHistory: [(x: Double, y: Double)] = [firstEntry]
                var contributors: [(x: Double, y: Double)] = [firstEntry]
                var annualHistory: [(x: Double, y: Double)] = [firstEntry]
                var maturityHistory: [(x: Double, y: Double)] = [firstEntry]
                
                for e in edNum.getSortedHistory(){
                    history.append((x: e.date!.timeIntervalSinceReferenceDate, y: Double(e.value)))
                    plusOneHistory.append((x: e.date!.timeIntervalSinceReferenceDate, y: Double(e.value + e.plusOne)))
                    maturityHistory.append((x: e.date!.timeIntervalSinceReferenceDate, y: e.maturity))
                    
                }
                historyGraph.data = history
                plusOneGraph.data = plusOneHistory
                maturityGraph.data = maturityHistory
                
                for c in edNum.getSortedContributors(){
                    contributors.append((c.date!.timeIntervalSinceReferenceDate, c.value))
                }
                
                
                contributorsGraph.data = contributors
                
                for e in edNum.getSortedAnnualHistory(){
                    annualHistory.append((x:e.date!.timeIntervalSinceReferenceDate, y: Double(e.value)))
                }
                annualHistoryGraph.data = annualHistory
                
                gv.chartTitle = edNum.eddingtonCode
                
                gv.needsDisplay = true
                
            }
        }
    }
    
    
    //MARK: - Private
    

    
    private func selectedRows() -> [EddingtonNumber]{
        
        if let controller = parent as? EddingtonSplitViewController{
            if let selectedObjects = controller.eddingtonNumberAC.selectedObjects{
                return selectedObjects as! [EddingtonNumber]
            }else{
                return []
            }
        }

        return []
    }
    
    private func getSelectedEddingtonNumber() -> EddingtonNumber?{
        if selectedRows().count > 0{
            return selectedRows()[0]
        }
        return nil
    }
    
    private func setUpGraphs(){
        if let gv = graphView{
            
            gv.backgroundGradientStartColour = .lightGray
            gv.backgroundGradientEndColour = .darkGray
            gv.backgroundGradientAngle = 45
            
            updateXAxisLabels()
            
            for g in graphs{
                g.xAxisLabels = xAxisLabels
                gv.add(graph: g)
            }
    
        }
    }
    
    private func updateXAxisLabels(){
        xAxisLabels = []
        if let td = trainingDiary{
            var d = td.firstDayOfDiary
            while d < td.lastDayOfDiary{
                xAxisLabels.append((x:d.timeIntervalSinceReferenceDate, label: d.dateOnlyShorterString()))
                d = Calendar.current.date(byAdding: DateComponents.init( year: 1), to: d)!
            }
        }
    }
    

    
}
