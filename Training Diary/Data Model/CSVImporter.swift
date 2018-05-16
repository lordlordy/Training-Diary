//
//  CSVImporter.swift
//  Training Diary
//
//  Created by Steven Lord on 30/11/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Cocoa

class CSVImporter{
    
    struct ColumnDetails{
        var entity: ENTITY
        var activity: String?
        var property: String
    }
    
    private var dictionary: [Int:ColumnDetails] = [:]
    
    public func importDiary(fromURL url: URL){
        print("Loading JSON from URL = \(url) ...")
        do{
            let string = try String(contentsOf: url)
            parseCSV(data: string)
        }catch{
            print("error initialising Training Diary for URL: " + url.absoluteString)
            
        }
    }
    
    private func parseCSV(data: String){

        let rowsAndColumns = splitUpCSV(data)
        if rowsAndColumns.count == 0 { return }

        setUpIndexes(rowsAndColumns[0])

        createManagedObjectModelFrom(csv: rowsAndColumns)
    
    }
    
    private func createManagedObjectModelFrom(csv: [[String]]){
        //create the base Object - TrainingDiary
        let td = CoreDataStackSingleton.shared.newTrainingDiary()
        td.setValue("CSV IMPORT - \(Date().dateOnlyShorterString())", forKey: "name")

        let daysMOSet = td.mutableSetValue(forKey: TrainingDiaryProperty.days.rawValue)
        
        var index = 0
        for row in csv{
            //first row is labels
            if index > 0{
                var colIndex: Int = 0
                var objDict: [String:NSManagedObject] = [:]
                
                let day = CoreDataStackSingleton.shared.newDay()
                daysMOSet.add(day)
                objDict[ENTITY.Day.rawValue] = day

                for c in row{
                    let col = c.trimmingCharacters(in: CharacterSet.init(charactersIn: "\"\r"))
                    if let colDetails = dictionary[colIndex]{
                        var mObject: NSManagedObject
                        if let managedObj = objDict[dictStr(colDetails)]{
                            mObject = managedObj
                        }else{
                            // create
                            let newMO = createManagedObject(forColumn: colDetails, trainingDiary: td, andDay: day)
                            objDict[dictStr(colDetails)] = newMO
                            mObject = newMO
                        }
                        parseColValue(col: col, colDetails: colDetails, managedOject: mObject, trainingDiary: td)
                    }
                    colIndex += 1
                }
                removeZeroDurationWorkouts(fromDay: day)
                
                if let weight = objDict[ENTITY.Weight.rawValue] as? Weight{
                    if weight.kg == 0.0{
                        td.mutableSetValue(forKey: TrainingDiaryProperty.weights.rawValue).remove(weight)
                        CoreDataStackSingleton.shared.delete(entity: weight)
                    }else{
                        weight.fromDate = day.date
                    }
                }
                if let physio = objDict[ENTITY.Physiological.rawValue] as? Physiological{
                    if physio.restingHR == 0.0{
                        td.mutableSetValue(forKey: TrainingDiaryProperty.physiologicals.rawValue).remove(physio)
                        CoreDataStackSingleton.shared.delete(entity: physio)
                    }else{
                        physio.fromDate = day.date
                    }
                }
                //need to put in activity type and equipment objects
                for w in day.workouts?.allObjects as! [Workout]{
                    if let ats = w.activityTypeString{
                        if let activityType = td.addActivityType(forActivity: w.activityString!, andType: ats){
                            w.activityType = activityType
                        }
                    }
                    if let e = w.equipmentName{
                        if let equipment = td.addEquipment(forActivity: w.activityString!, andName: e){
                            w.equipment = equipment
                        }
                    }
                }
            }
            index += 1
        }
        
        insertYesterdayAndTomorrow(forDays: td.descendingOrderedDays())

        var i: Int = 0
        debug: for p in td.weights!.allObjects as! [Weight]{
            print(p)
            i += 1
            if i > 5 { break }
        }
        
        print("Added:")
        for e in CoreDataStackSingleton.shared.getEntityCounts(forDiary: td){
            print("\(e.entity) = \(e.count)")
        }
    }
    
    private func removeZeroDurationWorkouts(fromDay d: Day){
        var zeroWorkouts: [Workout] = []
        if let workouts = d.workouts?.allObjects as? [Workout]{
            for w in workouts{
                if w.seconds == 0.0{
                    zeroWorkouts.append(w)
                }
            }
        }
        let workoutMS = d.mutableSetValue(forKey: DayProperty.workouts.rawValue)
        for w in zeroWorkouts{
            workoutMS.remove(w)
            CoreDataStackSingleton.shared.delete(entity: w)
        }
        
    }
    
