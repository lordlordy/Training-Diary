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
        return EddingtonNumber.code(activity, activityType, period!, unit!)
    }
}
