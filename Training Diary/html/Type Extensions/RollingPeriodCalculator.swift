//
//  RollingPeriodCalculator.swift
//  Training Diary
//
//  Created by Steven Lord on 27/04/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Foundation

protocol RollingPeriodCalculator{
     func addAndReturnValue(forDate date: Date?, value v: Double, weighting w: Double?) -> Double?
}
