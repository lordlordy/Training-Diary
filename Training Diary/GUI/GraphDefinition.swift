//
//  GraphDefinition.swift
//  Training Diary
//
//  Created by Steven Lord on 10/01/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class GraphDefinition: NSObject{
    var data: [(x: Double, y: Double)] = []
    var axis: Axis = Axis.Primary
    var type: ChartType = ChartType.Line
    var startFromOrigin: Bool = false
    var dash: [CGFloat]?
    
    @objc dynamic var drawZero: Bool = true
    @objc dynamic var name: String
    @objc dynamic var axisString: String{
        get{ return axis.rawValue }
        set{ if let a = Axis(rawValue: newValue){ axis = a } }
    }
    @objc dynamic var typeString: String{
        get{ return type.rawValue }
        set{ if let t = ChartType(rawValue: newValue){ type = t }}
    }
    @objc var display: Bool = true
    @objc var format: GraphFormat
    //need to figure this out. For some reason if I remove this and use colour in GraphFormat I get an uncaught exception.
    @objc var colour: NSColor{
        get{return format.colour}
        set{format.colour = newValue}
    }
    @objc var priority: Int = 1 //This gives relative priority of drawing. Remember that things draw on top of each other
    
    static var observerStrings: [String] = ["axisString","typeString","display","format","colour","priority","drawZero","name"]
    
    //MARK: - Initializers
    
    init(name: String,axis: Axis, type: ChartType, format: GraphFormat, drawZeroes: Bool,  priority: Int){
        self.axis = axis
        self.type = type
        self.format = format
        self.name = name
        self.drawZero = drawZeroes
        self.priority = priority
    }
    
    convenience init(name: String, data: [(x: Double, y: Double)], axis: Axis, type: ChartType, format: GraphFormat, drawZeroes: Bool, priority: Int){
        
        self.init(name: name, axis: axis, type: type, format: format, drawZeroes: drawZeroes, priority: priority)
        self.data = data
    }
    
    override convenience init(){
        self.init(name: "new", axis: .Primary, type: .Line, format: GraphFormat.init(fill: false, colour: .black, fillGradientStart: .black, fillGradientEnd: .black, gradientAngle: 0.0, size: 2.0, opacity: 1.0), drawZeroes: false, priority: 5)
    }
    
}
