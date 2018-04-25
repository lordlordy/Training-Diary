//
//  PlanOutputViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 23/04/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class PlanOutputViewController: NSViewController{
    
    @IBAction func recalcTSB(_ sender: Any) {
        if let p = parent?.parent as? PlanningSplitViewController{
            p.recalculatePlan()
        }
    }
    @IBOutlet weak var swimTextField: NSTextField!
    @IBOutlet weak var swimPredictedTextField: NSTextField!
    
    @IBOutlet weak var bikeTextField: NSTextField!
    @IBOutlet weak var bikePredictedTextField: NSTextField!
    
    @IBOutlet weak var runTextField: NSTextField!
    @IBOutlet weak var runPredictedTextField: NSTextField!
    
    @IBOutlet weak var allTextField: NSTextField!
    @IBOutlet weak var allPredictedTextField: NSTextField!
    
    @IBOutlet var comments: NSTextView!
    
    @IBAction func updateActual(_ sender: Any) {
        if let p = parent?.parent as? PlanningSplitViewController{
            p.updateActuals()
        }
    }
    
    @IBAction func export(_ sender: Any) {
    }
    
    
}
