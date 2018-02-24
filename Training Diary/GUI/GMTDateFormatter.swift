//
//  GMTDateFormatter.swift
//  Training Diary
//
//  Created by Steven Lord on 21/02/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Cocoa

class GMTDateFormatter: DateFormatter {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.timeZone = TimeZone(secondsFromGMT: 0)
    }
    
}
