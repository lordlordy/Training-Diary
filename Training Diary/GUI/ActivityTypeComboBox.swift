//
//  ActivityTypeComboBox.swift
//  Training Diary
//
//  Created by Steven Lord on 07/11/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Cocoa

class ActivityTypeComboBox: NSComboBox {


    required init?(coder: NSCoder) {
        super.init(coder: coder)
   //     self.addItems(withObjectValues: ActivityTypeEnum.AllActivityTypes.map({$0.rawValue}))
        
    }
  
/*    func selectedActivityType() -> ActivityTypeEnum?{
        return ActivityTypeEnum(rawValue: self.stringValue)
    }
  */
}
