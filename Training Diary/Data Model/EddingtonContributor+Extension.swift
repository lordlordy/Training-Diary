//
//  EddingtonContributor+Extension.swift
//  Training Diary
//
//  Created by Steven Lord on 23/05/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Foundation

extension EddingtonContributor{
    //this is for JSON serialisation
    @objc dynamic var iso8601DateString: String{
        return date!.iso8601Format()
    }
    
    //this is for csv serialisation
    @objc dynamic var dateCSVString: String{
        return date?.dateOnlyString() ?? ""
    }
}
