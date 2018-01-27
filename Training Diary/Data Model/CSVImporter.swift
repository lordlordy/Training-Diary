//
//  CSVImporter.swift
//  Training Diary
//
//  Created by Steven Lord on 30/11/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Cocoa

enum CSVImportString: String{
    case date, fatigue, motivation, sleep, sleepQuality, type, comments
    case kg, fatPercent
    case restingHR, restingRMSSD, restingSDNN, standingHR, standingRMSSD, standingSDNN
    case swimSeconds, swimComments, swimIsRace, swimKJ, swimKM, swimRPE, swimTSS, swimTSSMethod, swimType, swimWatts
    case bikeSeconds, bikeAscentMetres, bikeBrick, bikeCadence, bikeComments, bikeHR, bikeIsRace, bikeKJ, bikeKM, bikeRPE, bikeTSS, bikeTSSMethod, bikeType, bikeWatts
    case runSeconds, runAscentMetres, runBrick, runCadence, runComments, runHR, runIsRace, runKJ, runKM, runRPE, runTSS, runTSSMethod, runType, runWatts
    case gymSeconds, gymComments, gymKJ, gymReps, gymRPE, gymTSS, gymTSSMethod, gymType
    case walkSeconds, walkAscentMetres, walkComments, walkHR, walkKJ, walkKM, walkRPE, walkTSS, walkTSSMethod, walkType
    case otherSeconds, otherComments, otherHR, otherKJ, otherRPE, otherTSS, otherTSSMethod, otherType
    
    
    
}

class CSVImporter{
    
    private var dayIndexes: [Int] = []
    private var weightIndexes: [Int] = []
    private var physioIndexes: [Int] = []
    private var swimIndexes: [Int] = []
    private var bikeIndexes: [Int] = []
    private var runIndexes: [Int] = []
    private var otherIndexes: [Int] = []
    private var dateIndex: Int = 0
    private var columnHeaders: [String] = []
    private var columnDictionary: [String: Int] = [:]
    
    private var dateFormatter: DateFormatter
    private let persistentContainer = CoreDataStackSingleton.shared.trainingDiaryPC



    init() {
        dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone.init(secondsFromGMT: 0)
    }
    
    public func importDiary(fromURL url: URL){
        print("Loading JSON from URL = \(url) ...")
        do{
            let string = try String(contentsOf: url)
            parseCSV(data: string)
        }catch{
            print("error initialising Training Diary for URL: " + url.absoluteString)
            
        }
    }
    
/*    public func merge(fromURL url: URL, intoDiary td: TrainingDiary){
        
        let json: [String:Any]? = importCSV(fromURL: url)
        
        if(json != nil){
//            addDaysAndWorkouts(fromJSON: json!, toTrainingDiary: td)
        }
    }
 */
    
    
    //MARK: - possibly private

    
    private func parseCSV(data: String){

        let rowsAndColumns = splitUpCSV(data)
        if rowsAndColumns.count == 0 { return }

        columnHeaders = rowsAndColumns[0]
        setUpIndexes()
    //    printCSV(data: rowsAndColumns)
        createManagedObjectModelFrom(csv: rowsAndColumns)
        

        
    }
    
/*    private func printCSV(data: [[String]]){
        for row in data{
            if row[0].count > 0{
                var dayString = ""
                var weightString = ""
                var physioString = ""
                var swimString = ""
                var bikeString = ""
                var runString = ""
                var otherString = ""
                
                for i in dayIndexes     { dayString += row[i] + " : "}
                for i in weightIndexes  { weightString += row[i] + " : "}
                for i in physioIndexes  { physioString += row[i] + " : "}
                for i in swimIndexes    { swimString += row[i] + " : "}
                for i in bikeIndexes    { bikeString += row[i] + " : "}
                for i in runIndexes     { runString += row[i] + " : "}
                for i in otherIndexes   { otherString += row[i] + " : "}
                
                print(dayString)
                print("::Weight: \(weightString)")
                print("::Physio: \(physioString)")
                print("::Swim: \(swimString)")
                print("::Bike: \(bikeString)")
                print("::Run: \(runString)")
                print("::Other: \(otherString)")
            }
            
            
        }
    }
 */
    
