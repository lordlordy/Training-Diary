//
//  JSONExporter.swift
//  Training Diary
//
//  Created by Steven Lord on 10/03/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Foundation

class JSONExporter{
    
    
    func createJSON(forTrainingDiary td: TrainingDiary) -> NSString?{
        
        var trainingDiaryDictionary = td.dictionaryWithValues(forKeys: TrainingDiaryProperty.jsonProperties.map({$0.rawValue}))
        trainingDiaryDictionary["Generated By"] = JSONGenerator.SwiftTrainingDiary.rawValue
        trainingDiaryDictionary["Generated At"] = Date().iso8601Format()
        let dayKeys =  DayProperty.jsonProperties.map({$0.rawValue})
        let workoutKeys = WorkoutProperty.jsonProperties.map({$0.rawValue })
        let physiologicalKeys = PhysiologicalProperty.jsonProperties.map({$0.rawValue})
        let weightKeys = WeightProperty.jsonProperties.map({$0.rawValue})
        let planKeys = PlanProperty.jsonProperties.map({$0.rawValue})
        let basicWeekKeys = BasicWeekDayProperty.jsonProperties.map({$0.rawValue})
        let planDayKeys = PlanDayProperty.jsonProperties.map({$0.rawValue})

        var dayArray: [[String:Any]] = []
        if let days = td.days{
            for d in days{
                if let day = d as? Day{
                    var dayDictionary = day.dictionaryWithValues(forKeys: dayKeys)
                    var workoutArray: [[String:Any]] = []
                    if let workouts = day.workouts{
                        for w in workouts{
                            let workout = w as! Workout
                            let workoutDictionary = workout.dictionaryWithValues(forKeys: workoutKeys)
                            workoutArray.append(workoutDictionary)
                        }
                    }
                    if workoutArray.count > 0{
                        dayDictionary[DayProperty.workouts.rawValue] = workoutArray
                    }
                    dayArray.append(dayDictionary)
                }
            }
        }
        trainingDiaryDictionary[TrainingDiaryProperty.days.rawValue] = dayArray
        
        var physiologicalsArray: [[String:Any]] = []
        if let physiologicals = td.physiologicals{
            for p in physiologicals{
                if let physio = p as? Physiological{
                    physiologicalsArray.append(physio.dictionaryWithValues(forKeys: physiologicalKeys))
                }
            }
            trainingDiaryDictionary[TrainingDiaryProperty.physiologicals.rawValue] = physiologicalsArray
        }
        
        var weightsArray: [[String:Any]] = []
        if let weights = td.weights{
            for w in weights{
                if let weight = w as? Weight{
                    weightsArray.append(weight.dictionaryWithValues(forKeys: weightKeys))
                }
            }
            trainingDiaryDictionary[TrainingDiaryProperty.weights.rawValue] = weightsArray
        }
        
        var plansArray: [[String:Any]] = []
        if let plans = td.plans{
            for p in plans{
                if let plan = p as? Plan{
                    var planDictionary = plan.dictionaryWithValues(forKeys: planKeys)
                    if let basicWeekDays = plan.basicWeek{
                        var basicWeekDaysArray: [[String:Any]] = []
                        for b in basicWeekDays{
                            if let bDay = b as? BasicWeekDay{
                                basicWeekDaysArray.append(bDay.dictionaryWithValues(forKeys: basicWeekKeys))
                            }
                        }
                        planDictionary[PlanProperty.basicWeek.rawValue] = basicWeekDaysArray
                    }
                    if let pDays = plan.planDays{
                        var planDaysArray: [[String:Any]] = []
                        for d in pDays{
                            if let pDay = d as? PlanDay{
                                planDaysArray.append(pDay.dictionaryWithValues(forKeys: planDayKeys))
                            }
                        }
                        planDictionary[PlanProperty.planDays.rawValue] = planDaysArray
                    }
                    plansArray.append(planDictionary)
                }
            }
            trainingDiaryDictionary[TrainingDiaryProperty.plans.rawValue] = plansArray
        }
        
        
        do {
            let data = try JSONSerialization.data(withJSONObject: trainingDiaryDictionary, options: .prettyPrinted)
            let jsonString = NSString.init(data: data, encoding: String.Encoding.utf8.rawValue)
            return jsonString
            
        } catch  {
            print("JSON export failed")
        }
        
        return nil
    }
    

    
}
    