    private func parseColValue(col: String, colDetails: ColumnDetails, managedOject: NSManagedObject, trainingDiary td: TrainingDiary){
        var value: Any?
        switch colDetails.entity{
        case .Day:
            if let p = DayProperty(rawValue: colDetails.property){
                if DayProperty.stringProperties.contains(p){
                    value = col
                }else if DayProperty.doubleProperties.contains(p){
                    if col == "" {
                        value = 0.0 as Any
                    }else{
                        value = Double(col) as Any
                    }
                }
            }
        case .Workout:
            if let p = WorkoutProperty(rawValue: colDetails.property){
                if WorkoutProperty.StringProperties.contains(p){
                    value = col
                }else if WorkoutProperty.DoubleProperties.contains(p){
                    if col == ""{
                        value = 0.0 as Any
                    }else{
                        value = Double(col)  as Any
                    }
                }else if WorkoutProperty.BooleanProperties.contains(p){
                    if let i = Double(col){
                        let result: Bool = Int(i) == 1
                        value = result
                    }
                    value = false
                } 
                
            }
        case .Weight, .Physiological:
            if col == ""{
                value = 0.0 as Any
            }else{
                value = Double(col)  as Any
            }
        default:
            print("Not parsing CSV for \(col) and \(colDetails)")
            
            
        }
        if let v = value{
            managedOject.setValue(v, forKey: colDetails.property)
        }

    }
    
    private func createManagedObject(forColumn col: ColumnDetails, trainingDiary td: TrainingDiary, andDay day: Day) -> NSManagedObject{
        switch col.entity{
        case .Day:
            print("Shouldn't have to create Day here. Should already have happened. CSVImporter.swift")
            return day
        case .Weight:
            let w = CoreDataStackSingleton.shared.newWeight()
            td.mutableSetValue(forKey: TrainingDiaryProperty.weights.rawValue).add(w)
            return w
        case .Physiological:
            let p = CoreDataStackSingleton.shared.newPhysiological()
            td.mutableSetValue(forKey: TrainingDiaryProperty.physiologicals.rawValue).add(p)
            return p
        case .Workout:
            let w = CoreDataStackSingleton.shared.newWorkout()
            day.mutableSetValue(forKey: DayProperty.workouts.rawValue).add(w)
            if let activityString = col.activity{
                w.activity = td.addActivity(forString: activityString)
                w.activityString = w.activity!.name
                w.tssMethod = "~Imported~"
            }
            return w
        default:
            print("CVSImporter.swift does not understand ENTITY \(col.entity) and is just ignoring it")
            return day
        }
        
    }
    
    private func dictStr(_ col: ColumnDetails) -> String{
        return col.entity.rawValue + (col.activity ?? "")
    }
    
    
    private func insertYesterdayAndTomorrow(forDays days: [Day]){
        let sortedDays = days.sorted(by: {$0.date! < $1.date!})
        var previousDay: Day?
        for s in sortedDays{
            if let pd = previousDay{
                if s.isYesterday(day: pd){
                    s.yesterday = pd
                }
                if pd.isTomorrow(day: s){
                    pd.tomorrow = s
                }
            }
            previousDay = s
        }
    }
    
    private func splitUpCSV(_ data: String) -> [[String]] {
        var result: [[String]] = []
        var rows = data.components(separatedBy: "\n")
        if rows.count == 1{
            //bug in CSV from excel
            rows = data.components(separatedBy: "\r")
        }
        for row in rows {
            let columns = row.components(separatedBy: ",")
            result.append(columns)
        }
        return result
    }
    
    private func setUpIndexes(_ columnHeaders: [String]){
        var index: Int = 0
        for item in columnHeaders{
            let trimmedItem = item.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: CharacterSet.init(charactersIn: "\r"))

            var split = trimmedItem.split(separator: ":")
            if split.count == 1{
                dictionary[index] = ColumnDetails(entity: ENTITY.Day, activity: nil, property: String(split[0]))
            }else if split.count == 2{
                if let entity = ENTITY(rawValue: String(split[0])){
                    dictionary[index] = ColumnDetails(entity: entity, activity: nil, property: String(split[1]))
                }
            }else if split.count == 3{
                dictionary[index] = ColumnDetails(entity: ENTITY.Workout, activity: String(split[1]), property: String(split[2]).trimmingCharacters(in: .init(charactersIn: "\r")))

            }
            
            index += 1
        }
        
    }
}