    private func createManagedObjectModelFrom(csv: [[String]]){
        //create the base Object - TrainingDiary
        let trainingDiary: NSManagedObject = NSEntityDescription.insertNewObject(forEntityName: "TrainingDiary", into: CoreDataStackSingleton.shared.trainingDiaryPC.viewContext)
        
        trainingDiary.setValue(Date().dateOnlyString(), forKey: "name")
        
        var index = 0
        for row in csv{
            //first row is labels
            if index > 0{
                addWeight(fromRow: row, toTrainingDiary: trainingDiary)
                addPhysio(fromRow: row, toTrainingDiary: trainingDiary)
                addDayAndWorkouts(forRow: row, toTrainingDiary: trainingDiary)
            }
            index += 1
        }
        

        print("Added:")
        CoreDataStackSingleton.shared.printEntityCounts(forDiary: trainingDiary as! TrainingDiary)
        
    }
    
    private func addDayAndWorkouts(forRow row: [String], toTrainingDiary trainingDiary: NSManagedObject){
        
        let daysMOSet = trainingDiary.mutableSetValue(forKey: TrainingDiaryProperty.days.rawValue)
        
        //    case date, fatigue, motivation, sleep, sleepQuality, type, comments
        
        if let index = columnDictionary[CSVImportString.date.rawValue]{
            if let date = dateFormatter.date(from: row[index]){
                //have parsed the date so can add a day to the diary
                let day = NSManagedObject.init(entity: NSEntityDescription.entity(forEntityName: ENTITY.Day.rawValue, in: persistentContainer.viewContext)!, insertInto: persistentContainer.viewContext)
                daysMOSet.add(day)
                
                day.setValue(date, forKey: DayProperty.date.rawValue)

                //add other day items if present
                if let i = columnDictionary[CSVImportString.fatigue.rawValue]{ day.setValue(Int(row[i]), forKey: DayProperty.fatigue.rawValue) }
                if let i = columnDictionary[CSVImportString.motivation.rawValue]{ day.setValue(Int(row[i]), forKey: DayProperty.motivation.rawValue) }
                if let i = columnDictionary[CSVImportString.sleep.rawValue]{ day.setValue(Double(row[i]), forKey: DayProperty.sleep.rawValue) }
                if let i = columnDictionary[CSVImportString.sleepQuality.rawValue]{ day.setValue(row[i], forKey: DayProperty.sleepQuality.rawValue) }
                if let i = columnDictionary[CSVImportString.type.rawValue]{ day.setValue(row[i], forKey: DayProperty.type.rawValue) }
                if let i = columnDictionary[CSVImportString.comments.rawValue]{ day.setValue(row[i], forKey: DayProperty.comments.rawValue) }

                let workoutsMOSet = day.mutableSetValue(forKey: DayProperty.workouts.rawValue)

                if let index = columnDictionary[CSVImportString.swimSeconds.rawValue]{
                    if Double(row[index]) != nil{ addSwimWorkout(fromRow: row, workouts: workoutsMOSet) }
                }
                if let index = columnDictionary[CSVImportString.bikeSeconds.rawValue]{
                    if Double(row[index]) != nil{ addBikeWorkout(fromRow: row, workouts: workoutsMOSet) }
                }
                if let index = columnDictionary[CSVImportString.runSeconds.rawValue]{
                    if Double(row[index]) != nil{ addRunWorkout(fromRow: row, workouts: workoutsMOSet) }
                }
                if let index = columnDictionary[CSVImportString.gymSeconds.rawValue]{
                    if Double(row[index]) != nil{ addGymWorkout(fromRow: row, workouts: workoutsMOSet) }
                }
                if let index = columnDictionary[CSVImportString.walkSeconds.rawValue]{
                    if Double(row[index]) != nil{ addWalkWorkout(fromRow: row, workouts: workoutsMOSet) }
                }
                if let index = columnDictionary[CSVImportString.otherSeconds.rawValue]{
                    if Double(row[index]) != nil{ addOtherWorkout(fromRow: row, workouts: workoutsMOSet) }
                }

            }else{
                print("unable to import day as couldn't parse: \(row[index]) in to a date")
            }
        }else{
            print("couldn't import day as could find column index for \(CSVImportString.date.rawValue)")
        }
        
        let addedDays: [Day] = daysMOSet.allObjects as! [Day]
        insertYesterdayAndTomorrow(forDays: addedDays)
 
    }
    
