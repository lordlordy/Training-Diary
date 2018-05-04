//
//  BucketDefinition.swift
//  Training Diary
//
//  Created by Steven Lord on 04/05/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Foundation

class BucketDefinition{
    
    let dataSeriesDefinition: DataSeriesDefinition
    let bucketSize: Double
    
    required init(data: DataSeriesDefinition, size: Double){
        dataSeriesDefinition = data
        bucketSize = size
    }
    
}
