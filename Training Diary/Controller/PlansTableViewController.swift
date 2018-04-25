//
//  PlansTableViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 21/04/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class PlansTableViewController: TrainingDiaryViewController, NSTableViewDelegate{
    
    @IBAction func add(_ sender: Any) {
        if let vc = parent?.parent as? PlanningSplitViewController{
            vc.plansArrayController!.add(sender)
        }
    }
    
    
    @IBAction func remove(_ sender: Any) {
        if let vc = parent?.parent as? PlanningSplitViewController{
            vc.plansArrayController!.remove(sender)
        }
    }
    
    //NSTableViewDelegate
    func tableViewSelectionDidChange(_ notification: Notification) {
        if let p = parent?.parent as? PlanningSplitViewController{
            p.planSelectionChanged()
        }
    }
}
