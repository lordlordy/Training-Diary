//
//  TrainingDiaryTabViewControler.swift
//  Training Diary
//
//  Created by Steven Lord on 02/03/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class TrainingDiaryTabViewControler: NSTabViewController, TrainingDiaryViewControllerProtocol {

    func set(trainingDiary td: TrainingDiary) {
        for vc in children{
            if let tdvc = vc as? TrainingDiaryViewControllerProtocol{
                print("Setting training diary on \(tdvc)")
                tdvc.set(trainingDiary: td)
            }
        }
    }
    
}
