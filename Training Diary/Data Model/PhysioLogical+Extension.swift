//
//  PhysioLogical+Extension.swift
//  Training Diary
//
//  Created by Steven Lord on 09/03/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Foundation

extension Physiological{
    
    
    //this is for JSON serialisation
    @objc dynamic var iso8061DateString: String{
        return fromDate?.iso8601Format() ?? ""
    }
    
    //for csv serialisation - simple data
    @objc dynamic var fromDateString: String{
        return fromDate?.dateOnlyString() ?? ""
    }
    
}
