//
//  BucketDefinition.swift
//  Training Diary
//
//  Created by Steven Lord on 04/05/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Foundation

@objc class BucketDefinition: NSObject{
    
    enum Observable: String{
        case bucketsName
    }
    
    @objc dynamic var dataSeriesDefinition: DataSeriesDefinition{
        didSet{
            addObservers()
        }
    }
    @objc dynamic var bucketSize: Double{
        didSet{
            setBucketName()
        }
    }
    @objc dynamic var bucketsName: String = "New Buckets"
    
    var bucketLabels: [String] = []
    
    required init(data: DataSeriesDefinition, size: Double){
        dataSeriesDefinition = data
        bucketSize = size
        super.init()
        setBucketName()
        addObservers()
    }
    
    func createBuckets() -> [Bucket]{
        let values: [Double] = dataSeriesDefinition.getData().map({[$0.value,0.0].max()!})
        let result: [Bucket] = createBuckets(from: values)
        bucketLabels = result.map({$0.name})
        return result
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let kp = keyPath{
            if DataSeriesDefinition.Property.observables.map({$0.rawValue}).contains(kp){
                setBucketName()
            }else{
                print("Why is BucketDefinition observing \(kp)??")
            }
        }
    }

    private func addObservers(){
        print("Adding observers for \(dataSeriesDefinition.name)")
        for p in DataSeriesDefinition.Property.observables{
            dataSeriesDefinition.addObserver(self, forKeyPath: p.rawValue, options: .new, context: nil)
        }
    }
    
    private func setBucketName(){
        bucketsName = "Buckets[\(Int(bucketSize))]" + "~" + dataSeriesDefinition.shortName
    }
    
    private func createBuckets( from values: [Double]) -> [Bucket]{
        
        if values.count == 0 { return [] }
        
        let min = [values.min()!, 0.0].max()!
        let max = values.max()!
        print("Min: \(min)... Max: \(max)")
        print("Number of values: \(values.count)")
        var bucketMin: Double = 0.0001
        var bucketMax: Double = bucketMin + bucketSize
        var result: [Bucket] = []
        
        while bucketMin <= max{
            let count = values.filter({$0 > bucketMin && $0 <= bucketMax}).count
            let name = String(Int(bucketMin)) + "->" + String(Int(bucketMax))
            result.append(Bucket(name: name, from: bucketMin, to: bucketMax, size: count))
            bucketMin = bucketMax
            bucketMax = bucketMin + bucketSize
        }
        
        return result
        
        
    }
    
    
}
