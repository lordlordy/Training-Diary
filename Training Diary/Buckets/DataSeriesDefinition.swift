//
//  DataSeriesDefinition.swift
//  Training Diary
//
//  Created by Steven Lord on 04/05/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Foundation

//add caching of data in here ... probably.
@objc class DataSeriesDefinition: NSObject{
    
    enum Property: String{
        case from, to, name, shortName
        static var observables: [Property] = [from,to, name, shortName]
    }
    
    var trainingDiary: TrainingDiary?
    //note these being nil means ALL
    var dayType: DayType? { didSet{ createName()}}
    var activity: Activity? { didSet{ createName()}}
    var activityType: ActivityType? { didSet{ createName()}}
    var equipment: Equipment? { didSet{ createName()}}
    var aggregationMethod: AggregationMethod { didSet{ createName()}}
    var period: Period { didSet{ createName()}}
    var unit: Unit { didSet{ createName()}}
    @objc dynamic var from: Date?
    @objc dynamic var to: Date?
    @objc dynamic var name: String = "New Series"
    @objc dynamic var shortName: String = "New Series"
    
    @objc dynamic var dayTypeString: String{
        get{
            return dayType?.rawValue ?? ConstantString.EddingtonAll.rawValue
        } set{
            if let dt = DayType(rawValue: newValue){
                dayType = dt
            }else{
                dayType = nil
            }
        }
    }
    
    @objc dynamic var activityString: String{
        get{
            return activity?.name ?? ConstantString.EddingtonAll.rawValue
        }set{
            if let td = trainingDiary{
                activity = td.activity(forString: newValue)
            }
        }
    }

    @objc dynamic var activityTypeString: String{
        get{
            return activityType?.name ?? ConstantString.EddingtonAll.rawValue
        }set{
            if let td = trainingDiary{
                activityType = td.activityType(forActivity: activityString, andType: newValue)
            }
        }
    }
    
    @objc dynamic var equipmentString: String{
        get{
            return equipment?.name ?? ConstantString.EddingtonAll.rawValue
        }set{
            if let td = trainingDiary{
                equipment = td.equipment(forActivity: activityString, andName: newValue)
            }
        }
    }
    
    @objc dynamic var aggregationMethodString: String{
        get{ return aggregationMethod.rawValue
        }set{
            if let am = AggregationMethod(rawValue: newValue){
                aggregationMethod = am
            }
        }
    }

    @objc dynamic var periodString: String{
        get{ return period.rawValue
        }set{
            if let p = Period(rawValue: newValue){
                period = p
            }
        }
    }
    
    @objc dynamic var unitString: String{
        get{ return unit.rawValue
        }set{
            if let u = Unit(rawValue: newValue){
                unit = u
            }
        }
    }
    
    private var cache: [String: [(date: Date, value: Double)]] = [:]
    
    // note that if trainingDiary is not set it will need to be post initialisation
    required init(dayType dt: DayType? = nil, activity a: Activity? = nil, activityType at: ActivityType? = nil, equipment e: Equipment? = nil, aggregationMethod ag: AggregationMethod, period p: Period, unit u: Unit, trainingDiary td: TrainingDiary? = nil){
        dayType = dt
        activity = a
        activityType = at
        equipment = e
        aggregationMethod = ag
        period = p
        unit = u
        trainingDiary = td
        super.init()
        createName()

    }
    

    
    func getData() -> [(date: Date, value: Double)]{
        var allValues: [(date: Date, value: Double)] = []
        if let td = trainingDiary{
            if let cachedValues = cache[name]{
                allValues = cachedValues
            }else{
                allValues =  td.valuesFor(dayType: dayType, activity: activity, activityType: activityType, equipment: equipment, period: period, aggregationMethod: aggregationMethod, unit: unit, from: td.firstDayOfDiary, to: td.lastDayOfDiary)
                cache[name] = allValues
            }
            let fromDate: Date = from ?? td.firstDayOfDiary
            let toDate: Date = to ?? td.lastDayOfDiary
            return allValues.filter({$0.date >= fromDate && $0.date <= toDate})
        }
        return allValues
    }
    
    private func createName(){
        var name: String = ""
        var shortName: String = ""
        if let dt = dayType{
            name += dt.rawValue + ":"
            shortName += dt.rawValue + ":"
        }else{
            name += "All:"
        }
        if let a = activity{
            name += a.name! + ":"
            shortName += a.name! + ":"
        }else{
            name += "All:"
        }
        if let at = activityType{
            name += at.name! + ":"
            shortName += at.name! + ":"
        }else{
            name += "All:"
        }
        if let e = equipment{
            name += e.name! + ":"
            shortName += e.name! + ":"
        }else{
            name += "All:"
        }
        name += aggregationMethod.rawValue + ":"
        name += period.rawValue + ":"
        name += unit.rawValue
        shortName += aggregationMethod.rawValue + ":"
        shortName += period.rawValue + ":"
        shortName += unit.rawValue

        self.name = name
        self.shortName = shortName
        
    }
    
    
    
    
    
}
