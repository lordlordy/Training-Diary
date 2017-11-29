//
//  BaseData+Extension.swift
//  Training Diary
//
//  Created by Steven Lord on 10/11/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Foundation

extension BaseData{
    
    @objc dynamic var eddingtonCode: String{
        var result = activity! + ":" + activityType!
        result += ":" + period! + ":" + unit!
        return result

    }
    
    @objc dynamic var annualEddingtonCode: String{
        let result = String(year) + ":" + eddingtonCode
        return result
        
    }
 
    @objc dynamic var id: String{
        if let d = date{
            return d.dateOnlyString() + ":" + eddingtonCode

        }else{
            return "NoDate" + ":" + eddingtonCode
        }
    }
    
    
}
