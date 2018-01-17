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
        
        print("Number of days: \(days)")
        print("Number of workouts: \(workouts)")
        print("Number of weights: \(weights)")
        print("Number of physiologicals:  \(physios)")
        print("Number of EddingtonNumbers:  \(edNums)")
        
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
    
    
/*    func getWeightAndFat(forDay day: Date, andTrainingDiary td: TrainingDiary) -> (weight: Double, fatPercentage: Double){
        if let weight = getWeight(forDay: day, andTrainingDiary: td){
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
  */
    //inserts fields for metrics if they don't already exist
    func populateMetricPlaceholders(forDay d: Day){
        let metricsMOSet = d.mutableSetValue(forKey: DayProperty.metrics.rawValue)
        let metricKeys: [String] = (metricsMOSet.allObjects as! [Metric]).map({$0.uniqueKey})
        for metric in Unit.metrics{
            for a in Activity.allActivities{
                if a != Activity.All{ // All is calculated
                    if !metricKeys.contains(Metric.key(forActivity: a, andUnit: metric)){
                        //add metric
                        let m = NSManagedObject.init(entity: NSEntityDescription.entity(forEntityName: ENTITY.Metric.rawValue, in: trainingDiaryPC.viewContext)!, insertInto: trainingDiaryPC.viewContext)
                        m.setValue(metric.rawValue, forKey: MetricProperty.name.rawValue)
                        m.setValue(a.rawValue, forKey: MetricProperty.activity.rawValue)
                        metricsMOSet.add(m)
                    }
                }
            }
        }
    }
    
 
    //MARK: - Eddington Number Support
    
    func newEddingtonHistory() -> EddingtonHistory{
        let eh = NSManagedObject.init(entity: NSEntityDescription.entity(forEntityName: ENTITY.EddingtonHistory.rawValue, in: trainingDiaryPC.viewContext)!, insertInto: trainingDiaryPC.viewContext)
        return eh as! EddingtonHistory
    }

    func newEddingtonAnnualHistory() -> EddingtonAnnualHistory{
        let eh = NSManagedObject.init(entity: NSEntityDescription.entity(forEntityName: ENTITY.EddingtonAnnualHistory.rawValue, in: trainingDiaryPC.viewContext)!, insertInto: trainingDiaryPC.viewContext)
        return eh as! EddingtonAnnualHistory
    }
    
    func newEddingtonContributor() -> EddingtonContributor{
        let eh = NSManagedObject.init(entity: NSEntityDescription.entity(forEntityName: ENTITY.EddingtonContributor.rawValue, in: trainingDiaryPC.viewContext)!, insertInto: trainingDiaryPC.viewContext)
        return eh as! EddingtonContributor
    }
    
    func newEddingtonAnnualContributor() -> EddingtonAnnualContributor{
        let eh = NSManagedObject.init(entity: NSEntityDescription.entity(forEntityName: ENTITY.EddingtonAnnualContributor.rawValue, in: trainingDiaryPC.viewContext)!, insertInto: trainingDiaryPC.viewContext)
        return eh as! EddingtonAnnualContributor
    }
    
    func newLTDEdNum() -> LTDEdNum{
        let len = NSManagedObject.init(entity: NSEntityDescription.entity(forEntityName: ENTITY.LTDEdNum.rawValue, in: trainingDiaryPC.viewContext)!, insertInto: trainingDiaryPC.viewContext)
        return len as! LTDEdNum
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
 
    // MARK: - Private
    
/*    private func getPhysiological(forDay day: Date) -> Physiological?{
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
 */
/*    private func getWeight(forDay day: Date, andTrainingDiary td: TrainingDiary) -> Weight?{
        let myFetch = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Weight")
        myFetch.predicate = NSPredicate.init(format: "%@ >= fromDate AND %@ <= toDate and %@ == trainingDiary", argumentArray: [day,day,td])
        
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
*/
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
