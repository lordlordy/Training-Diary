//
//  PlansTableViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 21/04/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class PlansTableViewController: TrainingDiaryViewController, NSTableViewDelegate, NSComboBoxDataSource{
    
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
    
//    @IBAction func startingFromDiaryPressed(_ sender: Any) {
//        if let p = parent?.parent as? PlanningSplitViewController{
//            p.setStartingTSBValuesFromTrainingDiary()
//        }
//    }
    
//    @IBAction func copyStartingToPlanPressed(_ sender: Any) {
//        if let p = parent?.parent as? PlanningSplitViewController{
//            p.copyStartingTSBValuesToFirstPlanDay()
//        }
//    }
    
    //MARK: - NSComboBoxDataSource
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        let plans: [Plan] = trainingDiary?.plans?.allObjects as? [Plan] ?? []
        if index < plans.count{
            return plans[index].name
        }
        return nil
    }
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        return trainingDiary?.plans?.count ?? 0
    }
    
    //NSTableViewDelegate
    func tableViewSelectionDidChange(_ notification: Notification) {
        if let p = parent?.parent as? PlanningSplitViewController{
            p.planSelectionChanged()
        }
    }
}
