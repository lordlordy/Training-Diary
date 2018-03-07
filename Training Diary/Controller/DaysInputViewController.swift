//
//  DaysInputViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 04/03/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class DaysInputViewController: TrainingDiaryViewController {

    
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
    
}
