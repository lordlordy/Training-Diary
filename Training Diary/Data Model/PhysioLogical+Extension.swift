//
//  PhysioLogical+Extension.swift
//  Training Diary
//
//  Created by Steven Lord on 09/03/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Foundation

extension Physiological{
    
    @objc dynamic var recordingDate: String{
        return fromDate!.iso8601Format()
    }
    
    
}
