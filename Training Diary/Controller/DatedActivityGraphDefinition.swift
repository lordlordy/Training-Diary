//
//  DatedActivityGraphDefinition.swift
//  Training Diary
//
//  Created by Steven Lord on 01/12/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Foundation


@objc class DatedActivityGraphDefinition: ActivityGraphDefinition{
    
    enum ObserveKey: String{
        case to, from
    }
    
    @objc dynamic var from: Date
    @objc dynamic var to: Date
    
    override init(){
        self.to = Date()
        self.from = to.addingTimeInterval(TimeInterval(-Constant.SecondsPer365Days.rawValue))
        super.init()
    }
    
    convenience init(activity a: ActivityEnum, unit u: Unit, period p: Period, fromDate f: Date, toDate t: Date) {
        self.init()
        self.activity = a
        self.unit = u
        self.period = p
        self.from = f
        self.to = t
    }
    
    convenience init(graph: GraphDefinition,activity a: ActivityEnum, unit u: Unit, period p: Period, fromDate f: Date, toDate t: Date) {
        self.init(activity: a, unit: u, period: p, fromDate: f, toDate: t)
        self.graph = graph
    }
    



    
    
}
