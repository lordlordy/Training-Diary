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
        if let dtv = daysTableView{
            dtv.reloadData()
        }
    }
    
    @IBAction func calcTSBForSelection(_ sender: Any) {
        if let pvc = parent?.parent as? DaysSplitViewController{
            if let selectedDay = pvc.daysArrayController.selectedObjects as? [Day]{
                if selectedDay.count > 0{
                    if let td = trainingDiary{
                        for a in td.activitiesArray(){
                            td.calcTSB(forActivity: a, fromDate: selectedDay[0].date!)
                        }
                        daysTableView!.reloadData()
                    }
                }
            }
        }
    }
    
}
