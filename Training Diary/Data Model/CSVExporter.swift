//
//  CSVExporter.swift
//  Training Diary
//
//  Created by Steven Lord on 18/01/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Foundation

class CSVExporter{
    
    struct TrainingDiaryCVSStrings{
        var days: String
        var workouts: String
        var weights: String
        var physiologicals: String
        var plans: String
        var basicWeek: String
        var planDays: String
    }
    
    struct EddingtonNumberStrings{
        var eddingtonNumbers: String
        //the following are dictionaries with the key the eddington code
        var history: [String:String]
        var contributors: [String:String]
        var annualHistory: [String:String]
    }
    
    var weightsDictionary: [String:Weight] = [:]
    var physioDictionary: [String:Physiological] = [:]

    func convertToCSV(trainingDiary td: TrainingDiary) -> TrainingDiaryCVSStrings{
        return convertToCSV(td, td.days?.allObjects as? [Day] ?? [], td.weights?.allObjects as? [Weight] ?? [], td.physiologicals?.allObjects as? [Physiological] ?? [], td.plans?.allObjects as? [Plan] ?? [])
    }
    
    func convertToCSV(trainingDiary td: TrainingDiary, forYear year: Int) -> TrainingDiaryCVSStrings{
        return convertToCSV(td, td.daysArray().filter({$0.date!.year() == year}).sorted(by: {$0.date! < $1.date!}), td.weightsArray().filter({$0.fromDate!.year() == year}).sorted(by: {$0.fromDate! < $1.fromDate!}), td.physiologicalArray().filter({$0.fromDate!.year() == year}).sorted(by: {$0.fromDate! < $1.fromDate!}), td.plansArray().filter({$0.from?.year() == year}).sorted(by: {$0.from! < $1.from!}))
    }
    
    //this is split out to allow the conversion of a selection to CSV
    func convertToCSV(_ td: TrainingDiary, _ days: [Day], _ weights: [Weight], _ physiologicals: [Physiological], _ plans: [Plan]) -> TrainingDiaryCVSStrings{
        
        createDictionaries(weights, physiologicals)
        let result = convertToCSV(days, td)
        let weights = convertToCSV(forWeights: weights)
        let physios = convertToCSV(forPhysios: physiologicals)
        let plans = convertToCSV(plans)
        return TrainingDiaryCVSStrings(days: result.dayCSV, workouts: result.workoutCSV, weights: weights, physiologicals: physios, plans: plans.plan, basicWeek: plans.basicWeek, planDays: plans.planDays)
    
    }
    
    
    func convertToCSV(_ workouts: [Workout]) -> String{
        var workoutString: String = createHeaderRow(WorkoutProperty.csvProperties.map({$0.rawValue}))
        workoutString += "\n"
        for w in workouts{
            workoutString += w.day!.date!.dateOnlyString()
            workoutString += ","
            workoutString += csv(w, WorkoutProperty.csvProperties.map({$0.rawValue}))
            workoutString += "\n"
        }
        return workoutString
    }

    func convertToCSV(_ ltdEdNums: [LTDEddingtonNumber]) -> String{
        var edNumString: String = createHeaderRow(LTDEddingtonNumberProperty.csvProperties.map({$0.rawValue}))
        edNumString += "\n"
        for l in ltdEdNums{
            edNumString += csv(l, LTDEddingtonNumberProperty.csvProperties.map({$0.rawValue}))
            edNumString += "\n"
        }
        return edNumString
    }
    
    func convertToCSV(_ edNums: [EddingtonNumber]) -> EddingtonNumberStrings{
        var edNumString: String = createHeaderRow(EddingtonNumberProperty.csvProperties.map({$0.rawValue}))
        edNumString += "\n"
        
        var historyDict: [String:String] = [:]
        var contributorsDict: [String:String] = [:]
        var annualHistoryDict: [String:String] = [:]
        
        for e in edNums{
            edNumString += csv(e, EddingtonNumberProperty.csvProperties.map({$0.rawValue}))
            edNumString += "\n"
            
            if let history = e.history?.allObjects as? [EddingtonHistory]{
                var historyString: String = createHeaderRow(EddingtonHistoryProperty.csvProperties.map({$0.rawValue}))
                historyString += "\n"
                for h in history{
                    historyString += csv(h, EddingtonHistoryProperty.csvProperties.map({$0.rawValue}))
                    historyString += "\n"
                }
                historyDict[e.eddingtonCode] = historyString
            }
            
            if let contributors = e.contributors?.allObjects as? [EddingtonContributor]{
                var contributorString: String = createHeaderRow(EddingtonContributorProperty.csvProperties.map({$0.rawValue}))
                contributorString += "\n"
                for c in contributors{
                    contributorString += csv(c, EddingtonContributorProperty.csvProperties.map({$0.rawValue}))
                    contributorString += "\n"
                }
                contributorsDict[e.eddingtonCode] = contributorString
            }
            
            if let annualHistory = e.annualHistory?.allObjects as? [EddingtonAnnualHistory]{
                var annualString: String = createHeaderRow(EddingtonAnnualHistoryProperty.csvProperties.map({$0.rawValue}))
                annualString += "\n"
                for a in annualHistory{
                    annualString += csv(a, EddingtonAnnualHistoryProperty.csvProperties.map({$0.rawValue}))
                    annualString += "\n"
                }
                annualHistoryDict[e.eddingtonCode] = annualString
            }
            
        }
        
        return EddingtonNumberStrings(eddingtonNumbers: edNumString, history: historyDict, contributors: contributorsDict, annualHistory: annualHistoryDict)
        
    }
    
