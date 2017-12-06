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
        let a = super.newObject() as! DatedActivityGraphDefinition
        if let gmd = graphManagementDelegate{
            gmd.add(graph: a)
        }
        return a
    }
    
    override func remove(_ sender: Any?) {
        let graphs = self.selectedObjects as! [DatedActivityGraphDefinition]
        if let gmd = graphManagementDelegate{
            for g in graphs{
                gmd.remove(graph: g)
            }
        }
        super.remove(sender)
    }
    

    
}