    private func addSwimWorkout(fromRow row: [String], workouts : NSMutableSet){
        
        let workout = NSManagedObject.init(entity: NSEntityDescription.entity(forEntityName: ENTITY.Workout.rawValue, in: persistentContainer.viewContext)!, insertInto: persistentContainer.viewContext)
        workouts.add(workout)
        
        //    case swimSeconds, swimComments, swimIsRace, swimKJ, swimKM, swimRPE, swimTSS, swimTSSMethod, swimType, swimWatts

        workout.setValue(ActivityEnum.Swim.rawValue, forKey: WorkoutProperty.activity.rawValue)
        if let i = columnDictionary[CSVImportString.swimSeconds.rawValue]{ workout.setValue(Double(row[i]), forKey: WorkoutProperty.seconds.rawValue) }
        if let i = columnDictionary[CSVImportString.swimComments.rawValue]{ workout.setValue(row[i], forKey: WorkoutProperty.comments.rawValue) }
        if let i = columnDictionary[CSVImportString.swimIsRace.rawValue]{
            if row[i] == "1" || row[i].uppercased() == "TRUE"{
                workout.setValue(true, forKey: WorkoutProperty.isRace.rawValue)
            }else{
                workout.setValue(false, forKey: WorkoutProperty.isRace.rawValue)
            }
        }
        if let i = columnDictionary[CSVImportString.swimKJ.rawValue]{ workout.setValue(Double(row[i]), forKey: WorkoutProperty.kj.rawValue) }
        if let i = columnDictionary[CSVImportString.swimKM.rawValue]{ workout.setValue(Double(row[i]), forKey: WorkoutProperty.km.rawValue) }
        if let i = columnDictionary[CSVImportString.swimRPE.rawValue]{ workout.setValue(Double(row[i]), forKey: WorkoutProperty.rpe.rawValue) }
        if let i = columnDictionary[CSVImportString.swimTSS.rawValue]{ workout.setValue(Double(row[i]), forKey: WorkoutProperty.tss.rawValue) }
        if let i = columnDictionary[CSVImportString.swimTSSMethod.rawValue]{ workout.setValue(row[i], forKey: WorkoutProperty.tssMethod.rawValue) }
        if let i = columnDictionary[CSVImportString.swimType.rawValue]{
            if row[i] == ""{
                workout.setValue(ActivityTypeEnum.Squad.rawValue, forKey: WorkoutProperty.activityType.rawValue)
            }else{
                workout.setValue(row[i], forKey: WorkoutProperty.activityType.rawValue)
            }
        }
        if let i = columnDictionary[CSVImportString.swimWatts.rawValue]{ workout.setValue(Double(row[i]), forKey: WorkoutProperty.watts.rawValue) }
        
    }

