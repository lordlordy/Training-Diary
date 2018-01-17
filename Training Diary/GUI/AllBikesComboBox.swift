//
//  AllBikesComboBox.swift
//  Training Diary
//
//  Created by Steven Lord on 14/01/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class AllBikesComboBox: NSComboBox {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.addItems(withObjectValues: Bike.AllBikes.map({$0.rawValue}))
        
    }
    func selectedBike() -> Bike?{
        return Bike(rawValue: self.stringValue)
    }
    
}
