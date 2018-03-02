//
//  TrainingDiaryTabViewControler.swift
//  Training Diary
//
//  Created by Steven Lord on 02/03/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class TrainingDiaryTabViewControler: NSTabViewController, TrainingDiaryViewController {

    func set(trainingDiary td: TrainingDiary) {
        for vc in childViewControllers{
            if let tdvc = vc as? TrainingDiaryViewController{
                print("Setting training diary on \(tdvc)")
                tdvc.set(trainingDiary: td)
            }
        }
    }
    
}
