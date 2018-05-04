//
//  GraphListViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 28/03/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class GraphListViewController: TrainingDiaryViewController, NSComboBoxDataSource{
    
    @IBOutlet weak var fromDatePicker: NSDatePicker!
    @IBOutlet weak var toDatePicker: NSDatePicker!
    @IBOutlet weak var activityComboBox: NSComboBox!
    
    

    
    @IBAction func fromDateChanged(_ sender: NSDatePicker) {
        if let parentVC = parent as? GraphSplitViewController{
            parentVC.updateForDateChange()
        }
    }
    
    @IBAction func toDateChanged(_ sender: NSDatePicker) {
        if let parentVC = parent as? GraphSplitViewController{
            parentVC.updateForDateChange()
        }
    }
    
    @IBAction func activityChanged(_ sender: NSComboBox) {
        if let parentVC = parent as? GraphSplitViewController{
            parentVC.activityChanged(sender)
        }
    }
    
    @IBAction func activityTypeChanged(_ sender: NSComboBox) {
        if let parentVC = parent as? GraphSplitViewController{
            parentVC.activityTypeChanged(sender)
        }
    }
    

    @IBAction func periodChanged(_ sender: PeriodComboBox) {
        if let parentVC = parent as? GraphSplitViewController{
            parentVC.periodComboBoxChanged(sender)
        }
    }
    
    @IBAction func aggregationMethodChanged(_ sender: AggregationMethodComboBox) {
        if let parentVC = parent as? GraphSplitViewController{
            parentVC.aggregationMethodChanged(sender)
        }
    }
    
    @IBAction func unitChanged(_ sender: UnitComboBox) {
        if let parentVC = parent as? GraphSplitViewController{
            parentVC.unitChanged(sender)
        }
    }
    
    @IBAction func advanceAPeriod(_ sender: Any) {
        if let parentVC = parent as? GraphSplitViewController{
            parentVC.advanceAPeriod()
        }
    }
    
    @IBAction func retreatAPeriod(_ sender: Any) {
        if let parentVC = parent as? GraphSplitViewController{
            parentVC.retreatAPeriod()
        }
    }
    
    @IBAction func graphPeriodChanged(_ sender: PeriodTextField) {
        if let parentVC = parent as? GraphSplitViewController{
            parentVC.graphPeriodChange(sender)
        }
    }
    
    @IBAction func removeGraph(_ sender: Any) {
        if let parentVC = parent as? GraphSplitViewController{
            parentVC.graphArrayController.remove(sender)
        }
        
    }
    
    @IBAction func addGraph(_ sender: Any) {
        if let parentVC = parent as? GraphSplitViewController{
            parentVC.graphArrayController.add(sender)
        }
    }
    
    
    //MARK: - NSComboBoxDataSource
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        if let identifier = comboBox.identifier{
            switch identifier.rawValue{
            case "TableActivityComboBox", "ActivityComboBox":
                let activities = trainingDiary!.eddingtonActivities()
                if index < activities.count{
                    return activities[index]
                }
            case "TableActivityTypeComboBox":
                guard let c = comboBox.superview as? NSTableCellView else{
                    return nil
                }
                if let graph = c.objectValue as? ActivityGraphDefinition{
                    let types = trainingDiary!.eddingtonActivityTypes(forActivityString: graph.activity)
                    if index < types.count{
                        return types[index]
                    }
                }
            case "ActivityTypeComboBox":
                if let acb = activityComboBox{
                    if let types = trainingDiary?.eddingtonActivityTypes(forActivityString: acb.stringValue){
                        if index < types.count{
                            return types[index]
                        }
                    }
                }
            default:
                print("What combo box is this \(identifier.rawValue) which I'm (DaysViewController) a data source for? ")
            }
        }
        return nil
    }
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        if let identifier = comboBox.identifier{
            switch identifier.rawValue{
            case "TableActivityComboBox", "ActivityComboBox":
                return trainingDiary!.eddingtonActivities().count
            case "TableActivityTypeComboBox":
                guard let c = comboBox.superview as? NSTableCellView else{
                    return 0
                }
                if let graph = c.objectValue as? ActivityGraphDefinition{
                    return trainingDiary!.eddingtonActivityTypes(forActivityString: graph.activity).count
                }
            case "ActivityTypeComboBox":
                if let acb = activityComboBox{
                    if let types = trainingDiary?.eddingtonActivityTypes(forActivityString: acb.stringValue){
                        return types.count
                    }
                }
            default:
                return 0
            }
        }
        return 0
    }
    
}
