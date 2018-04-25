//
//  WorkoutPredicateViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 17/04/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class WorkoutPredicateViewController: NSViewController{
    
    
    @IBOutlet weak var predicateEditor: NSPredicateEditor!
    
    @IBAction func add(_ sender: Any) {
        if let pe = predicateEditor{
            pe.addRow(nil)
        }
    }
}
