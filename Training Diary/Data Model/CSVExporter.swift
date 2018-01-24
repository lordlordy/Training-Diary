//
//  CSVExporter.swift
//  Training Diary
//
//  Created by Steven Lord on 18/01/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Foundation

class CSVExporter{

    func convertToCVS(trainingDiary td: TrainingDiary) -> (dayCSV: String, workoutCSV: String){
        return convertToCVS(forDays: td.days!.allObjects as! [Day])
    }
    
    func convertToCVS(forDays days: [Day]) -> (dayCSV: String, workoutCSV: String){
        
        var workoutString: String = "date"
        var dayString: String = ""
        var workoutCount: Int = 0
        var dayCount: Int = 0
    
        workoutString += headerRowForWorkouts()
        workoutString += "\n"
    
        dayString += headerRowForDays()
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

    private func csv(forWorkout w: Workout) -> String{
        var result: String = ""
        
        for property in WorkoutProperty.AllProperties{
            result += ","
            if let value = w.value(forKey: property.rawValue){
                if let v = value as? String{
                    result += fixString(v)
                }else if let d = value as? Double{
                    result += String(format: "%.8f",d)
                }else{
                    result += String(describing: value)
                }
            }
        }

        return result
    }

    private func csv(forDay d: Day) -> String{
        var result: String = ""
        var isFirst: Bool = true
        
        for property in DayProperty.ExportProperties{
            if isFirst{
                isFirst = false
            }else{
                result += ","
            }
            if let value = d.value(forKey: property.rawValue){
                if let v = value as? String{
                    result += fixString(v)
                }else if let d = value as? Double{
                    result += String(format: "%.8f",d)
                }else{
                    result += String(describing: value)
                }
            }
        }
        for property in DayCalculatedProperty.ExportProperties{
            result += ","
            if let value = d.value(forKey: property.rawValue){
                if let v = value as? String{
                    result += fixString(v)
                }else if let d = value as? Double{
                    result += String(format: "%.8f",d)
                }else{
                    result += String(describing: value)
                }
            }
        }
        
        return result
    }
    
    private func headerRowForWorkouts() -> String{
        var result: String = ""
        
        for property in WorkoutProperty.AllProperties{
            result += ","
            result += property.rawValue
        }
        
        return result
        
    }
    
    private func headerRowForDays() -> String{
        var result: String = ""
        var isFirst: Bool = true

        for property in DayProperty.ExportProperties{
            if isFirst{
                isFirst = false
            }else{
                result += ","
            }
            result += property.rawValue
        }
        for property in DayCalculatedProperty.ExportProperties{
            result += ","
            result += property.rawValue
        }
        return result
        
    }

    private func fixString(_ forString: String) -> String{
        
        var result = "\""
        result += forString.replacingOccurrences(of: ",", with: ";")
        result += "\""

        return result
    }
    
}
