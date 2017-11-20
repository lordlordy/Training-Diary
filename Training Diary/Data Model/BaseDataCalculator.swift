//
//  BaseDataCalculator.swift
//  Training Diary
//
//  Created by Steven Lord on 03/11/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Foundation

class BaseDataCalculator{
    
    static var shared = BaseDataCalculator.init()
    var count = 0
    
    func createBaseData(forDay d: Day){
        let start = Date()
        for a in Activity.allActivities{
            for at in a.typesForEddingtonNumbers(){
                for u in a.unitsForEddingtonNumbers(){
                    for p in Period.baseDataPeriods{
                        if let bdc = BaseDataCreatorFactory.shared.baseDataCreator(forActivity: a, andActivityType: at, andUnit: u, andPeriod: p){
                            let value = bdc.create(forDay: d)
                            if value > 0.0{
                                count += CoreDataStackSingleton.shared.addBaseDataFor(date: d.date!, activity: a, activityType: at, period: p, unit: u, value: value,  trainingDiary: d.trainingDiary!)
                            }
                        }
                    }
                }
            }
        }
        print("Time taken to create \(count) base data for a \(d.date!) was \(Date().timeIntervalSince(start)) seconds")
    }
    
    func createBaseDataMethod2(forDay d: Day){
        let start = Date()
        for a in Activity.allActivities{
            for at in a.typesForEddingtonNumbers(){
                for u in a.unitsForEddingtonNumbers(){
                    for p in Period.baseDataPeriods{

                            let value = d.valueFor(period: p, activity: a, activityType: at, unit: u)
                            if value > 0.0{
                                count += CoreDataStackSingleton.shared.addBaseDataFor(date: d.date!, activity: a, activityType: at, period: p, unit: u, value: value,  trainingDiary: d.trainingDiary!)
                            }
                        
                    }
                }
            }
        }
        print("Time taken to create \(count) base data for a \(d.date!) was \(Date().timeIntervalSince(start)) seconds")
    }

    
    func createBaseDataDayFirst(forTrainingDiary td: TrainingDiary){
        let start = Date()
        var count = 0
        var calculators: [String: BaseDataCreator] = [:]
        // set up calculators
        for a in Activity.allActivities{
            for at in a.typesForEddingtonNumbers(){
                for u in a.unitsForEddingtonNumbers(){
                    for p in Period.baseDataPeriods{
                        let key = a.rawValue + at.rawValue + u.rawValue + p.rawValue
                        calculators[key] = BaseDataCreatorFactory.shared.baseDataCreator(forActivity: a, andActivityType: at, andUnit: u, andPeriod: p)
                    }
                }
            }
        }
        for d in CoreDataStackSingleton.shared.getDaysOrdered(byKey: DayProperty.date.rawValue, isAcending: true, trainingDiary: td){
            for a in Activity.allActivities{
                for at in a.typesForEddingtonNumbers(){
                    for u in a.unitsForEddingtonNumbers(){
                        for p in Period.baseDataPeriods{
                            let key = a.rawValue + at.rawValue + u.rawValue + p.rawValue
                            if let value = calculators[key]?.add(forDay: d){
                                if value > 0{
                                    count += CoreDataStackSingleton.shared.addBaseDataFor(date: d.date!, activity: a, activityType: at, period: p, unit: u, value: value, trainingDiary: td)
                                }
                            }
                        }
                    }
                }
            }
        }
        
        print("\(count) items. Time taken with 'Day first': \(Date().timeIntervalSince(start)) seconds")
    }
    

    func createBaseDataNoCoreDataSave(forTrainingDiary td: TrainingDiary){
        let start = Date()
        // get a handle on the days here so we don't requery them in every calc (there are THOUSANDS!!)
        let days = CoreDataStackSingleton.shared.getDaysOrdered(byKey: DayProperty.date.rawValue, isAcending: true, trainingDiary: td)
        var elements: [BaseData] = []
        for a in Activity.allActivities{
            for at in a.typesForEddingtonNumbers(){
                for u in a.unitsForEddingtonNumbers(){
                    for p in Period.baseDataPeriods{
                        elements.append(contentsOf: createBaseDataNoCoreDataSave(forTrainingDiary: td, activity: a, activityType: at, period: p, unit: u, forDays: days))
                    }
                }
            }
        }
        print("Time taken without save: \(Date().timeIntervalSince(start)) seconds")
        print("\(elements.count) elements created")
    }
    
    
    func createBaseData(forTrainingDiary td: TrainingDiary){
        let start = Date()
        var total: Int = 0
        // get a handle on the days here so we don't requery them in every calc (there are THOUSANDS!!)
        let days = CoreDataStackSingleton.shared.getDaysOrdered(byKey: DayProperty.date.rawValue, isAcending: true, trainingDiary: td)

        for a in Activity.allActivities{
            for at in a.typesForEddingtonNumbers(){
                for u in a.unitsForEddingtonNumbers(){
                    for p in Period.baseDataPeriods{
                        total += createBaseData(forTrainingDiary: td, activity: a, activityType: at, period: p, unit: u, forDays: days)
                    }
                }
            }
        }
        print(total)
        print("Time taken: \(Date().timeIntervalSince(start)) seconds")
    }
    
    func createBaseData(forTrainingDiary td: TrainingDiary, activity a: Activity, activityType at: ActivityType, period p: Period, unit u: Unit) -> Int{
        let days = CoreDataStackSingleton.shared.getDaysOrdered(byKey: DayProperty.date.rawValue, isAcending: true, trainingDiary: td)
        return createBaseData(forTrainingDiary: td, activity: a, activityType: at, period: p, unit: u, forDays: days)
    }

    
    private func createBaseData(forTrainingDiary td: TrainingDiary, activity a: Activity, activityType at: ActivityType, period p: Period, unit u: Unit, forDays days: [Day]) -> Int{
        
        var count: Int = 0
        if let calculator = BaseDataCreatorFactory.shared.baseDataCreator(forActivity: a, andActivityType: at, andUnit: u, andPeriod: p){
            for d in days{
                let value = calculator.add(forDay: d)
                if value > 0{
                    print("\(d.date!) - \(a.rawValue):\(at.rawValue):\(p.rawValue):\(u.rawValue) = \(value)")
                    count += CoreDataStackSingleton.shared.addBaseDataFor(date: d.date!, activity: a, activityType: at, period: p, unit: u, value: value, trainingDiary: td)
                    
                }
            }
        }else{
            //    print("No calculator for \(u)")
        }
        return count
    }
    
    private func createBaseDataNoCoreDataSave(forTrainingDiary td: TrainingDiary, activity a: Activity, activityType at: ActivityType, period p: Period, unit u: Unit, forDays days: [Day]) -> [BaseData]{
        
        var elements: [BaseData] = []
        if let calculator = BaseDataCreatorFactory.shared.baseDataCreator(forActivity: a, andActivityType: at, andUnit: u, andPeriod: p){
            for d in days{
                let value = calculator.add(forDay: d)
                if value > 0{
                    let bd = BaseData()
                    bd.activity = a.rawValue
                    bd.activityType = at.rawValue
                    bd.period = p.rawValue
                    bd.unit = u.rawValue
                    bd.value = value
                    elements.append(bd)
                }
            }
        }
        return elements
    }
    
    //singleton pattern
    private init(){}
    
}
