//
//  ActivityGraphDefinition.swift
//  Training Diary
//
//  Created by Steven Lord on 23/11/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Foundation

//this is intentionally set up as a class rather than struct so that it is passed by reference.
@objc class ActivityGraphDefinition: NSObject{
    
    var cache: [(date: Date, value: Double)] = [] // this is ALL the data. When dates change we just filter this
    @objc var graph: GraphView.GraphDefinition?
    
    var activity:   Activity{ didSet{ updateName() } }
    var unit:       Unit{ didSet{ updateName() } }
    var period:     Period { didSet{ updateName() } }
    @objc dynamic var activityString: String{
        get{ return activity.rawValue}
        set{
            if let a = Activity(rawValue: newValue){ activity = a}
        }
    }
    @objc dynamic var unitString: String{
        get{ return unit.rawValue}
        set{
            if let u = Unit(rawValue: newValue){
                unit = u
            }
        }
    }
    @objc dynamic var periodString: String{
        get{ return period.rawValue}
        set{
            if let p = Period(rawValue: newValue){ period = p}
        }
    }
    // not sure we need to set the name in Graph as that name is 'probably' redundant and should probably be removed
    @objc dynamic var name: String = ""{didSet{ graph?.name = name } }
    
    init(activity a: Activity, unit u: Unit, period p: Period) {
        activity = a
        unit = u
        period = p
        super.init()
        updateName()
    }
    
    override convenience init(){
        self.init(activity: .All, unit: .KM, period: .Day)
        graph = GraphView.GraphDefinition(name: self.name, axis: .Primary, type: .Line, format: GraphFormat.init(fill: false, colour: .black, fillGradientStart: .black, fillGradientEnd: .black, gradientAngle: 0.0, size: 1.0), drawZeroes: true, priority: 1)
    }
    
    convenience init(graph: GraphView.GraphDefinition,activity a: Activity, unit u: Unit, period p: Period) {
        self.init(activity: a, unit: u, period: p)
        self.graph = graph
    }
    
    private func updateName(){
        name = activityString + ":" + periodString + ":" + unitString
    }
    
}
