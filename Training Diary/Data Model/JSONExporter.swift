//
//  JSONExporter.swift
//  Training Diary
//
//  Created by Steven Lord on 10/03/2018.
//  Copyright © 2018 Steven Lord. All rights reserved.
//

import Foundation

class JSONExporter{
    
    func createJSON(forTrainingDiary td: TrainingDiary? = nil, forDays days: [Day], forPhysiologicals physios: [Physiological], forWeights weights: [Weight], forPlans plans: [Plan]) -> NSString?{
        return createJSON(td, days, physios, weights, plans)
    }
    
    func createJSON(forTrainingDiary td: TrainingDiary, andYear year: Int) -> NSString?{
        let days = td.daysArray().filter({$0.date!.year() == year})
        let physios = td.physiologicalArray().filter({$0.fromDate!.year() == year})
        let weights = td.weightsArray().filter({$0.fromDate!.year() == year})
        let plans = td.plansArray().filter({$0.from!.year() == year})
        return createJSON(td, days, physios, weights, plans)
    }
    

    
    func createJSON(forTrainingDiary td: TrainingDiary) -> NSString?{
        return createJSON(td, td.daysArray(), td.physiologicalArray(), td.weightsArray(), td.plansArray())
    }
    
    func createJSON(forPlan plan: Plan) -> NSString?{
        return createJSON(plan.trainingDiary, [], [], [], [plan])
    }
 
    func createJSON(forWorkouts workouts: [Workout]) -> NSString?{
        var trainingDiaryDictionary: [String:Any] = [:]
        trainingDiaryDictionary["Included"] = "Selected Workouts"
        var workoutArray: [[String:Any]] = []
        for workout in workouts{
            var workoutDictionary = workout.dictionaryWithValues(forKeys: WorkoutProperty.jsonProperties.map({$0.rawValue }))
            workoutDictionary[DayProperty.iso8061DateString.rawValue] = workout.day!.date!.iso8601Format()
            workoutArray.append(workoutDictionary)
        }
        trainingDiaryDictionary[DayProperty.workouts.rawValue] = workoutArray
        
        do {
            let data = try JSONSerialization.data(withJSONObject: trainingDiaryDictionary, options: .prettyPrinted)
            let jsonString = NSString.init(data: data, encoding: String.Encoding.utf8.rawValue)
            return jsonString
            
        } catch  {
            print("JSON export of selected workouts failed")
        }
        
        return nil
    }
    
    func createJSON(forEddingtonNumbers edNums: [EddingtonNumber]) -> NSString?{
        var trainingDiaryDictionary: [String:Any] = [:]
        trainingDiaryDictionary["Included"] = "Selected EddingtonNumbers"
        var edArray: [[String:Any]] = []
        for edNum in edNums{
            edArray.append(json(forEddingtonNumber: edNum))
        }
        trainingDiaryDictionary[TrainingDiaryProperty.eddingtonNumbers.rawValue] = edArray
        
        do {
            let data = try JSONSerialization.data(withJSONObject: trainingDiaryDictionary, options: .prettyPrinted)
            let jsonString = NSString.init(data: data, encoding: String.Encoding.utf8.rawValue)
            return jsonString
            
        } catch  {
            print("JSON export of selected workouts failed")
        }
        
        return nil
    }
    
    func createJSON(forLTDEddingtonNumbers edNums: [LTDEddingtonNumber]) -> NSString?{
        var trainingDiaryDictionary: [String:Any] = [:]
        trainingDiaryDictionary["Included"] = "Selected LTDEddingtonNumbers"
        var edArray: [[String:Any]] = []
        for e in edNums{
            edArray.append(e.dictionaryWithValues(forKeys: LTDEddingtonNumberProperty.jsonProperties.map({$0.rawValue})))
        }
        trainingDiaryDictionary[TrainingDiaryProperty.ltdEddingtonNumbers.rawValue] = edArray
        
        do {
            let data = try JSONSerialization.data(withJSONObject: trainingDiaryDictionary, options: .prettyPrinted)
            let jsonString = NSString.init(data: data, encoding: String.Encoding.utf8.rawValue)
            return jsonString
            
        } catch  {
            print("JSON export of selected LTDEddingtonNumbers failed")
        }
        
        return nil
    }
    
    fileprivate func createJSON(_ trainingDiary: TrainingDiary?, _ days: [Day], _ physios: [Physiological], _ weights: [Weight], _ plans: [Plan] ) -> NSString?{
        
        
        var trainingDiaryDictionary: [String:Any] = [:]
        
        if let td = trainingDiary{
            trainingDiaryDictionary = td.dictionaryWithValues(forKeys: TrainingDiaryProperty.jsonProperties.map({$0.rawValue}))
        }
        
        trainingDiaryDictionary["Generated By"] = JSONGenerator.SwiftTrainingDiary.rawValue
        trainingDiaryDictionary["Generated At"] = Date().iso8601Format()
        
        var included: String = ""
        
        if days.count > 0{
            trainingDiaryDictionary[TrainingDiaryProperty.days.rawValue] = createDaysJSON(days.sorted(by: {$0.date! < $1.date!}))
            included = included + "Days :"
        }

        if physios.count > 0{
            trainingDiaryDictionary[TrainingDiaryProperty.physiologicals.rawValue] = createPhysiologicalsJSON(physios.sorted(by: {$0.fromDate! < $1.fromDate!}))
            included = included + "Physiologicals :"
        }

        if weights.count > 0{
            trainingDiaryDictionary[TrainingDiaryProperty.weights.rawValue] = createWeightsJSON(weights.sorted(by: {$0.fromDate! < $1.fromDate!}))
            included = included + "Weights :"
        }
        
        if plans.count > 0{
            trainingDiaryDictionary[TrainingDiaryProperty.plans.rawValue] = createPlansJSON(plans.sorted(by: {$0.from! < $1.from!}))
            included = included + "Plans"
        }
        
        trainingDiaryDictionary["Included"] = included.trimmingCharacters(in: CharacterSet.init(charactersIn: " :"))
        
        
        do {
            let data = try JSONSerialization.data(withJSONObject: trainingDiaryDictionary, options: .prettyPrinted)
            let jsonString = NSString.init(data: data, encoding: String.Encoding.utf8.rawValue)
            return jsonString
            
        } catch  {
            print("JSON export (\(included)) failed")
        }
        
        return nil
    }
    
