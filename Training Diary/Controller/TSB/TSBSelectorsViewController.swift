//
//  TSBSelectorsViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 16/04/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class TSBSelectorsViewController: TrainingDiaryViewController, NSComboBoxDataSource {
    
    @IBOutlet weak var fromDatePicker: NSDatePicker!
    @IBOutlet weak var toDatePicker: NSDatePicker!
    @IBOutlet weak var activityComboBox: NSComboBox!
    @IBOutlet weak var periodTextField: PeriodTextField!
    

    
    @IBAction func activityChanged(_ sender: Any) {
        if let tsbVC = parent as? TSBGraphSplitViewController{
            tsbVC.updateActivity(toActivity: activityComboBox.stringValue)
        }
    }
    
    @IBAction func fromDateChanged(_ sender: Any) {
        if let tsbVC = parent as? TSBGraphSplitViewController{
            tsbVC.updateStart(toDate: fromDatePicker.dateValue)
        }
    }
    
    @IBAction func toDateChanged(_ sender: Any) {
        if let tsbVC = parent as? TSBGraphSplitViewController{
            tsbVC.updateEnd(toDate: toDatePicker.dateValue)
        }
    }
    
    @IBAction func periodChanged(_ sender: Any) {
        if let dc = periodTextField.getNegativeDateComponentsEquivalent(){
            if let fdp = fromDatePicker{
                if let tdp = toDatePicker{
                    fdp.dateValue = Calendar.current.date(byAdding: dc, to: tdp.dateValue)!
                    updateForDateChanges()
                }
            }
        }
    }
    
    @IBAction func retreatAPeriod(_ sender: Any) {
        if let dc = periodTextField.getNegativeDateComponentsEquivalent(){
            advance(by: dc)
            updateForDateChanges()
        }
    }
    
    @IBAction func advanceAPeriod(_ sender: Any) {
        if let dc = periodTextField.getDateComponentsEquivalent(){
            advance(by: dc)
            updateForDateChanges()
        }
        
    }
    
    @IBAction func reload(_ sender: Any) {
        if let tsbVC = parent as? TSBGraphSplitViewController{
            tsbVC.clearCache(forActivity: activityComboBox.stringValue)
            tsbVC.updateGraphs()
        }
    }
  
    override func viewDidLoad(){
        super.viewDidLoad()
        
        fromDatePicker.dateValue = Calendar.current.date(byAdding: DateComponents.init(month: -6), to: Date())!
        toDatePicker.dateValue = Date()
        activityComboBox.stringValue = ConstantString.EddingtonAll.rawValue
        
        
    }
    
    //MARK: - NSComboBoxDataSource
    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        var activities = trainingDiary!.activitiesArray().map({$0.name!})
        activities.append(ConstantString.EddingtonAll.rawValue)
        if index < activities.count{ return activities[index] }
        return nil
    }
    
    func numberOfItems(in comboBox: NSComboBox) -> Int {
        return trainingDiary!.activitiesArray().count + 1 //add 1 since added "All"
    }
    

    private func advance(by dc: DateComponents){
        if let fdp = fromDatePicker{
            if let tdp = toDatePicker{
                fdp.dateValue = Calendar.current.date(byAdding: dc, to: fdp.dateValue)!
                tdp.dateValue = Calendar.current.date(byAdding: dc, to: tdp.dateValue)!
            }
        }
    }
    
    private func updateForDateChanges(){
        if let tsbVC = parent as? TSBGraphSplitViewController{
            tsbVC.updateStartAndEnd(start: fromDatePicker.dateValue, end: toDatePicker.dateValue)
        }
    }
    
}
