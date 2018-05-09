//
//  BucketGraphDefinition.swift
//  Training Diary
//
//  Created by Steven Lord on 07/05/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Foundation

@objc class BucketGraphDefinition: NSObject{
    
    @objc dynamic var graph: GraphDefinition = GraphDefinition(name: "New Buckets", axis: .Primary, type: .Bar, format: GraphFormat(fill: true, colour: .green, fillGradientStart: .red, fillGradientEnd: .green, gradientAngle: 90.0, size: 2.0, opacity: 1.0), drawZeroes: true, priority: 1)
    
    @objc dynamic var bucketDefinition: BucketDefinition

    override init(){
        bucketDefinition = BucketDefinition.init(data: DataSeriesDefinition(aggregationMethod: .Sum, period: .Day, unit: .Hours), size: 10.0)
        super.init()
        setUpObserving()
    }
    
    init(definition: GraphDefinition, buckets: BucketDefinition){
        graph = definition
        bucketDefinition = buckets
        super.init()
        setUpObserving()
    }
    
    func updateData(){
        var data = [(x:0.0, y:0.0)]
        data.append(contentsOf: bucketDefinition.createBuckets().map({(x:$0.to, y: Double($0.size))}))
        graph.data = data
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let kp = keyPath{
            if kp == BucketDefinition.Observable.bucketsName.rawValue{
                updateData()
                graph.name = bucketDefinition.bucketsName
            }else{
                print("Why is BucketGraphDefinition observing \(kp)?")
            }
        }
    }
    
    private func setUpObserving(){
        bucketDefinition.addObserver(self, forKeyPath: BucketDefinition.Observable.bucketsName.rawValue, options: .new, context: nil)
    }
    
}