    fileprivate func createPlansJSON(_ plans: [Plan]) -> [[String:Any]]{
        var plansArray: [[String:Any]] = []
        for plan in plans{
            plansArray.append(createPlanJSON(plan))
        }
        return plansArray
    }
    
    fileprivate func createPlanJSON(_ plan: Plan) -> [String:Any]{
        var planDictionary = plan.dictionaryWithValues(forKeys: PlanProperty.jsonProperties.map({$0.rawValue}))
        var basicWeekDaysArray: [[String:Any]] = []
        if let basicWeekDays = plan.basicWeek?.allObjects as? [BasicWeekDay]{
            for b in basicWeekDays{
                basicWeekDaysArray.append(b.dictionaryWithValues(forKeys: BasicWeekDayProperty.jsonProperties.map({$0.rawValue})))
            }
            planDictionary[PlanProperty.basicWeek.rawValue] = basicWeekDaysArray
            
        }
        var planDaysArray: [[String:Any]] = []
        if let planDays = plan.planDays?.allObjects as? [PlanDay]{
            for planDay in planDays{
                planDaysArray.append(planDay.dictionaryWithValues(forKeys: PlanDayProperty.jsonProperties.map({$0.rawValue})))
                
            }
            planDictionary[PlanProperty.planDays.rawValue] = planDaysArray
            
        }
        return planDictionary
        
    }
    
    fileprivate func createPhysiologicalsJSON(_ physios: [Physiological]) -> [[String:Any]]{
        var physiosArray: [[String:Any]] = []
        for p in physios{
            physiosArray.append(p.dictionaryWithValues(forKeys: PhysiologicalProperty.jsonProperties.map({$0.rawValue})))
        }
        return physiosArray
    }
    
    fileprivate func createWeightsJSON(_ weights: [Weight]) -> [[String:Any]]{
        var weightsArray: [[String:Any]] = []
        for w in weights{
            weightsArray.append(w.dictionaryWithValues(forKeys: WeightProperty.jsonProperties.map({$0.rawValue})))
        }
        return weightsArray
    }
    
    fileprivate func createDaysJSON(_ days: [Day]) -> [[String:Any]] {
        var dayArray: [[String:Any]] = []
        for day in days{
            
            var dayDictionary = day.dictionaryWithValues(forKeys: DayProperty.jsonProperties.map({$0.rawValue}))
            var workoutArray: [[String:Any]] = []
            if let workouts = day.workouts{
                for w in workouts{
                    let workout = w as! Workout
                    let workoutDictionary = workout.dictionaryWithValues(forKeys: WorkoutProperty.jsonProperties.map({$0.rawValue }))
                    workoutArray.append(workoutDictionary)
                }
            }
            if workoutArray.count > 0{
                dayDictionary[DayProperty.workouts.rawValue] = workoutArray
            }
            dayArray.append(dayDictionary)
            
        }
        return dayArray
    }
    
    private func json(forEddingtonNumber edNum: EddingtonNumber) -> [String:Any]{
        var edNumDictionary = edNum.dictionaryWithValues(forKeys: EddingtonNumberProperty.jsonProperties.map({$0.rawValue }))
        
        var annualArray: [[String:Any]] = []
        var contributorsArray: [[String:Any]] = []
        var historyArray: [[String:Any]] = []
        
        if let annual = edNum.annualHistory?.allObjects as? [EddingtonAnnualHistory]{
            for a in annual{
                let aDict = a.dictionaryWithValues(forKeys: EddingtonAnnualHistoryProperty.jsonProperties.map({$0.rawValue}))
                annualArray.append(aDict)
            }
        }
        
        if let contributors = edNum.contributors?.allObjects as? [EddingtonContributor]{
            for c in contributors{
                let cDict = c.dictionaryWithValues(forKeys: EddingtonContributorProperty.jsonProperties.map({$0.rawValue}))
                contributorsArray.append(cDict)
            }
        }
        
        if let history = edNum.history?.allObjects as? [EddingtonHistory]{
            for h in history{
                let hDict = h.dictionaryWithValues(forKeys: EddingtonHistoryProperty.jsonProperties.map({$0.rawValue}))
                historyArray.append(hDict)
            }
        }
        
        edNumDictionary[EddingtonNumberProperty.annualHistory.rawValue] = annualArray
        edNumDictionary[EddingtonNumberProperty.contributors.rawValue] = contributorsArray
        edNumDictionary[EddingtonNumberProperty.history.rawValue] = historyArray
        
        return edNumDictionary
        
    }
    
}
    

