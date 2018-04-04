//
//  DaysInputViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 04/03/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class DaysInputViewController: TrainingDiaryViewController {

    @IBOutlet weak var daysTableView: TableViewWithColumnSort!
    
    @IBAction func add(_ sender: Any) {
        if let parentVC = parent?.parent as? DaysSplitViewController{
            if let dac = parentVC.daysArrayController{
                dac.add(sender)
            }
        }
    }
    
    @IBAction func remove(_ sender: Any) {
        if let parentVC = parent?.parent as? DaysSplitViewController{
            if let dac = parentVC.daysArrayController{
                dac.remove(sender)
            }
        }
    }
    
    @IBAction func reload(_ sender: Any) {
        
    }
    
    @IBAction func calcTSBForSelection(_ sender: Any) {
    }
    
}
