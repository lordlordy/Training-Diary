//
//  OutLineViewWithColumnSort.swift
//  Training Diary
//
//  Created by Steven Lord on 03/02/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class OutLineViewWithColumnSort: NSOutlineView {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        for t in tableColumns{
            createColumnSortFor(key: t.identifier.rawValue)
        }        
    }
    
    // assumes the the column ID and the key for the data are the same
    private func createColumnSortFor(key k: String){
        let c = tableColumns[column(withIdentifier: NSUserInterfaceItemIdentifier.init(k))]
        c.sortDescriptorPrototype = NSSortDescriptor.init(key: k, ascending: false)
    }
    
}
