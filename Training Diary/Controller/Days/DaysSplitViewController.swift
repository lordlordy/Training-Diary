//
//  DaysSplitViewController.swift
//  Training Diary
//
//  Created by Steven Lord on 05/03/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class DaysSplitViewController: TrainingDiarySplitViewController{
    
    @IBOutlet var daysArrayController: DaysArrayController!
    
    
    override func set(trainingDiary td: TrainingDiary){
        super.set(trainingDiary: td)
        if let dac = daysArrayController{
            dac.trainingDiary = td
        }
    }
    
}
