//
//  PlanBasicWeekViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 21/04/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class PlanBasicWeekViewController: TrainingDiaryViewController{
    
    @IBOutlet var comments: NSTextView!
    @IBOutlet weak var swim: NSTextField!
    @IBOutlet weak var bike: NSTextField!
    @IBOutlet weak var run: NSTextField!
    @IBOutlet weak var total: NSTextField!
    
    
    @IBAction func createPlan(_ sender: Any) {
        
        if let pscv = parent?.parent as? PlanningSplitViewController{
            pscv.createPlan()
        }
        
    }
    
}
