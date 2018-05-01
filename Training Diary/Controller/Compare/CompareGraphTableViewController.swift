//
//  CompareGraphTableViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 28/03/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class CompareGraphTableViewController: TrainingDiaryViewController, NSComboBoxDataSource {
    
    @IBOutlet weak var activityComboBox: NSComboBox!
    
    
    @IBAction func retreatAPeriod(_ sender: NSButton) {
        if let parentVC = parent as? CompareGraphSplitViewController{
            parentVC.retreatAPeriod()
        }
    }
    
    @IBAction func advanceAPeriod(_ sender: NSButton) {
        if let parentVC = parent as? CompareGraphSplitViewController{
            parentVC.advanceAPeriod()
        }
    }
    
    @IBAction func graphLengthChange(_ sender: PeriodTextField) {
        if let parentVC = parent as? CompareGraphSplitViewController{
            if let dc = sender.getDateComponentsEquivalent(){
                if let negDC = sender.getNegativeDateComponentsEquivalent(){
                    parentVC.graphLengthChange(dcEquiv: dc, negativeDCEquiv: negDC)
                }
            }
        }
    }
    
    
    @IBAction func activityChange(_ sender: NSComboBox) {
        if let parentVC = parent as? CompareGraphSplitViewController{
            parentVC.activityChange(activity: sender.stringValue)
        }
    }
    
    @IBAction func activityTypeChange(_ sender: NSComboBox) {
        if let parentVC = parent as? CompareGraphSplitViewController{
            parentVC.activityTypeChange(activityType: sender.stringValue)
        }
    }
    
    
    @IBAction func periodChange(_ sender: PeriodComboBox) {
        if let parentVC = parent as? CompareGraphSplitViewController{
            if let p = sender.selectedPeriod(){
                parentVC.periodChange(period: p.rawValue)
            }
        }
    }
    
    @IBAction func aggregationMethodChanged(_ sender: AggregationMethodComboBox) {
        if let parentVC = parent as? CompareGraphSplitViewController{
            if let a = sender.selectedAggregationMethod(){
                parentVC.aggregationMethodChange(aggregationMethod: a.rawValue)
            }
        }
    }
    
    @IBAction func unitChange(_ sender: UnitComboBox) {
        if let parentVC = parent as? CompareGraphSplitViewController{
            if let u = sender.selectedUnit(){
                parentVC.unitChange(unit: u.rawValue)
            }
        }
    }
    
    
    @IBAction func add(_ sender: Any) {
        if let parentVC = parent as? CompareGraphSplitViewController{
            parentVC.graphArrayController!.add(sender)
        }
    }
    
    
    @IBAction func remove(_ sender: Any) {
        if let parentVC = parent as? CompareGraphSplitViewController{
            parentVC.graphArrayController!.remove(sender)
        }
    }
    
    //MARK: - NSComboBoxDataSource
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        if let identifier = comboBox.identifier{
            switch identifier.rawValue{
            case "CompareTableActivityComboBox", "CompareActivityComboBox":
                let activities = trainingDiary!.eddingtonActivities()
                if index < activities.count{
                    return activities[index]
                }
            case "CompareTableActivityTypeComboBox":
                guard let c = comboBox.superview as? NSTableCellView else{ return nil }
                if let graph = c.objectValue as? ActivityGraphDefinition{
                    let types = trainingDiary!.eddingtonActivityTypes(forActivityString: graph.activity)
                    if index < types.count{
                        return types[index]
                    }
                }
            case "CompareTableEquipmentComboBox":
                guard let c = comboBox.superview as? NSTableCellView else{ return nil }
                if let graph = c.objectValue as? ActivityGraphDefinition{
                    let types = trainingDiary!.eddingtonEquipment(forActivityString: graph.activity)
                    if index < types.count{
                        return types[index]
                    }
                }
            case "CompareActivityTypeComboBox":
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
            case "CompareTableActivityComboBox", "CompareActivityComboBox":
                return trainingDiary!.eddingtonActivities().count
            case "CompareTableActivityTypeComboBox":
                guard let c = comboBox.superview as? NSTableCellView else{ return 0 }
                if let graph = c.objectValue as? ActivityGraphDefinition{
                    return trainingDiary!.eddingtonActivityTypes(forActivityString: graph.activity).count
                }
            case "CompareTableEquipmentComboBox":
                guard let c = comboBox.superview as? NSTableCellView else{ return 0 }
                if let graph = c.objectValue as? ActivityGraphDefinition{
                    return trainingDiary!.eddingtonEquipment(forActivityString: graph.activity).count
                }
            case "CompareActivityTypeComboBox":
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

