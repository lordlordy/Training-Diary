//
//  TrainingDiarySplitViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 04/03/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class TrainingDiarySplitViewController: NSSplitViewController, TrainingDiaryViewControllerProtocol {
    
    @objc dynamic var trainingDiary: TrainingDiary?
    
    func set(trainingDiary td: TrainingDiary) {
        trainingDiary = td
        for vc in childViewControllers{
            if let tdvc = vc as? TrainingDiaryViewControllerProtocol{
                print("Setting training diary on \(tdvc)")
                tdvc.set(trainingDiary: td)
            }
            
        }
        
    }
    
    override func splitView(_ splitView: NSSplitView, canCollapseSubview subview: NSView) -> Bool {
        return true
    }
    
    override func splitView(_ splitView: NSSplitView, shouldCollapseSubview subview: NSView, forDoubleClickOnDividerAt dividerIndex: Int) -> Bool {
        return true
    }
    
}
