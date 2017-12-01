//
//  DatedActivityGraphDefinition.swift
//  Training Diary
//
//  Created by Steven Lord on 01/12/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Foundation

class DatedActivityGraphDefinition: ActivityGraphDefinition{
    
    private var from: Date
    private var to: Date
    
    init(activity a: Activity, unit u: Unit, period p: Period, fromDate f: Date, toDate t: Date) {
        self.from = f
        self.to = t
        super.init(activity: a, unit: u, period: p)
    }
    
    convenience init(graph: GraphView.GraphDefinition,activity a: Activity, unit u: Unit, period p: Period, fromDate f: Date, toDate t: Date) {
        self.init(activity: a, unit: u, period: p, fromDate: f, toDate: t)
        self.graph = graph
    }
    
    
}
