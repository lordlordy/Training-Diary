//
//  PlansArrayController.swift
//  Training Diary
//
//  Created by Steven Lord on 21/04/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class PlansArrayController: NSArrayController{
   
    override func newObject() -> Any{
        let plan = super.newObject() as! Plan
        let basicWeek = plan.mutableSetValue(forKey: PlanProperty.basicWeek.rawValue)
        
        for day in WeekDay.All{
            let basicWeekDay = CoreDataStackSingleton.shared.newBasicWeekDay()
            
            basicWeekDay.name = day.name()
            basicWeekDay.order = Int16((day.rawValue+5) % 7)
            
            basicWeek.add(basicWeekDay)
            
        }
        
        plan.from = nextMonday()
        plan.taperStart = plan.from!.addDays(numberOfDays: 70)
        plan.to = plan.taperStart!.addDays(numberOfDays: 21)
        
        return plan
    }
    
    
    private func nextMonday() -> Date{
        var cal = Calendar.init(identifier: .iso8601)
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        var dc = DateComponents.init()
        dc.weekday = WeekDay.gregorianMonday.rawValue
        if let d = cal.nextDate(after: Date(), matching: dc, matchingPolicy: .nextTime, repeatedTimePolicy: .first, direction: .forward){
            return d.noonGMT()
        }
        return Date().noonGMT()
    }
    
}
