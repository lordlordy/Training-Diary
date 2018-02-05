//
//  EddingtonHistory+Extension.swift
//  Training Diary
//
//  Created by Steven Lord on 01/02/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Foundation

extension EddingtonHistory{
    
    @objc dynamic var maturity: Double { return EddingtonNumberCalculator.calculateMaturity(ednum: Int(value), plusOne: Int(plusOne), max: max)}
    
}
