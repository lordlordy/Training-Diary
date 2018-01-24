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
        physio.fromDate = Date().startOfDay()
        physio.toDate = Calendar.current.date(byAdding: DateComponents(year: 99), to: Date())
        let physios = self.arrangedObjects as! [Physiological]
        let sortedPhysios = physios.sorted(by: {$0.fromDate! > $1.toDate!})
        if sortedPhysios.count > 0{
            sortedPhysios[0].toDate = Date().yesterday().endOfDay()
        }
        return physio
    }
}