    private func addBikeWorkout(fromRow row: [String], workouts : NSMutableSet){
        let workout = NSManagedObject.init(entity: NSEntityDescription.entity(forEntityName: ENTITY.Workout.rawValue, in: persistentContainer.viewContext)!, insertInto: persistentContainer.viewContext)
        workouts.add(workout)
        
       // case bikeSeconds, bikeAscentMetres, bikeBrick, bikeCadence, BikeComments, bikeHR, bikeIsRace, bikeKJ, bikeKM, bikeRPE, bikeTSS, bikeTSSMethod, bikeType, bikeWatts
        workout.setValue(ActivityEnum.Bike.rawValue, forKey: WorkoutProperty.activity.rawValue)
        if let i = columnDictionary[CSVImportString.bikeSeconds.rawValue]{      workout.setValue(Double(row[i]), forKey: WorkoutProperty.seconds.rawValue) }
        if let i = columnDictionary[CSVImportString.bikeAscentMetres.rawValue]{ workout.setValue(Double(row[i]), forKey: WorkoutProperty.ascentMetres.rawValue) }
        if let i = columnDictionary[CSVImportString.bikeBrick.rawValue]{
            if row[i] == "1" || row[i].uppercased() == "TRUE"{
                workout.setValue(true, forKey: WorkoutProperty.brick.rawValue)
            }else{
                workout.setValue(false, forKey: WorkoutProperty.brick.rawValue)
            }
        }
        if let i = columnDictionary[CSVImportString.bikeCadence.rawValue]{      workout.setValue(Double(row[i]), forKey: WorkoutProperty.cadence.rawValue) }
        if let i = columnDictionary[CSVImportString.bikeComments.rawValue]{     workout.setValue(row[i], forKey: WorkoutProperty.comments.rawValue) }
        if let i = columnDictionary[CSVImportString.bikeHR.rawValue]{           workout.setValue(Double(row[i]), forKey: WorkoutProperty.hr.rawValue) }
        if let i = columnDictionary[CSVImportString.bikeIsRace.rawValue]{
            if row[i] == "1" || row[i].uppercased() == "TRUE"{
                workout.setValue(true, forKey: WorkoutProperty.isRace.rawValue)
            }else{
                workout.setValue(false, forKey: WorkoutProperty.isRace.rawValue)
            }
        }
        if let i = columnDictionary[CSVImportString.bikeKJ.rawValue]{           workout.setValue(Double(row[i]), forKey: WorkoutProperty.kj.rawValue) }
        if let i = columnDictionary[CSVImportString.bikeKM.rawValue]{           workout.setValue(Double(row[i]), forKey: WorkoutProperty.km.rawValue) }
        if let i = columnDictionary[CSVImportString.bikeRPE.rawValue]{          workout.setValue(Double(row[i]), forKey: WorkoutProperty.rpe.rawValue) }
        if let i = columnDictionary[CSVImportString.bikeTSS.rawValue]{          workout.setValue(Double(row[i]), forKey: WorkoutProperty.tss.rawValue) }
        if let i = columnDictionary[CSVImportString.bikeTSSMethod.rawValue]{    workout.setValue(row[i], forKey: WorkoutProperty.tssMethod.rawValue) }
        if let i = columnDictionary[CSVImportString.bikeType.rawValue]{
            if row[i] == ""{
               workout.setValue(ActivityTypeEnum.Road.rawValue, forKey: WorkoutProperty.activityType.rawValue)
            }else{
                workout.setValue(row[i], forKey: WorkoutProperty.activityType.rawValue)
            }
        }
        if let i = columnDictionary[CSVImportString.bikeWatts.rawValue]{        workout.setValue(Double(row[i]), forKey: WorkoutProperty.watts.rawValue) }


    }
    private func addRunWorkout(fromRow row: [String], workouts : NSMutableSet){
        let workout = NSManagedObject.init(entity: NSEntityDescription.entity(forEntityName: ENTITY.Workout.rawValue, in: persistentContainer.viewContext)!, insertInto: persistentContainer.viewContext)
        workouts.add(workout)
        
        //case runSeconds, runAscentMetres, runBrick, runCadence, runComments, runHR, runIsRace, runKJ, runKM, runRPE, runTSS, runTSSMethod, runType, runWatts
        workout.setValue(ActivityEnum.Run.rawValue, forKey: WorkoutProperty.activity.rawValue)
        if let i = columnDictionary[CSVImportString.runSeconds.rawValue]{      workout.setValue(Double(row[i]), forKey: WorkoutProperty.seconds.rawValue) }
        if let i = columnDictionary[CSVImportString.runAscentMetres.rawValue]{ workout.setValue(Double(row[i]), forKey: WorkoutProperty.ascentMetres.rawValue) }
        if let i = columnDictionary[CSVImportString.runBrick.rawValue]{
            if row[i] == "1" || row[i].uppercased() == "TRUE"{
                workout.setValue(true, forKey: WorkoutProperty.brick.rawValue)
            }else{
                workout.setValue(false, forKey: WorkoutProperty.brick.rawValue)
            }
        }
        if let i = columnDictionary[CSVImportString.runCadence.rawValue]{      workout.setValue(Double(row[i]), forKey: WorkoutProperty.cadence.rawValue) }
        if let i = columnDictionary[CSVImportString.runComments.rawValue]{     workout.setValue(row[i], forKey: WorkoutProperty.comments.rawValue) }
        if let i = columnDictionary[CSVImportString.runHR.rawValue]{           workout.setValue(Double(row[i]), forKey: WorkoutProperty.hr.rawValue) }
        if let i = columnDictionary[CSVImportString.runIsRace.rawValue]{
            if row[i] == "1" || row[i].uppercased() == "TRUE"{
                workout.setValue(true, forKey: WorkoutProperty.isRace.rawValue)
            }else{
                workout.setValue(false, forKey: WorkoutProperty.isRace.rawValue)
            }
        }
        if let i = columnDictionary[CSVImportString.runKJ.rawValue]{           workout.setValue(Double(row[i]), forKey: WorkoutProperty.kj.rawValue) }
        if let i = columnDictionary[CSVImportString.runKM.rawValue]{           workout.setValue(Double(row[i]), forKey: WorkoutProperty.km.rawValue) }
        if let i = columnDictionary[CSVImportString.runRPE.rawValue]{          workout.setValue(Double(row[i]), forKey: WorkoutProperty.rpe.rawValue) }
        if let i = columnDictionary[CSVImportString.runTSS.rawValue]{          workout.setValue(Double(row[i]), forKey: WorkoutProperty.tss.rawValue) }
        if let i = columnDictionary[CSVImportString.runTSSMethod.rawValue]{    workout.setValue(row[i], forKey: WorkoutProperty.tssMethod.rawValue) }
        if let i = columnDictionary[CSVImportString.runType.rawValue]{
            if row[i] == ""{
                workout.setValue(ActivityTypeEnum.Road.rawValue, forKey: WorkoutProperty.activityType.rawValue)
            }else{
                workout.setValue(row[i], forKey: WorkoutProperty.activityType.rawValue)
            }
        }
        if let i = columnDictionary[CSVImportString.runWatts.rawValue]{        workout.setValue(Double(row[i]), forKey: WorkoutProperty.watts.rawValue) }

    }
        
