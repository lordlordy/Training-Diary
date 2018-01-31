//
//  LTDEdNum+Extension.swift
//  Training Diary
//
//  Created by Steven Lord on 17/01/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Foundation

extension LTDEdNum{
    @objc dynamic var code: String{
        let ALL = ConstantString.EddingtonAll.rawValue
        return EddingtonNumber.code(activity: activity ?? ALL, activityType: activityType ?? ALL, equipment: equipment ?? ALL, period: period!,unit: unit!)
    }
    
    var levelString: String{
        var result = ""
        result += activity ?? ConstantString.EddingtonAll.rawValue
        result += ":" + (equipment ?? ConstantString.EddingtonAll.rawValue)
        result += ":" + (activityType ?? ConstantString.EddingtonAll.rawValue)
        result += ":" + unit!
        result += ":" + period!
        return result
    }
}
