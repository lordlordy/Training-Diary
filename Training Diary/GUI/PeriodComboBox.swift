//
//  PeriodComboBox.swift
//  Training Diary
//
//  Created by Steven Lord on 08/11/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Cocoa

class PeriodComboBox: NSComboBox {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        //this excludes Adhoc and Lifetime
        self.addItems(withObjectValues: Period.baseDataPeriods.map({$0.rawValue}))
        
    }
  
    
    func selectedPeriod() -> Period?{
        return Period(rawValue: self.stringValue)
    }
    
}
