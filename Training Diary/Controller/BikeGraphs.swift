//
//  BikeGraphs.swift
//  Training Diary
//
//  Created by Steven Lord on 23/01/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Foundation

class BikeGraphs: NSObject{
    
    @objc dynamic var name: String
    @objc dynamic var valuesGraph: GraphDefinition
    @objc dynamic var ltdGraph: GraphDefinition
    @objc dynamic var rollingGraph: GraphDefinition
    
    init(name: String, valuesGraph: GraphDefinition, ltdGraph: GraphDefinition, rollingGraph: GraphDefinition){
        self.name = name
        self.valuesGraph = valuesGraph
        self.ltdGraph = ltdGraph
        self.rollingGraph = rollingGraph
        super.init()
    }
    
    func add(toGraph gv: GraphView){
        gv.add(graph: valuesGraph)
        gv.add(graph: ltdGraph)
        gv.add(graph: rollingGraph)
    }
    
    func remove(fromGraph gv: GraphView){
        gv.remove(graph: valuesGraph)
        gv.remove(graph: ltdGraph)
        gv.remove(graph: rollingGraph)
    }
    
}
