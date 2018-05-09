//
//  BucketGraphArrayController.swift
//  Training Diary
//
//  Created by Steven Lord on 07/05/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class BucketGraphArrayController: NSArrayController {

    var trainingDiary: TrainingDiary?
    
    override func newObject() -> Any {
        let graph = super.newObject() as! BucketGraphDefinition
        graph.bucketDefinition.dataSeriesDefinition.trainingDiary = trainingDiary
        return graph
    }
    
}
