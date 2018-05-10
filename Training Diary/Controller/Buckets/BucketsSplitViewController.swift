//
//  BucketsSplitViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 07/05/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class BucketsSplitViewController: TrainingDiarySplitViewController{
    
    private let gradientAngle: Double = 90.0
    private let startColour: NSColor = .green
    private let endColour: NSColor = .red
    
    var graphView: GraphView?{
        for c in childViewControllers{
            if let graph = c as? BucketsGraphViewController{
                let gv = graph.graphView
                return gv
            }
        }
        return nil
    }
    
    private var bucketViewController: BucketsViewController?{
        for c in childViewControllers{
            if let bvc = c as? BucketsViewController{
                return bvc
            }
        }
        return nil
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        if let gv = graphView{
            gv.backgroundGradientAngle = CGFloat(gradientAngle)
            gv.backgroundGradientEndColour = endColour
            gv.backgroundGradientStartColour = startColour
            if let bvc = bucketViewController{
                if let selectedGraphs = bvc.graphArrayController.selectedObjects as? [BucketGraphDefinition]{
                    for g in selectedGraphs{
                        gv.add(graph: g.graph)
                    }
                    if selectedGraphs.count > 0{
                        gv.xAxisLabels = selectedGraphs[0].bucketDefinition.bucketLabels
                    }
                }
                bvc.backgroundGradientTextField.doubleValue = gradientAngle
                bvc.gradientStepper.doubleValue = gradientAngle
                bvc.startColour.color = startColour
                bvc.endColour.color = endColour
                gv.needsDisplay = true
            }
        }
        
    }
    
    func setGraphs(to graphs: [GraphDefinition]){
        if let gv = graphView{
            gv.clearGraphs()
            for g in graphs{
                gv.add(graph: g)
            }
            gv.needsDisplay = true
        }
    }
    
   
    
    
}
