//
//  DataSeriesDefinition.swift
//  Training Diary
//
//  Created by Steven Lord on 04/05/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Foundation

class DataSeriesDefinition{
    
    //note these being nil means ALL
    let dayType: DayType?
    let activity: Activity?
    let activityType: ActivityType?
    let equipment: Equipment?
    let aggregationMethod: AggregationMethod
    let period: Period
    let unit: Unit
    var name: String{
        return createName(isLong: true)
    }
    var shortName: String{
        return createName(isLong: false)
    }
    
    required init(dayType dt: DayType? = nil, activity a: Activity? = nil, activityType at: ActivityType? = nil, equipment e: Equipment? = nil, aggregationMethod ag: AggregationMethod, period p: Period, unit u: Unit){
        dayType = dt
        activity = a
        activityType = at
        equipment = e
        aggregationMethod = ag
        period = p
        unit = u
    }
    
    private func createName(isLong: Bool) -> String{
        var name: String = ""
        if let dt = dayType{
            name += dt.rawValue + ":"
        }else if isLong{
            name += "All:"
        }
        if let a = activity{
            name += a.name! + ":"
        }else if isLong{
            name += "All:"
        }
        if let at = activityType{
            name += at.name! + ":"
        }else if isLong{
            name += "All:"
        }
        if let e = equipment{
            name += e.name! + ":"
        }else if isLong{
            name += "All:"
        }
        name += aggregationMethod.rawValue + ":"
        name += period.rawValue + ":"
        name += unit.rawValue
        
        return name
        
    }
    
    
    
    
    
}
