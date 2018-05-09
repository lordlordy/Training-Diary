//
//  DayTypeComboBox.swift
//  Training Diary
//
//  Created by Steven Lord on 07/11/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Cocoa

class DayTypeComboBox: NSComboBox {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.addItems(withObjectValues: DayType.InputTypes.map({$0.rawValue}))

    }
   
    func selectedDayType() -> DayType?{
        return DayType(rawValue: self.stringValue)
    }
    
}
