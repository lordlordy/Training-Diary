//
//  TrainingDiaryViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 07/12/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Cocoa

class TrainingDiaryViewController: NSViewController, TrainingDiaryViewControllerProtocol{
    
    @objc dynamic var trainingDiary: TrainingDiary?

    func set(trainingDiary td: TrainingDiary){
        self.trainingDiary = td
        //not sure we should do this here
//        for c in childViewControllers{
//            if let tdvc = c as? TrainingDiaryViewControllerProtocol{
//                tdvc.set(trainingDiary: td)
//            }
//        }
    }
    
}

