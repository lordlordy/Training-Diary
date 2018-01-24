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
        weight.toDate = Calendar.current.date(byAdding: DateComponents(year: 99), to: Date())
        let weights = self.arrangedObjects as! [Weight]
        let sortedWeights = weights.sorted(by: {$0.fromDate! > $1.toDate!})
        if sortedWeights.count > 0{
            sortedWeights[0].toDate = Date().yesterday().endOfDay()
        }
        return weight
    }
}
