//
//  ActivityGraphDefinition.swift
//  Training Diary
//
//  Created by Steven Lord on 23/11/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Foundation

//this is intentionally set up as a class rather than struct so that it is passed by reference.
//TO DO - should consolidate these definitions. This should extend GraphDefinition not contain it
@objc class ActivityGraphDefinition: NSObject{
    
    enum ObserveKey: String{
        case name
    }
    
    var cache: [(date: Date, value: Double)] = [] // this is ALL the data. When dates change we just filter this
    @objc var graph: GraphDefinition?
    
    var activity:       Activity        { didSet{ updateName() } }
    var activityType:   ActivityType    { didSet{ updateName() } }
    var unit:           Unit            { didSet{ updateName() } }
    var period:         Period          { didSet{ updateName() } }
    
    @objc dynamic var activityString: String{
        get{ return activity.rawValue}
        set{
            if let a = Activity(rawValue: newValue){ activity = a}
        }
    }
    
    @objc dynamic var activityTypeString: String{
        get{ return activityType.rawValue}
        set{
            if let at = ActivityType(rawValue: newValue){ activityType = at}
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
    //@objc dynamic var name: String = ""{didSet{ graph?.name = name } }
    @objc dynamic var name: String = ""
    
    override init(){
        self.activity = Activity.Bike
        self.activityType = ActivityType.All
        self.unit = Unit.KM
        self.period = Period.Day
        graph = GraphDefinition(name: "new", axis: .Primary, type: .Line, format: GraphFormat.init(fill: false, colour: .black, fillGradientStart: .black, fillGradientEnd: .black, gradientAngle: 0.0, size: 1.0), drawZeroes: true, priority: 1)
        super.init()
        updateName()
    }
    
    convenience init(activity a: Activity, unit u: Unit, period p: Period) {
        self.init()
        activity = a
        unit = u
        period = p
        updateName()
    }

    convenience init(graph: GraphDefinition,activity a: Activity, unit u: Unit, period p: Period) {
        self.init(activity: a, unit: u, period: p)
        self.graph = graph
    }
    
    private func updateName(){
        name = activityString + ":" + activityTypeString + ":" + periodString + ":" + unitString
    }
    
}
