//
//  DaysArrayController.swift
//  Training Diary
//
//  Created by Steven Lord on 08/10/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Cocoa

class DaysArrayController: NSArrayController {

    var trainingDiary: TrainingDiary?
    
    override func newObject() -> Any {
        
        let day: Day = super.newObject() as! Day
        print("Training diary for day \(String(describing: day.date)) is \(String(describing: day.trainingDiary))")
        //not sure this is the right way to go about it...
        if let td = trainingDiary{
            if let latestDay = td.latestDay(){
                day.yesterday = latestDay
                latestDay.tomorrow = day
                day.date = latestDay.date!.addDays(numberOfDays: 1)
          //      CoreDataStackSingleton.shared.populateMetricPlaceholders(forDay: day)
            }
        }
        return day
    }
    
}
    
