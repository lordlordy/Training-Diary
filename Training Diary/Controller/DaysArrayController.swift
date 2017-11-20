//
//  DaysArrayController.swift
//  Training Diary
//
//  Created by Steven Lord on 08/10/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Cocoa

class DaysArrayController: NSArrayController {

    override func newObject() -> Any {
        print("adding Day")
        let day = super.newObject() as! Day
        day.setValue(Date().startOfDay(), forKey: "date")
        return day
    }



}
    
