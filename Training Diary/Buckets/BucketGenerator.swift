//
//  BucketGenerator.swift
//  Training Diary
//
//  Created by Steven Lord on 04/05/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Foundation
/* deprecated
class BucketGenerator{
    
    func createBuckets(fromTrainingDiary td: TrainingDiary, buckets: BucketDefinition) -> [Bucket]{
        let values: [Double] = td.valuesFor(dataSeriesDefinition: buckets.dataSeriesDefinition).map({$0.value}).filter({$0 > 0.001})
        let result: [Bucket] = createBuckets(buckets: buckets, from: values)
        return result
    }
    
    func createBuckets(fromTrainingDiary td: TrainingDiary, buckets: BucketDefinition, from: Date, to: Date) -> [Bucket]{
        buckets.dataSeriesDefinition.from = from
        buckets.dataSeriesDefinition.to = to

        let values: [Double] = buckets.dataSeriesDefinition.getData().map({$0.value}).filter({$0 > 0.001})
        
        let result: [Bucket] = createBuckets(buckets: buckets, from: values)
        return result
    }
    
    private func createBuckets(buckets: BucketDefinition, from values: [Double]) -> [Bucket]{
        
        let min = values.min()!
        let max = values.max()!
        print("Min: \(min)... Max: \(max)")
        print("Number of values: \(values.count)")
        var bucketMin: Double = 0.0
        var bucketMax: Double = bucketMin + buckets.bucketSize
        var result: [Bucket] = []
        
        while bucketMin <= max{
            let count = values.filter({$0 > bucketMin && $0 <= bucketMax}).count
            let name = String(Int(bucketMin)) + "->" + String(Int(bucketMax))
            result.append(Bucket(name: name, from: bucketMin, to: bucketMax, size: count))
            bucketMin = bucketMax
            bucketMax = bucketMin + buckets.bucketSize
        }
        
        return result
        
        
    }
    

    
}
 */
