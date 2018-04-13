//
//  TSBConstant+Extension.swift
//  Training Diary
//
//  Created by Steven Lord on 04/04/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Foundation
/* deprecated
extension TSBConstant{
    
    @objc dynamic var ctlDecayFactor: Double { return exp(-1 / ctlDays) }
    @objc dynamic var atlDecayFactor: Double { return exp(-1 / atlDays) }
    
    func ctlDecayFactor(afterNDays n: Int) -> Double{
        return pow(ctlDecayFactor, Double(n))
    }

    func ctlReplacementTSSFactor(afterNDays n: Int) -> Double{
        return (1 - pow(ctlDecayFactor,Double(n))) / (1 - ctlDecayFactor)
    }

    func atlDecayFactor(afterNDays n: Int) -> Double{
        return pow(atlDecayFactor, Double(n))
    }

    func atlReplacementTSSFactor(afterNDays n: Int) -> Double{
        return (1 - pow(atlDecayFactor,Double(n))) / (1 - ctlDecayFactor)
    }
}
*/
