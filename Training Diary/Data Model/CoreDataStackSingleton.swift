//
//  CoreDataStackSingleton.swift
//  Training Diary
//
//  Created by Steven Lord on 07/10/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Foundation
import CoreData

/*
 This class is meant to be purely for mediating with the Core Data Stack. There is some
 additional functionality in here that should be extracted in to another class mainly
 around creation of Base Data
*/
class CoreDataStackSingleton{
    
    static let shared = CoreDataStackSingleton()
    
    // MARK: - Core Data stack
    
    lazy var trainingDiaryPC: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Training_Diary")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            let type = storeDescription.type
            let url = storeDescription.url
            if let error = error {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error)")
            }
        })
        return container
    }()
    
    public func printEntityCounts(forDiary td: TrainingDiary){
    
        print("Entity counts for Training Diary: \(String(describing: td.name))")
            
        let days        = getCount(forEntity: ENTITY.Day, forTrainingDiary: td)
        let workouts    = getCount(forEntity: ENTITY.Workout, forTrainingDiary: td)
        let weights     = getCount(forEntity: ENTITY.Weight, forTrainingDiary:td)
        let physios     = getCount(forEntity: ENTITY.Physiological, forTrainingDiary:td)
        let edNums      = getCount(forEntity: ENTITY.EddingtonNumber, forTrainingDiary: td)
        let baseData    = getCount(forEntity: ENTITY.BaseData, forTrainingDiary:td)
            
        print("Number of days: \(days)")
        print("Number of workouts: \(workouts)")
        print("Number of weights: \(weights)")
        print("Number of physiologicals:  \(physios)")
        print("Number of BaseData:  \(edNums)")
        print("Number of EddingtonNumbers:  \(baseData)")
        
    }

    func createBaseData(forTrainingDiary td: TrainingDiary){

        let start = Date()
        var count = 0
        
        let sortedDays = getDays(forTrainingDiary: td).sorted(by: {$0.date! < $1.date!})
        for a in Activity.allActivities{
            for at in a.typesForEddingtonNumbers(){
                for u in a.unitsForEddingtonNumbers(){
                    if !u.isMetric{
                        //metrics are calculated from other Units.
                        count += createBaseData(forSortedDays: sortedDays, activity: a, activityType: at, unit: u, trainingDiary: td)
                    }
                }
            }
        }
        td.setValue(Date(), forKey: TrainingDiaryProperty.baseDataLastUpdate.rawValue)
        print("Base data rebuild took \(Date().timeIntervalSince(start)) seconds creating \(count) records")
    }

    func createBaseData(activity a: Activity, activityType at: ActivityType, unit u: Unit, trainingDiary td: TrainingDiary){

        let days = getDays(forTrainingDiary: td)
        let sortedDays = days.sorted(by: {$0.date! < $1.date!})
        let _ = createBaseData(forSortedDays: sortedDays, activity: a, activityType: at, unit: u, trainingDiary: td)
    }

    
    func baseDataValues(toYearEnd ye: Int16, activity: Activity, activityType: ActivityType, period: Period, unit: Unit, forTrainingDiary td: TrainingDiary) -> (eddingtonCode: String, values: [Double]){
        let myFetch = NSFetchRequest<NSFetchRequestResult>.init(entityName: "BaseData")

        myFetch.predicate = NSPredicate.init(format: "%@ == activity and %@ == activityType AND %@ == period AND %@ == unit AND year <= %i AND trainingDiary == %@", argumentArray: [activity.rawValue, activityType.rawValue,period.rawValue,unit.rawValue, ye, td])
        return baseDataValuesFor(fetch: myFetch)
    }

    func baseDataValues(forYear y: Int16, activity a: Activity, activityType at: ActivityType, period p: Period, unit u: Unit, forTrainingDiary td: TrainingDiary) -> (eddingtonCode: String, values: [Double]){
        let myFetch = NSFetchRequest<NSFetchRequestResult>.init(entityName: "BaseData")
        
        myFetch.predicate = NSPredicate.init(format: "%@ == activity and %@ == activityType AND %@ == period AND %@ == unit AND year == %i AND trainingDiary == %@", argumentArray: [a.rawValue, at.rawValue,p.rawValue,u.rawValue, y, td])
        var result = baseDataValuesFor(fetch: myFetch)
        result.eddingtonCode = EddingtonNumber.annualEddingtonCode(forYear: y, activity: a, activityType: at, period: p, unit: u)
        return result
    }
    
    
    func save(){
        do {
            try trainingDiaryPC.viewContext.save()
        } catch {
            print(error)
        }
    }
    


    

    func getDaysOrdered(byKey key: String, isAcending: Bool, trainingDiary td: TrainingDiary) -> [Day]{
        let descriptor = NSSortDescriptor.init(key: key, ascending: isAcending)
        return getDays(sortDescriptor: [descriptor], trainingDiary: td)
    }
    
    
    func getWeightAndFat(forDay day: Date) -> (weight: Double, fatPercentage: Double){
        if let weight = getWeight(forDay: day){
            return (weight.kg, weight.fatPercent)
        }else{
            return (0.0,0.0)
        }
    }
    
    func getRestingHeartRate(forDay day: Date) -> Int16{
        if let physio = getPhysiological(forDay: day){
            return physio.restingHR
        }else{
            return 0
        }
    }
    
 
    
    /*this checks if this Eddington number exists, if not creates a new one and adds to the training diary
     */
    func getEddingtonNumber(forYear y: Int16, activity a: Activity, activityType at: ActivityType, period p: Period, unit u: Unit, trainingDiary td: TrainingDiary) -> EddingtonNumber{
        
        let myFetch = NSFetchRequest<NSFetchRequestResult>.init(entityName: ENTITY.EddingtonNumber.rawValue)
        
        myFetch.predicate = NSPredicate.init(format: "%@ == activity and %@ == activityType AND %@ == period AND %@ == unit AND %i == year AND trainingDiary == %@ ", argumentArray: [a.rawValue, at.rawValue,p.rawValue,u.rawValue, y, td])
    
        do{
            let results = try trainingDiaryPC.viewContext.fetch(myFetch) as! [EddingtonNumber]
            if results.count == 1{
                return results[0]
            }else if results.count > 1{
                print("*** duplicates found (\(results.count) records returned) for eddington number \(String(describing: results[0].eddingtonCode))")
                return results[0]
            }
        }catch{
            print("Eddington number Fetch failed with error: \(error)")
            let newEd =  createNewEddingtonNumber(forYear:y,activity:a,activityType:at,period:p,unit:u)
            td.mutableSetValue(forKey: TrainingDiaryProperty.eddingtonNumbers.rawValue).add(newEd)
            return newEd
        }
    
        //return newly created one
        let newEd =  createNewEddingtonNumber(forYear:y,activity:a,activityType:at,period:p,unit:u)
        td.mutableSetValue(forKey: TrainingDiaryProperty.eddingtonNumbers.rawValue).add(newEd)
        return newEd

    }
    
    func deleteAllEddingtonNumbers(forTrainingDiary td: TrainingDiary){
        
        let eddingtonNumberRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: ENTITY.EddingtonNumber.rawValue)
        eddingtonNumberRequest.predicate = NSPredicate.init(format: "trainingDiary = %@", argumentArray: [td])
        do {
            let ednum = try CoreDataStackSingleton.shared.trainingDiaryPC.viewContext.fetch(eddingtonNumberRequest)
            for e in ednum{
                CoreDataStackSingleton.shared.trainingDiaryPC.viewContext.delete(e as! NSManagedObject)
            }
        } catch {
            print("Failed to delete eddington numbers with error:")
            print(error)
        }
    }
    
    
    /*returns number of base data added
     checks if Base Data exists and returns it, otherwise creates a new one
     */
    func addBaseDataFor(date d: Date, activity a: Activity, activityType at: ActivityType, period p: Period, unit u: Unit, value v: Double, trainingDiary td: TrainingDiary) -> Int{
        if v > 0.99{
            let bd = getBaseData(date: d, activity: a, activityType: at, period: p, unit: u, value: v, trainingDiary: td)
            bd.setValue(v, forKey: BaseDataProperty.value.rawValue)
            return 1
        }
        return 0
    }


    // MARK: - Private
    
    private func getPhysiological(forDay day: Date) -> Physiological?{
        let myFetch = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Physiological")
        myFetch.predicate = NSPredicate.init(format: "%@ >= fromDate AND %@ <= toDate", argumentArray: [day,day])
        
        do{
            let results = try trainingDiaryPC.viewContext.fetch(myFetch)
            let physiologicals: [Physiological] = results as! [Physiological]
            if(physiologicals.count >= 1){
                return physiologicals[0]
            }else{
                return nil
            }
        }catch{
            print("Physiological fetch for date \(day) failed with error \(error)")
        }
        return nil
    }
    
    private func getWeight(forDay day: Date) -> Weight?{
        let myFetch = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Weight")
        myFetch.predicate = NSPredicate.init(format: "%@ >= fromDate AND %@ <= toDate", argumentArray: [day,day])
        
        do{
            let results = try trainingDiaryPC.viewContext.fetch(myFetch)
            let weights: [Weight] = results as! [Weight]
            if(weights.count >= 1){
                return weights[0]
            }else{
                return nil
            }
        }catch{
            print("Weight fetch for date \(day) failed with error \(error)")
        }
        return nil
    }
    
    private func createBaseData(forSortedDays sortedDays: [Day], activity a: Activity, activityType at: ActivityType, unit u: Unit, trainingDiary td: TrainingDiary) -> Int{
        print("\(a.rawValue):\(at.rawValue):\(u.rawValue)")
        var start = Date()
        let dailyValues: [(date: Date,value: Double)] = sortedDays.map{(date: $0.date!, value: $0.valueFor(activity: a, activityType: at, unit: u))}
        let i = createBaseDataFor(forDailyValues: dailyValues, forActivity: a, forActivityType: at, forUnit: u, trainingDiary: td)
        print("\(i) Base Data Elements created in  \(Date().timeIntervalSince(start)) seconds. Saving...")
        start = Date()
        save()
        print("Done. Save took \(Date().timeIntervalSince(start)) seconds")
        return i
    }

    
    private func getDays(sortDescriptor : [NSSortDescriptor]?, trainingDiary td: TrainingDiary) -> [Day]{
        let results = getEntitiesFor(entityName: "Day",predicate: NSPredicate.init(format: "trainingDiary == %@", argumentArray: [td]), sortDescriptor: sortDescriptor, trainingDiary: td)
        return results as! [Day]
    }

    
    private func getEntitiesFor(entityName name: String, predicate: NSPredicate?, sortDescriptor: [NSSortDescriptor]?, trainingDiary td: TrainingDiary) -> [NSManagedObject]{
        let myFetch = NSFetchRequest<NSFetchRequestResult>.init(entityName: name)
        if let p = predicate{
            myFetch.predicate = p
        }
        
        
        if let sd = sortDescriptor{
            myFetch.sortDescriptors = sd
        }
        
        do{
        
            let results = try trainingDiaryPC.viewContext.fetch(myFetch)
            return results as! [NSManagedObject]

        }catch{
            print("Fetch failed with error: \(error)")
        }
        return []
    }

    private func getEntityCountFor(entityName name: String, predicate: NSPredicate?, sortDescriptor: [NSSortDescriptor]?, trainingDiary td: TrainingDiary) ->Int{
        let myFetch = NSFetchRequest<NSFetchRequestResult>.init(entityName: name)
        if let p = predicate{
            myFetch.predicate = p
        }
        
        
        if let sd = sortDescriptor{
            myFetch.sortDescriptors = sd
        }
        
        do{
            
            let results = try trainingDiaryPC.viewContext.count(for: myFetch)
            return results
        }catch{
            print("Fetch failed with error: \(error)")
        }
        return 0
    }
    
    private func deleteAllBaseData(forTrainingDiary td: TrainingDiary){
        
        let baseDataRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: ENTITY.BaseData.rawValue)
        baseDataRequest.predicate = NSPredicate.init(format: "trainingDiary == %@", argumentArray: [td])
        
        do {
            let bd = try CoreDataStackSingleton.shared.trainingDiaryPC.viewContext.fetch(baseDataRequest)
            print("starting to delete \(bd.count) base data...")
            for b in bd{
                CoreDataStackSingleton.shared.trainingDiaryPC.viewContext.delete(b as! NSManagedObject)
            }
            print("DONE")
        } catch {
            print("Failed to delete base data with error:")
            print(error)
        }
    }
    

    private func createBaseDataFor(forDailyValues: [(date: Date, value: Double)], forActivity activity: Activity, forActivityType activityType: ActivityType, forUnit unit: Unit, trainingDiary td: TrainingDiary) -> Int{
        var wtd             = 0.0
        var mtd             = 0.0
        var ytd             = 0.0
        var rWeek           = RollingSum.init(size: 7)
        var rMonth          = RollingSum.init(size: 30)
        var rYear           = RollingSum.init(size: 365)
        let tsbCalculator   = TSBCalculator()
        var i = 0
        
        for d in forDailyValues{
            let isWeekEnd = d.date.isEndOfWeek()
            let isMonthEnd = d.date.isEndOfMonth()
            let isYearEnd = d.date.isEndOfYear()
            
            //SWIM
            wtd     = wtd + d.value
            mtd     = mtd + d.value
            ytd     = ytd + d.value
            let rw  = rWeek.addAndReturnTotal(d.value)
            let rm  = rMonth.addAndReturnTotal(d.value)
            let ry  = rYear.addAndReturnTotal(d.value)
            
            var tsb: (atl: Double, ctl: Double, tsb: Double)
            //create RollDayItems
            if(unit == Unit.TSS){
                //currently only done for Day ... could 'in theory' do for all periods
                tsb = tsbCalculator.calculate(forTSS: d.value)

                i += addBaseDataFor(date: d.date, activity: activity, activityType: activityType, period: Period.Day, unit: Unit.ATL, value: tsb.atl,trainingDiary: td)
                i += addBaseDataFor(date: d.date, activity: activity, activityType: activityType, period: Period.Day, unit: Unit.CTL , value: tsb.ctl,trainingDiary: td)
                i += addBaseDataFor(date: d.date, activity: activity, activityType: activityType, period: Period.Day, unit: Unit.TSB, value: tsb.tsb,trainingDiary: td)
            }
 
            i += addBaseDataFor(date: d.date, activity: activity, activityType: activityType, period: Period.Day, unit: unit, value: d.value,trainingDiary: td)
            i += addBaseDataFor(date: d.date, activity: activity, activityType: activityType, period: Period.WeekToDate, unit: unit, value: wtd,trainingDiary: td)
            i += addBaseDataFor(date: d.date, activity: activity, activityType: activityType, period: Period.MonthToDate, unit: unit, value: mtd,trainingDiary: td)
            i += addBaseDataFor(date: d.date, activity: activity, activityType: activityType, period: Period.YearToDate, unit: unit, value: ytd,trainingDiary: td)
            i += addBaseDataFor(date: d.date, activity: activity, activityType: activityType, period: Period.rWeek, unit: unit, value: rw,trainingDiary: td)
            i += addBaseDataFor(date: d.date, activity: activity, activityType: activityType, period: Period.rMonth, unit: unit, value: rm,trainingDiary: td)
            i += addBaseDataFor(date: d.date, activity: activity, activityType: activityType, period: Period.rYear, unit: unit, value: ry,trainingDiary: td)
            
            if isWeekEnd{
                i += addBaseDataFor(date: d.date, activity: activity, activityType: activityType, period: Period.Week, unit: unit, value: wtd,trainingDiary: td)
                wtd = 0.0
            }
            if isMonthEnd{
                i += addBaseDataFor(date: d.date, activity: activity, activityType: activityType, period: Period.Month, unit: unit, value: mtd,trainingDiary: td)
                mtd = 0.0
            }
            if isYearEnd{
                i += addBaseDataFor(date: d.date, activity: activity, activityType: activityType, period: Period.Year, unit: unit, value: ytd,trainingDiary: td)
                ytd = 0.0
            }
        }
        return i
    }

    
    /*this checks if this Eddington number exists, if not creates a new one and adds to the training diary
     
     
     let bde = BaseDataElement(date: d.date!, activity: a, type: at, period: p, unit: u, value: value)
     
     */
    private func getBaseData(date d: Date, activity a: Activity, activityType at: ActivityType, period p: Period, unit u: Unit, value v: Double, trainingDiary td: TrainingDiary) -> BaseData{
        
        let myFetch = NSFetchRequest<NSFetchRequestResult>.init(entityName: ENTITY.BaseData.rawValue)
        
        myFetch.predicate = NSPredicate.init(format: "%@ == activity and %@ == activityType AND %@ == period AND %@ == unit AND %i == date AND trainingDiary == %@ ", argumentArray: [a.rawValue, at.rawValue,p.rawValue,u.rawValue, d, td])
        
        do{
            let results = try trainingDiaryPC.viewContext.fetch(myFetch) as! [BaseData]
            if results.count == 1{
                return results[0]
            }else if results.count > 1{
                print("*** duplicates found (\(results.count) records returned) for Base Data \(String(describing: results[0].id))")
                return results[0]
            }
        }catch{
            print("Base Data  Fetch failed with error: \(error)")
            let newBD =  createNewBaseDataElement(date: d, activity: a, activityType: at, period: p, unit: u, value: v, andTrainingDiary: td)
            td.mutableSetValue(forKey: TrainingDiaryProperty.baseData.rawValue).add(newBD)
            return newBD
        }
        
        //return newly created one
        let newBD =  createNewBaseDataElement(date: d, activity: a, activityType: at, period: p, unit: u, value: v, andTrainingDiary: td)
        td.mutableSetValue(forKey: TrainingDiaryProperty.baseData.rawValue).add(newBD)
        return newBD
        
    }
    
    private func createNewBaseDataElement(date d: Date, activity a: Activity, activityType at: ActivityType, period p: Period, unit u: Unit, value v: Double, andTrainingDiary td: TrainingDiary) -> BaseData{
        let bd = NSManagedObject.init(entity: NSEntityDescription.entity(forEntityName: ENTITY.BaseData.rawValue, in: trainingDiaryPC.viewContext)!, insertInto: trainingDiaryPC.viewContext)
        let baseDataMOSet = td.mutableSetValue(forKey: TrainingDiaryProperty.baseData.rawValue)
        baseDataMOSet.add(bd)
        bd.setValue(a.rawValue, forKey: BaseDataProperty.activity.rawValue)
        bd.setValue(at.rawValue, forKey: BaseDataProperty.activityType.rawValue)
        bd.setValue(d, forKey: BaseDataProperty.date.rawValue)
        bd.setValue(p.rawValue, forKey: BaseDataProperty.period.rawValue)
        bd.setValue(u.rawValue, forKey: BaseDataProperty.unit.rawValue)
        bd.setValue(d.year(), forKey: BaseDataProperty.year.rawValue)
        return bd as! BaseData
    }

    private func baseDataValuesFor(fetch: NSFetchRequest<NSFetchRequestResult>) -> (eddingtonCode: String, values: [Double]){
        do{
            let results = try trainingDiaryPC.viewContext.fetch(fetch) as! [BaseData]
            if results.count > 0{
                return (eddingtonCode: results[0].eddingtonCode, values: results.map{$0.value})
            }else{
                return(eddingtonCode: "No Values", values: [])
            }
        }catch{
            print("Fetch failed with error: \(error)")
            return(eddingtonCode: "No Values", values: [])
        }
    }
    
    //CHECK- should this set the EddingtonNumber values via setValue(ForKey: ?
    private func createNewEddingtonNumber(forYear y: Int16, activity a: Activity, activityType at: ActivityType, period p: Period, unit u: Unit) -> EddingtonNumber{
        
        let mo = NSManagedObject.init(entity: NSEntityDescription.entity(forEntityName: ENTITY.EddingtonNumber.rawValue, in: trainingDiaryPC.viewContext)!, insertInto: trainingDiaryPC.viewContext)
         let ed = mo as! EddingtonNumber
        ed.year = y
        ed.activity = a.rawValue
        ed.activityType = at.rawValue
        ed.period = p.rawValue
        ed.unit = u.rawValue
        
        return ed
    }
    
    private func getCount(forEntity entity: ENTITY, forTrainingDiary td: TrainingDiary) -> Int{
        switch entity{
        case .Workout:
            return getEntityCountFor(entityName: entity.rawValue,predicate: NSPredicate.init(format: "day.trainingDiary == %@", argumentArray: [td]), sortDescriptor: nil, trainingDiary: td)
            
        default:
            return getEntityCountFor(entityName: entity.rawValue,predicate: NSPredicate.init(format: "trainingDiary == %@", argumentArray: [td]), sortDescriptor: nil, trainingDiary: td)
            
        }
    }
    
    private func getDays(forTrainingDiary td: TrainingDiary) -> [Day]{
        return getDays(sortDescriptor: nil, trainingDiary: td)
    }
    
    private init(){
    }

}
