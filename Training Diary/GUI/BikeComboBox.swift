//
//  BikeComboBox.swift
//  Training Diary
//
//  Created by Steven Lord on 07/11/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Cocoa

class BikeComboBox: NSComboBox {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.addItems(withObjectValues: BikeName.ActiveBikes.map({$0.rawValue}))
        
    }
    func selectedBike() -> BikeName?{
        return BikeName(rawValue: self.stringValue)
    }
    
}
