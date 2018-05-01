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
        
        createTableHeaderContextMenu()
    }
    
    

    
    override func controlTextDidEndEditing(_ obj: Notification) {
        super.controlTextDidEndEditing(obj)
        print("control text")
        if let userInfo = userActivity?.userInfo{
            for u in userInfo{
                print("\(u.key): \(u.value)")
            }
        }
    }
    
    override func textDidEndEditing(_ notification: Notification) {
        super.textDidEndEditing(notification)
        if let userInfo = userActivity?.userInfo{
            for u in userInfo{
                print("\(u.key): \(u.value)")
            }
        }
    }
    
    // assumes the the column ID and the key for the data are the same
    private func createColumnSortFor(key k: String){
        let c = tableColumns[column(withIdentifier: NSUserInterfaceItemIdentifier.init(k))]
        c.sortDescriptorPrototype = NSSortDescriptor.init(key: k, ascending: false)
    }
    
    @objc func contextMenuSelected(_ item: NSMenuItem){
        if let col = item.representedObject as? NSTableColumn{
            col.isHidden = !col.isHidden
            item.state = col.isHidden ? .off : .on
            UserDefaults.standard.set(col.isHidden, forKey: key(forColumn: col))
        }
    }
    
    private func key(forColumn c: NSTableColumn) -> String{
        var key = autosaveName?.rawValue ?? "~"
        key += ":"
        key += c.title
        return key
    }
    
    /// set up the table header context menu for choosing the columns.
    private func createTableHeaderContextMenu() {
        
        
        let tableHeaderContextMenu = NSMenu(title:"Select Columns")
        let tableColumns = self.tableColumns
        for column in tableColumns {
            let colHidden: Bool = UserDefaults.standard.bool(forKey: key(forColumn: column))
            let title = column.headerCell.title
            
            let item = tableHeaderContextMenu.addItem(withTitle: title, action: #selector(TableViewWithColumnSort.contextMenuSelected), keyEquivalent: "")
            
            item.target = self
            item.representedObject = column
            item.state = colHidden ? .off : .on
            
        }
        self.headerView?.menu = tableHeaderContextMenu
    }
    

    
}
