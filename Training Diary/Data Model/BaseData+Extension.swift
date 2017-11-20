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
        return EddingtonNumber.eddingtonCode(forActivity: activity!, activityType: activityType!, period: period!, unit: unit!)
    }
    
    @objc dynamic var annualEddingtonCode: String{
        return EddingtonNumber.annualEddingtonCode(year: year, forActivity: activity!, activityType: activityType!, period: period!, unit: unit!)
    }
    
    @objc dynamic var id: String{
        if let d = date{
            return d.dateOnlyString() + ":" + eddingtonCode

        }else{
            return "NoDate" + ":" + eddingtonCode
        }
    }
    
    
}