    private func addGymWorkout(fromRow row: [String], workouts : NSMutableSet){
        let workout = NSManagedObject.init(entity: NSEntityDescription.entity(forEntityName: ENTITY.Workout.rawValue, in: persistentContainer.viewContext)!, insertInto: persistentContainer.viewContext)
        workouts.add(workout)
        
        //case gymSeconds, gymComments, gymKJ, gymReps, gymRPE, gymTSS, gymTSSMethod, gymType
        workout.setValue(ActivityEnum.Gym.rawValue, forKey: WorkoutProperty.activity.rawValue)
        if let i = columnDictionary[CSVImportString.gymSeconds.rawValue]{ workout.setValue(Double(row[i]), forKey: WorkoutProperty.seconds.rawValue) }
        if let i = columnDictionary[CSVImportString.gymComments.rawValue]{ workout.setValue(row[i], forKey: WorkoutProperty.comments.rawValue) }
        if let i = columnDictionary[CSVImportString.gymKJ.rawValue]{ workout.setValue(Double(row[i]), forKey: WorkoutProperty.kj.rawValue) }
        if let i = columnDictionary[CSVImportString.gymReps.rawValue]{ workout.setValue(Double(row[i]), forKey: WorkoutProperty.reps.rawValue) }
        if let i = columnDictionary[CSVImportString.gymRPE.rawValue]{ workout.setValue(Double(row[i]), forKey: WorkoutProperty.rpe.rawValue) }
        if let i = columnDictionary[CSVImportString.gymTSS.rawValue]{ workout.setValue(Double(row[i]), forKey: WorkoutProperty.tss.rawValue) }
        if let i = columnDictionary[CSVImportString.gymTSSMethod.rawValue]{ workout.setValue(row[i], forKey: WorkoutProperty.tssMethod.rawValue) }
        if let i = columnDictionary[CSVImportString.gymType.rawValue]{
            if row[i] == ""{
                workout.setValue(ActivityTypeEnum.General.rawValue, forKey: WorkoutProperty.activityType.rawValue)
            }else{
                workout.setValue(row[i], forKey: WorkoutProperty.activityType.rawValue)
            }
        }
        

    }
    private func addWalkWorkout(fromRow row: [String], workouts : NSMutableSet){
        let workout = NSManagedObject.init(entity: NSEntityDescription.entity(forEntityName: ENTITY.Workout.rawValue, in: persistentContainer.viewContext)!, insertInto: persistentContainer.viewContext)
        workouts.add(workout)
        
        //case walkSeconds, walkAscentMetres, walkComments, walkHR, walkKJ, walkKM, walkRPE, walkTSS, walkTSSMethod, walkType
        workout.setValue(ActivityEnum.Walk.rawValue, forKey: WorkoutProperty.activity.rawValue)
        if let i = columnDictionary[CSVImportString.walkSeconds.rawValue]{      workout.setValue(Double(row[i]), forKey: WorkoutProperty.seconds.rawValue) }
        if let i = columnDictionary[CSVImportString.walkAscentMetres.rawValue]{ workout.setValue(Double(row[i]), forKey: WorkoutProperty.ascentMetres.rawValue) }
        if let i = columnDictionary[CSVImportString.walkComments.rawValue]{     workout.setValue(row[i], forKey: WorkoutProperty.comments.rawValue) }
        if let i = columnDictionary[CSVImportString.walkHR.rawValue]{           workout.setValue(Double(row[i]), forKey: WorkoutProperty.hr.rawValue) }
        if let i = columnDictionary[CSVImportString.walkKJ.rawValue]{           workout.setValue(Double(row[i]), forKey: WorkoutProperty.kj.rawValue) }
        if let i = columnDictionary[CSVImportString.walkKM.rawValue]{           workout.setValue(Double(row[i]), forKey: WorkoutProperty.km.rawValue) }
        if let i = columnDictionary[CSVImportString.walkRPE.rawValue]{          workout.setValue(Double(row[i]), forKey: WorkoutProperty.rpe.rawValue) }
        if let i = columnDictionary[CSVImportString.walkTSS.rawValue]{          workout.setValue(Double(row[i]), forKey: WorkoutProperty.tss.rawValue) }
        if let i = columnDictionary[CSVImportString.walkTSSMethod.rawValue]{    workout.setValue(row[i], forKey: WorkoutProperty.tssMethod.rawValue) }
        if let i = columnDictionary[CSVImportString.walkType.rawValue]{
            if row[i] == ""{
                workout.setValue(ActivityTypeEnum.General.rawValue, forKey: WorkoutProperty.activityType.rawValue)
            }else{
                workout.setValue(row[i], forKey: WorkoutProperty.activityType.rawValue)
            }
        }


    }
    private func addOtherWorkout(fromRow row: [String], workouts : NSMutableSet){
        let workout = NSManagedObject.init(entity: NSEntityDescription.entity(forEntityName: ENTITY.Workout.rawValue, in: persistentContainer.viewContext)!, insertInto: persistentContainer.viewContext)
        workouts.add(workout)
        
        //case otherSeconds, otherComments, otherHR, otherKJ, otherRPE, otherTSS, otherTSSMethod, otherType
        workout.setValue(ActivityEnum.Swim.rawValue, forKey: WorkoutProperty.activity.rawValue)
        if let i = columnDictionary[CSVImportString.otherSeconds.rawValue]{ workout.setValue(Double(row[i]), forKey: WorkoutProperty.seconds.rawValue) }
        if let i = columnDictionary[CSVImportString.otherComments.rawValue]{ workout.setValue(row[i], forKey: WorkoutProperty.comments.rawValue) }
        if let i = columnDictionary[CSVImportString.otherHR.rawValue]{ workout.setValue(Double(row[i]), forKey: WorkoutProperty.hr.rawValue) }
        if let i = columnDictionary[CSVImportString.otherKJ.rawValue]{ workout.setValue(Double(row[i]), forKey: WorkoutProperty.kj.rawValue) }
        if let i = columnDictionary[CSVImportString.otherRPE.rawValue]{ workout.setValue(Double(row[i]), forKey: WorkoutProperty.rpe.rawValue) }
        if let i = columnDictionary[CSVImportString.otherTSS.rawValue]{ workout.setValue(Double(row[i]), forKey: WorkoutProperty.tss.rawValue) }
        if let i = columnDictionary[CSVImportString.otherTSSMethod.rawValue]{ workout.setValue(row[i], forKey: WorkoutProperty.tssMethod.rawValue) }
        if let i = columnDictionary[CSVImportString.otherType.rawValue]{
            if row[i] == ""{
                workout.setValue(ActivityTypeEnum.General.rawValue, forKey: WorkoutProperty.activityType.rawValue)
            }else{
                workout.setValue(row[i], forKey: WorkoutProperty.activityType.rawValue)
            }
        }
        

    }

