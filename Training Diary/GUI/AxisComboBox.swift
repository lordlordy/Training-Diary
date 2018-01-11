//
//  AxisComboBox.swift
//  Training Diary
//
//  Created by Steven Lord on 24/11/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Cocoa

class AxisComboBox: NSComboBox {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.addItems(withObjectValues: Axis.AllAxes.map({$0.rawValue}))
    }
    
    func selectedChartType() -> Axis?{
        print("returning chart type")
        return Axis(rawValue: self.stringValue)
    }
     
}
