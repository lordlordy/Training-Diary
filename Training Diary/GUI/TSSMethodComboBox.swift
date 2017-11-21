//
//  TSSMethodComboBox.swift
//  Training Diary
//
//  Created by Steven Lord on 07/11/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Cocoa

class TSSMethodComboBox: NSComboBox {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.addItems(withObjectValues: TSSMethod.AllMethods.map({$0.rawValue}))
        
    }
    
    func selectedTSSMethod() -> TSSMethod?{
        return TSSMethod(rawValue: self.stringValue)
    }
}