    private func addWeight(fromRow row: [String], toTrainingDiary trainingDiary: NSManagedObject){
        
        if let dateIndex = columnDictionary[CSVImportString.date.rawValue]{
            if let date = dateFormatter.date(from: row[dateIndex]){
                //we've managed to parse the date so can proceed
                // lets see if there is a weight or a fat% in this row
                var kg: Double?
                
                if let kgIndex = columnDictionary[CSVImportString.kg.rawValue]{
                    kg = Double(row[kgIndex])
                }

                //only create and add weight if we have KG
                if let weightKG = kg{
                    let weight = NSManagedObject.init(entity: NSEntityDescription.entity(forEntityName: ENTITY.Weight.rawValue, in: persistentContainer.viewContext)!, insertInto: persistentContainer.viewContext)
                    trainingDiary.mutableSetValue(forKey: TrainingDiaryProperty.weights.rawValue).add(weight)
                    // for now set the date just for the day - should go through weights and put in correct toDate
                    weight.setValue(date.startOfDay() , forKey: WeightProperty.fromDate.rawValue)
                    weight.setValue(date.endOfDay(), forKey: WeightProperty.toDate.rawValue)
                    weight.setValue(weightKG, forKey: WeightProperty.kg.rawValue)
                    if let fatIndex = columnDictionary[CSVImportString.fatPercent.rawValue]{
                        weight.setValue(Double(row[fatIndex]), forKey: WeightProperty.fatPercent.rawValue)
                    }
                }
            }else{
                print("failed to import weight for from date : \(row[dateIndex])")
            }
        }else{
            print("Failed to import weight as couldn't establish column index for column 'date'")
        }
        
    }
    
