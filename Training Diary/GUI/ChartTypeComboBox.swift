//
//  ChartTypeComboBox.swift
//  Training Diary
//
//  Created by Steven Lord on 23/11/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Cocoa

class ChartTypeComboBox: NSComboBox {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.addItems(withObjectValues: GraphView.ChartType.AllChartTypes.map({$0.rawValue}))
    }
    
    func selectedChartType() -> GraphView.ChartType?{
        return GraphView.ChartType(rawValue: self.stringValue)
    }
    
    
    
}
