//
//  TableViewWithColumnSort.swift
//  Training Diary
//
//  Created by Steven Lord on 02/11/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Cocoa

enum TableIdentifier: String{
    //these are the identifiers given to tables to use for user defaults.
    //This will allow setting up of a screen to change these default
    case DayTableInSplitView
    
}

class TableViewWithColumnSort: NSTableView {

    private var columnDict: [String:Bool] = [:]
    
    required init?(coder: NSCoder) {
  
        super.init(coder: coder)
        
        if let dict = UserDefaults.standard.value(forKey: tableName()) as? [String : Bool]{
            columnDict = dict
        }
        
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
    
    private func tableName() -> String{
        return autosaveName?.rawValue ?? "unNamedTable"
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
    //        UserDefaults.standard.set(col.isHidden, forKey: key(forColumn: col))
        
            columnDict[col.identifier.rawValue] = col.isHidden
            UserDefaults.standard.set(columnDict, forKey: tableName())
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
            let colHidden: Bool = columnDict[column.identifier.rawValue] ?? false
            let title = column.headerCell.title
            
            let item = tableHeaderContextMenu.addItem(withTitle: title, action: #selector(TableViewWithColumnSort.contextMenuSelected), keyEquivalent: "")
            
            item.target = self
            item.representedObject = column
            item.state = colHidden ? .off : .on
            
        }
        self.headerView?.menu = tableHeaderContextMenu
    }
    

    
}
