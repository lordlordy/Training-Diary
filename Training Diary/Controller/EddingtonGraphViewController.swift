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
    private let historyGraph = GraphDefinition(name: "history", axis: .Primary, type: .Line, format: GraphFormat.init(fill: false, colour: .red, fillGradientStart: .red, fillGradientEnd: .red, gradientAngle: 0.0, size: 2.0), drawZeroes: false, priority: 1)
    private let plusOneGraph = GraphDefinition(name: "plusOne", axis: .Primary, type: .Line, format: GraphFormat.init(fill: false, colour: .blue, fillGradientStart: .blue, fillGradientEnd: .blue, gradientAngle: 0.0, size: 1.0), drawZeroes: false, priority: 1)
    private let contributorsGraph = GraphDefinition(name: "contributors", axis: .Primary, type: .Point, format: GraphFormat.init(fill: false, colour: .green, fillGradientStart: .green, fillGradientEnd: .green, gradientAngle: 0.0, size: 2.0), drawZeroes: false, priority: 2)
    private let annualHistoryGraph = GraphDefinition(name: "annual", axis: .Primary, type: .Point, format: GraphFormat.init(fill: true, colour: .yellow, fillGradientStart: .yellow, fillGradientEnd: .yellow, gradientAngle: 0.0, size: 7.0), drawZeroes: false, priority: 4)
    private let maturityGraph = GraphDefinition(name: "maturity", axis: .Secondary, type: .Line, format: GraphFormat.init(fill: false, colour: .cyan, fillGradientStart: .cyan, fillGradientEnd: .cyan, gradientAngle: 0.0, size: 1.0), drawZeroes: false, priority: 5)
    

    @IBOutlet weak var graphView: GraphView!
    
    override func set(trainingDiary td: TrainingDiary){
        super.set(trainingDiary: td)
        if let gv = graphView{
            let range = td.lastDayOfDiary.timeIntervalSince(td.firstDayOfDiary)
            let numberOfLabels = 6
            let gap = range / Double(numberOfLabels - 1)
            var labels: [String] = []
            labels.append(td.firstDayOfDiary.dateOnlyShorterString())
            for i in 1...(numberOfLabels-1){
                labels.append(td.firstDayOfDiary.addingTimeInterval(TimeInterval(gap*Double(i))).dateOnlyShorterString())
            }
            gv.xAxisLabelStrings = labels
        }
        
        
    }
    
    //MARK: - Override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpGraphs()
    }
    
    //MARK: - Private
    
    private func selectedRows() -> [EddingtonNumber]{
        
        if let controller = parent?.parent as? EddingtonSplitViewController{
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
            
            gv.add(graph: historyGraph)
            gv.add(graph: plusOneGraph)
            gv.add(graph: contributorsGraph)
            gv.add(graph: annualHistoryGraph)
            gv.add(graph: maturityGraph)
            
            gv.backgroundGradientStartColour = .lightGray
            gv.backgroundGradientEndColour = .darkGray
            gv.backgroundGradientAngle = 45
            
            //create the labels - create six
            var xAxisLabels: [String] = []
            if let td = trainingDiary{
                let from = td.firstDayOfDiary
                let to = td.lastDayOfDiary
                let gap = to.timeIntervalSince(from) / 5.0
                xAxisLabels.append(from.dateOnlyShorterString())
                for i in 1...5{
                    xAxisLabels.append(from.addingTimeInterval(gap * Double(i)).dateOnlyShorterString())
                }
            }
            
            gv.xAxisLabelStrings = xAxisLabels
            
            let formatter = NumberFormatter()
            formatter.format = "#,##0.00"
            gv.secondaryAxisNumberFormatter = formatter
            
            
        }
    }
    
    private func updateGraph(){
        if let edNum = getSelectedEddingtonNumber(){
            if let gv = graphView{
                
                //start with zero for first day of diary - this ensures that scales line up.
                let firstEntry = (date: trainingDiary!.firstDayOfDiary,value: 0.0)
                var history: [(date: Date, value: Double)] = [firstEntry]
                var plusOneHistory: [(date: Date, value: Double)] = [firstEntry]
                var contributors: [(date: Date, value: Double)] = [firstEntry]
                var annualHistory: [(date: Date, value: Double)] = [firstEntry]
                var maturityHistory: [(date: Date, value: Double)] = [firstEntry]
                
                for e in edNum.getSortedHistory(){
                    history.append((date: e.date!, value: Double(e.value)))
                    plusOneHistory.append((date: e.date!, value: Double(e.value + e.plusOne)))
                    maturityHistory.append((date: e.date!, value: e.maturity))
                    
                }
                historyGraph.data = history
                plusOneGraph.data = plusOneHistory
                maturityGraph.data = maturityHistory
                
                for c in edNum.getSortedContributors(){
                    contributors.append((c.date!, c.value))
                }
                
                
                contributorsGraph.data = contributors
                
                for e in edNum.getSortedAnnualHistory(){
                    annualHistory.append((date:e.date!, value: Double(e.value)))
                }
                annualHistoryGraph.data = annualHistory
                
                gv.chartTitle = edNum.eddingtonCode
                
                gv.needsDisplay = true
                
            }
        }
    }
    
}
