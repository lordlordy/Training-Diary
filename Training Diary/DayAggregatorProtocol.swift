//
//  DayAggregatorProtocol.swift
//  Training Diary
//
//  Created by Steven Lord on 27/04/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Foundation

protocol DayAggregatorProtocol{
    func aggregate(data: [Day]) -> [(date: Date, value: Double)]
}
