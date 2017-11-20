//
//  ActivityComboBox.swift
//  Training Diary
//
//  Created by Steven Lord on 07/11/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Cocoa

class ActivityComboBox: NSComboBox {


    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.addItems(withObjectValues: Activity.allActivities.map({$0.rawValue}))
    
        
    }
    
}
