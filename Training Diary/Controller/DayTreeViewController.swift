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
    
    @objc dynamic var yearNodes: [PeriodNode] = []
    
    //MARK: - IBActions
    @IBAction func outlineViewDoubleClicked(_ sender: NSOutlineView) {
        
        let item = sender.item(atRow: sender.clickedRow)
        
        if sender.isItemExpanded(item){
            sender.collapseItem(item)
        }else{
            sender.expandItem(item)
        }
        
    }
    
    
    private func getYearNode(forName n: String) -> PeriodNode?{
        for y in yearNodes{
            if y.name == n { return y }
        }
        return nil
    }
    


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _ = trainingDiary{
            createOutlineView()
        }
        
 
        
    }
    
    
    
    private func createOutlineView(){
        yearNodes = []
        for d in trainingDiary!.descendingOrderedDays(){
            let year: String = String(d.date!.year())
            let month: String = d.date!.monthAsString()
            var yearNode: PeriodNode
            var monthNode: PeriodNode
            
            if let yNode = getYearNode(forName: year){
                yearNode = yNode
            }else{
                yearNode = PeriodNodeImplementation(name: year, from: d.date!.startOfYear(), to: d.date!.endOfYear(), isRoot: true)
                yearNodes.append(yearNode)
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
    
}

