//
//  UnitComboBox.swift
//  Training Diary
//
//  Created by Steven Lord on 10/11/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Cocoa

class UnitComboBox: NSComboBox {
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.addItems(withObjectValues: Unit.allActivityUnits.map({$0.rawValue}))
    }
   
    func selectedUnit() -> Unit?{
        return Unit(rawValue: self.stringValue)
    }
    
}
