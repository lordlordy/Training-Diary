//
//  TrainingDiaryArrayController.swift
//  Training Diary
//
//  Created by Steven Lord on 10/03/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class TrainingDiaryArrayController: NSArrayController {

    
    override func newObject() -> Any {
        let newObj = super.newObject()
        if let td = newObj as? TrainingDiary{
            // add fixed activities
            CoreDataStackSingleton.shared.addFixedActiviesTypesAndEquipment(toTrainingDiary: td)
            
        }
        
        return newObj
    }
    
}
