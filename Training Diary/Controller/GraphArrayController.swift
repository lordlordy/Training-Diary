//
//  GraphArrayController.swift
//  Training Diary
//
//  Created by Steven Lord on 06/12/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Cocoa

class GraphArrayController: NSArrayController {

    public var graphManagementDelegate: GraphManagementDelegate?
    
    override func add(_ sender: Any?) {
        super.add(sender)
    }
    
    override func newObject() -> Any {
        let g = super.newObject() as! ActivityGraphDefinition
        if let gmd = graphManagementDelegate{
            gmd.setDefaults(forGraph: g)
            gmd.add(graph: g)
        }
        return g
    }
    
    override func remove(_ sender: Any?) {
        let graphs = self.selectedObjects as! [ActivityGraphDefinition]
        if let gmd = graphManagementDelegate{
            for g in graphs{
                gmd.remove(graph: g)
            }
        }
        super.remove(sender)
    }
    

    
}
