//
//  CSVExporter.swift
//  Training Diary
//
//  Created by Steven Lord on 18/01/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Foundation

class CSVExporter{
    
    var weightsDictionary: [String:Weight] = [:]
    var physioDictionary: [String:Physiological] = [:]

    func convertToCSV(trainingDiary td: TrainingDiary) -> (dayCSV: String, workoutCSV: String, weightsCSV: String, physiologicalsCSV: String){
        createDictionaries(forTrainingDiary: td)
        let result = convertToCSV(forDays: td.days!.allObjects as! [Day], td)
        let weights = convertToCSV(forWeights: td.weights!.allObjects as! [Weight])
        let physios = convertToCSV(forPhysios: td.physiologicals!.allObjects as! [Physiological])
        return (result.dayCSV, result.workoutCSV, weights, physios)
    }
    
    func convertToCSV(forDays days: [Day], _ td: TrainingDiary) -> (dayCSV: String, workoutCSV: String){
        
        var workoutString: String = "date"
        var dayString: String = ""
        var workoutCount: Int = 0
        var dayCount: Int = 0
    
        workoutString += headerRowForWorkouts()
        workoutString += "\n"
    
        dayString += headerRowForDays(td)
        dayString += "\n"
    
        
        for d in days{
            dayString += csv(forDay: d)
            dayString += "\n"
            dayCount += 1
            if let workoutDate = d.date{
                let dateString = workoutDate.dateOnlyString()
                if let workouts = d.workouts{
                    for w in workouts{
                        workoutCount += 1
                        workoutString += dateString
                        workoutString += csv(forWorkout: w as! Workout)
                        workoutString += "\n"
                    }
                }
            }
        }
                
        print("Workout count: \(workoutCount)")
        print("Day count: \(dayCount)")

        return (dayCSV: dayString, workoutCSV: workoutString)
    }
    
    private func convertToCSV(forWeights weights: [Weight]) -> String{
        
        var weightString: String = ""
        var isFirst: Bool = true
        
        for property in WeightProperty.jsonProperties{
            if isFirst{
                isFirst = false
            }else{
                weightString += ","
            }
            weightString += property.rawValue
        }
        weightString += "\n"
        
        
        for w in weights{
            isFirst = true
            for p in WeightProperty.jsonProperties{
                if isFirst{
                    isFirst = false
                }else{
                    weightString += ","
                }
                if let value = w.value(forKey: p.rawValue){
                    if let v = value as? String{
                        weightString += fixString(v)
                    }else if let d = value as? Double{
                        weightString += String(format: "%.8f",d)
                    }else{
                        weightString += String(describing: value)
                    }
                }
            }
            weightString += "\n"
        }
        
        return weightString
    }
    
    private func convertToCSV(forPhysios physios: [Physiological]) -> String{
        
        var physioString: String = ""
        var isFirst: Bool = true
        
        for property in PhysiologicalProperty.csvProperties{
            if isFirst{
                isFirst = false
            }else{
                physioString += ","
            }
            physioString += property.rawValue
        }
        physioString += "\n"
        
        
        for phys in physios{
            isFirst = true
            for p in PhysiologicalProperty.csvProperties{
                if isFirst{
                    isFirst = false
                }else{
                    physioString += ","
                }
                if let value = phys.value(forKey: p.rawValue){
                    if let v = value as? String{
                        physioString += fixString(v)
                    }else if let d = value as? Double{
                        physioString += String(format: "%.8f",d)
                    }else{
                        physioString += String(describing: value)
                    }
                }
            }
            physioString += "\n"
        }
        
        return physioString
    }

    private func csv(forWorkout w: Workout) -> String{
        var result: String = ""
        
        for property in WorkoutProperty.jsonProperties{
            result += ","
            if let value = w.value(forKey: property.rawValue){
                if let v = value as? String{
                    result += fixString(v)
                }else if let d = value as? Double{
                    result += String(format: "%.8f",d)
                }else if let category = value as? CategoryProtocol{
                    result += category.categoryName()
                }else{
                    result += String(describing: value)
                }
            }
        }

        return result
    }