    private func addPhysio(fromRow row: [String], toTrainingDiary trainingDiary: NSManagedObject){
        
        if let dateIndex = columnDictionary[CSVImportString.date.rawValue]{
            if let date = dateFormatter.date(from: row[dateIndex]){
                //we've managed to parse the date so can proceed
                // lets see if there is a weight or a fat% in this row
                var hr: Double?
                
                if let hrIndex = columnDictionary[CSVImportString.restingHR.rawValue]{
                    hr = Double(row[hrIndex])
                }
                
                //only create and add weight if we have KG
                if let restingHR = hr{
                    let physio = NSManagedObject.init(entity: NSEntityDescription.entity(forEntityName: ENTITY.Physiological.rawValue, in: persistentContainer.viewContext)!, insertInto: persistentContainer.viewContext)
                    trainingDiary.mutableSetValue(forKey: TrainingDiaryProperty.physiologicals.rawValue).add(physio)
                    // for now set the date just for the day - should go through weights and put in correct toDate
                    physio.setValue(date.startOfDay() , forKey: PhysiologicalProperty.fromDate.rawValue)
                    physio.setValue(date.endOfDay(), forKey: PhysiologicalProperty.toDate.rawValue)
                    physio.setValue(restingHR, forKey: PhysiologicalProperty.restingHR.rawValue)
                    if let sdnnIndex = columnDictionary[CSVImportString.restingSDNN.rawValue]{
                        physio.setValue(Double(row[sdnnIndex]), forKey: PhysiologicalProperty.restingSDNN.rawValue)
                    }
                    if let rmssdIndex = columnDictionary[CSVImportString.restingRMSSD.rawValue]{
                        physio.setValue(Double(row[rmssdIndex]), forKey: PhysiologicalProperty.restingRMSSD.rawValue)
                    }
                    if let standingHR = columnDictionary[CSVImportString.standingHR.rawValue]{
                        physio.setValue(Double(row[standingHR]), forKey: PhysiologicalProperty.standingHR.rawValue)
                    }
                    if let standingSDNN = columnDictionary[CSVImportString.standingSDNN.rawValue]{
                        physio.setValue(Double(row[standingSDNN]), forKey: PhysiologicalProperty.standingSDNN.rawValue)
                    }
                    if let standingRMSSD = columnDictionary[CSVImportString.standingRMSSD.rawValue]{
                        physio.setValue(Double(row[standingRMSSD]), forKey: PhysiologicalProperty.standingRMSSD.rawValue)
                    }
                }
            }else{
                print("failed to import physio for from date : \(row[dateIndex])")
            }
        }else{
            print("Failed to import physio as couldn't establish column index for column 'date'")
        }
        
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
    
    private func setUpIndexes(){
        var index: Int = 0
        for item in columnHeaders{
   //         if item.contains("swim")        { swimIndexes.append(index)     }
     //       else if item.contains("bike")   { bikeIndexes.append(index)     }
       //     else if item.contains("run")    { runIndexes.append(index)      }
         //   else if item.contains("other")  { otherIndexes.append(index)    }
           // else if item.contains("resting"){ physioIndexes.append(index)   }
        //    else if item.contains("kg")     { weightIndexes.append(index)   }
          //  else if item.contains("fat%")   { weightIndexes.append(index)   }
         //   else                            { dayIndexes.append(index)      }
      //      if item == "date" { dateIndex = index }
            let trimmedItem = item.trimmingCharacters(in: .whitespaces)
            columnDictionary[trimmedItem] = index
            index += 1
        }
        
    }
}
