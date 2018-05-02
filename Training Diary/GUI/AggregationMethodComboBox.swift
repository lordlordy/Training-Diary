//
//  AggregationMethodComboBox.swift
//  Training Diary
//
//  Created by Steven Lord on 27/04/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class AggregationMethodComboBox: NSComboBox {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        //this excludes Adhoc and Lifetime
        self.addItems(withObjectValues: AggregationMethod.All.map({$0.rawValue}))
        
    }
    
    
    func selectedAggregationMethod() -> AggregationMethod?{
        return AggregationMethod(rawValue: self.stringValue)
    }
    
}
