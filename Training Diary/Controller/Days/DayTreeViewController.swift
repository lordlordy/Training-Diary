//
//  DayTreeViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 02/03/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class DayTreeViewController:  TrainingDiaryViewController {
    
//    @objc dynamic var trainingDiary: TrainingDiary?
    
    private var monthYearNodes: [PeriodNode] = []
    private var weekYearNodes: [PeriodNode] = []
    
    @objc dynamic var yearNodes: [PeriodNode] = []
    @IBOutlet weak var outlineView: NSOutlineView!
    
    //MARK: - IBActions
    @IBAction func outlineViewDoubleClicked(_ sender: NSOutlineView) {
        
        let item = sender.item(atRow: sender.clickedRow)
        
        if sender.isItemExpanded(item){
            sender.collapseItem(item)
        }else{
            sender.expandItem(item)
        }
        
    }
    
    @IBAction func weekMonthToggle(_ sender: NSButton) {
        let onState: Bool = sender.state == NSControl.StateValue.on
        if onState{
            yearNodes = monthYearNodes
        }else{
            yearNodes = weekYearNodes
        }
        if let ov = outlineView{
            ov.reloadData()
        }
    }
    
    private func getYearNode(forName n: String, inYearNodes: [PeriodNode]) -> PeriodNode?{
        for y in inYearNodes{
            if y.name == n { return y }
        }
        return nil
    }
    


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _ = trainingDiary{
            createOutlineView()
            createWeekOutlineView()
            yearNodes = monthYearNodes
        }
        
 
        
    }
    
    
    
    private func createOutlineView(){
        monthYearNodes = []
        for d in trainingDiary!.descendingOrderedDays(){
            let year: String = String(d.date!.year())
            let month: String = d.date!.monthAsString()
            var yearNode: PeriodNode
            var monthNode: PeriodNode
            
            if let yNode = getYearNode(forName: year, inYearNodes: monthYearNodes){
                yearNode = yNode
            }else{
                yearNode = PeriodNodeImplementation(name: year, from: d.date!.startOfYear(), to: d.date!.endOfYear(), isRoot: true)
                monthYearNodes.append(yearNode)
            }
            
            if let mNode = yearNode.child(forName: month){
                monthNode = mNode
            }else{
                monthNode = PeriodNodeImplementation(name: d.date!.monthAsString(), from: d.date!.startOfMonth(), to: d.date!.endOfMonth(), isRoot: false)
                yearNode.add(child: monthNode)
            }
            monthNode.add(child: d)
        }
        
    }
    
    private func createWeekOutlineView(){
        weekYearNodes = []
        

        
        for d in trainingDiary!.descendingOrderedDays(){
            let year: String = String(d.date!.yearForWeekOfYear())
  //          let week: String = "Wk-\(d.date!.weekOfYear()) \(d.date!.yearForWeekOfYear())"
            let week: String = "Wk-\(d.date!.weekOfYear())"
            var yearNode: PeriodNode
            var weekNode: PeriodNode
            
            
            if let yNode = getYearNode(forName: year, inYearNodes: weekYearNodes){
                yearNode = yNode
            }else{
                yearNode = PeriodNodeImplementation(name: year, from: d.date!.startOfYear(), to: d.date!.endOfYear(), isRoot: true)
                weekYearNodes.append(yearNode)
            }
            
            if let wNode = yearNode.child(forName: week){
                weekNode = wNode
            }else{
                weekNode = PeriodNodeImplementation(name: week, from: d.date!.startOfWeek(), to: d.date!.endOfWeek(), isRoot: false)
                yearNode.add(child: weekNode)
            }
            weekNode.add(child: d)
        }
        
        
    }
    
}
