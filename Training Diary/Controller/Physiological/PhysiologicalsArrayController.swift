//
//  PhysiologicalsArrayController.swift
//  Training Diary
//
//  Created by Steven Lord on 11/11/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Cocoa

class PhysiologicalsArrayController: NSArrayController {
    override func newObject() -> Any {
        let physio = super.newObject() as! Physiological
        //get date components for date in current time zone
        let dc = Calendar.current.dateComponents([.day,.month,.year], from: Date())
        //set date as GMT
        var gmt = Calendar.init(identifier: .gregorian)
        gmt.timeZone = TimeZone(secondsFromGMT: 0)!
        //date in GMT
        let fromDate = gmt.date(from: dc)?.startOfDay()
        
        physio.fromDate = fromDate
        let physios = self.arrangedObjects as! [Physiological]
        let sortedPhysios = physios.sorted(by: {$0.fromDate! > $1.fromDate!})

        return physio
    }
}
