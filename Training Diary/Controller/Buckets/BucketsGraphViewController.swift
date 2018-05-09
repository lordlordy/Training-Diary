//
//  BucketsGraphViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 07/05/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Foundation

class BucketsGraphViewController: TrainingDiaryViewController{
    
  
    @IBOutlet weak var graphView: GraphView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let gv = graphView{
            gv.backgroundGradientAngle = 90.0
            gv.backgroundGradientEndColour = .red
            gv.backgroundGradientStartColour = .green
        }
    }
    
}