    private func convertToCSV(_ days: [Day], _ td: TrainingDiary) -> (dayCSV: String, workoutCSV: String){
        
        var workoutString: String = "date,"
        var dayString: String = ""
        var workoutCount: Int = 0
        var dayCount: Int = 0
    
        workoutString += createHeaderRow(WorkoutProperty.csvProperties.map({$0.rawValue}))
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
                        workoutString += ","
                        workoutString += csv(w as! Workout, WorkoutProperty.csvProperties.map({$0.rawValue}))
                        workoutString += "\n"
                    }
                }
            }
        }
                
        print("Workout count: \(workoutCount)")
        print("Day count: \(dayCount)")

        return (dayCSV: dayString, workoutCSV: workoutString)
    }
    
    private func convertToCSV(_ plans: [Plan]) -> (plan: String, basicWeek: String, planDays: String){
        
        if plans.count == 0{
            return (plan: "", basicWeek: "", planDays: "")
        }
        
        var planString: String = createHeaderRow(PlanProperty.csvProperties.map({$0.rawValue}))
        planString += "\n"
        
        var basicWeekString: String = createHeaderRow(BasicWeekDayProperty.csvProperties.map({$0.rawValue}))
        basicWeekString += "\n"
        
        var planDaysString: String = createHeaderRow(PlanDayProperty.csvProperties.map({$0.rawValue}))
        planDaysString += "\n"
        
        for p in plans{
            planString += csv(p, PlanProperty.csvProperties.map({$0.rawValue}))
            planString += "\n"
            if let basicWeek = p.basicWeek?.allObjects as? [BasicWeekDay]{
                for b in basicWeek{
                    basicWeekString += csv(b, BasicWeekDayProperty.csvProperties.map({$0.rawValue}))
                    basicWeekString += "\n"
                }
            }
            if let planDays = p.planDays?.allObjects as? [PlanDay]{
                for p in planDays{
                    planDaysString += csv(p, PlanDayProperty.csvProperties.map({$0.rawValue}))
                    planDaysString += "\n"
                }
            }
        }
        
        
        return (planString, basicWeekString, planDaysString)
    }
    
    
    private func convertToCSV(forPhysios physios: [Physiological]) -> String{
        
        let properties: [String] = PhysiologicalProperty.csvProperties.map({$0.rawValue})
        var physioString: String = createHeaderRow(properties)
        physioString += "\n"
        
        for phys in physios{
            physioString += csv(phys, properties)
            physioString += "\n"
        }
        
        return physioString
    }

    
    private func convertToCSV(forWeights weights: [Weight]) -> String{
        
        var weightString: String = createHeaderRow(WeightProperty.csvProperties.map({$0.rawValue}))
        weightString += "\n"
        
        for w in weights{
            weightString += csv(w, WeightProperty.csvProperties.map({$0.rawValue}))
            weightString += "\n"
        }
        
        return weightString
    }

    private func csv(forDay d: Day) -> String{
        var result: String = csv(d, DayProperty.csvProperties.map({$0.rawValue}))
        
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

    private func csv(_ obj: NSObject, _ properties: [String]) -> String{
        var result: String = ""
        
        for p in properties{
            if let value = obj.value(forKey: p){
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
        return result
//        return result.trimmingCharacters(in: CharacterSet(charactersIn: ","))
    }
    
    private func createHeaderRow(_ properties: [String]) -> String{
        var result: String = ""
        
        for p in properties{
            result += p
            result += ","
        }
        
        return result.trimmingCharacters(in: CharacterSet.init(charactersIn: ","))
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
    
    private func createDictionaries(_ weights: [Weight], _ physios: [Physiological]){
        weightsDictionary = [:]
        physioDictionary = [:]
        
        for w in weights{
            weightsDictionary[w.fromDateString] = w
        }
        
        
        for p in physios{
            physioDictionary[p.fromDateString] = p
        }
    
    }
    
}
