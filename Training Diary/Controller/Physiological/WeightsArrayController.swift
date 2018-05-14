//
//  WeightsArrayController.swift
//  Training Diary
//
//  Created by Steven Lord on 11/11/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Cocoa

class WeightsArrayController: NSArrayController {

    
    override func newObject() -> Any {
        let weight = super.newObject() as! Weight
        weight.fromDate = Date().startOfDay()
        return weight
    }
}
