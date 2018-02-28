//
//  EddingtonNumberTABViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 27/02/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class EddingtonNumberTABViewController: NSTabViewController, TrainingDiaryViewController {
    func set(trainingDiary td: TrainingDiary) {
        for vc in childViewControllers{
            if let tdvc = vc as? TrainingDiaryViewController{
                tdvc.set(trainingDiary: td)
            }
        }
    }

    
}