    private func csv(forDay d: Day) -> String{
        var result: String = ""
        
        for property in DayProperty.csvProperties{
            if let value = d.value(forKey: property.rawValue){
                if let v = value as? String{
                    result += fixString(v)
                }else if let d = value as? Double{
                    result += String(format: "%.8f",d)
                }else{
                    result += String(describing: value)
                }
            }
            result += ","
        }
        
        if let weight = weightsDictionary[d.date!.dateOnlyString()]{
            for p in DayProperty.weightProperties{
                if let value = weight.value(forKey: p.rawValue) as? Double{
                    result += String(format: "%.8f", value)
                }
                result += ","
            }
        }else{
            //just stick in the commas as no values
            for _ in DayProperty.weightProperties{
                result += ","
            }
        }
        
        if let physio = physioDictionary[d.date!.dateOnlyString()]{
            for p in DayProperty.physiologicalProperties{
                if let value = physio.value(forKey: p.rawValue) as? Double{
                    result += String(format: "%.8f", value)
                }
                result += ","
            }
        }else{
            //just commas as no values
            for _ in DayProperty.physiologicalProperties{
                result += ","
            }
        }
        
        for a in d.trainingDiary!.activitiesArray(){
            for u in Unit.csvExportUnits{
                let value: Double = d.valueFor( activity: a, unit: u)
                result += String(format: "%.8f", value)
                result += ","
            }
            if let activityType = d.activityTypeString(forActivity: a.name!){
                result += activityType
            }
            result += ","
            if let equipment = d.equipmentString(forActivity: a.name!){
                result += equipment
            }
            result += ","
        }
        
        return result.trimmingCharacters(in: CharacterSet(charactersIn: ","))
    }
    
    private func headerRowForWorkouts() -> String{
        var result: String = ""
        
        for property in WorkoutProperty.jsonProperties{
            result += ","
            result += property.rawValue
        }
        
        return result
        
    }
    
    private func headerRowForDays(_ td: TrainingDiary) -> String{
        var result: String = ""
        
        for property in DayProperty.csvProperties{
            result += property.rawValue
            result += ","
        }
        
        for property in DayProperty.weightProperties{
            result += ENTITY.Weight.rawValue + ":" + property.rawValue
            result += ","
        }

        for property in DayProperty.physiologicalProperties{
            result += ENTITY.Physiological.rawValue + ":" + property.rawValue
            result += ","
        }
        
        for a in td.activitiesArray(){
            for u in Unit.csvExportUnits{
                result += ENTITY.Activity.rawValue + ":" + a.name! + ":" + u.rawValue
                result += ","
            }
            result += ENTITY.Activity.rawValue + ":" + a.name! + ":" + WorkoutProperty.activityTypeString.rawValue
            result += ","
            result += ENTITY.Activity.rawValue + ":" + a.name! + ":" + WorkoutProperty.equipmentName.rawValue
            result += ","

        }
        
        return result.trimmingCharacters(in: CharacterSet(charactersIn: ","))
        
    }

    private func fixString(_ forString: String) -> String{
        
        var result = "\""
        result += forString.replacingOccurrences(of: ",", with: ";")
        result += "\""

        return result
    }
    
    private func createDictionaries(forTrainingDiary td: TrainingDiary){
        weightsDictionary = [:]
        physioDictionary = [:]
        
        if let weights = td.weights?.allObjects as? [Weight]{
            for w in weights{
                weightsDictionary[w.fromDateString] = w
            }
        }
        
        if let physios = td.physiologicals?.allObjects as? [Physiological]{
            for p in physios{
                physioDictionary[p.fromDateString] = p
            }
        }
        
    }
    
}
