//
//  TableViewWithColumnSort.swift
//  Training Diary
//
//  Created by Steven Lord on 02/11/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Cocoa

class TableViewWithColumnSort: NSTableView {

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
