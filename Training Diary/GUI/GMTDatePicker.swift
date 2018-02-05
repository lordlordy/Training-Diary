//
//  GMTDatePicker.swift
//  Training Diary
//
//  Created by Steven Lord on 03/02/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class GMTDatePicker: NSDatePicker {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.timeZone = TimeZone.init(secondsFromGMT: 0)
    }
    
}
