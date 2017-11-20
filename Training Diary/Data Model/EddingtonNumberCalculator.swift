//
//  EddingtonNumberCalculator.swift
//  Training Diary
//
//  Created by Steven Lord on 18/10/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Foundation

/*REFACTOR change returns form Ed calcs to be Int.
 - need to consolidate the use of Core Data. Each time a number is calculated then the core data should be updated.
*/
public class EddingtonNumberCalculator{

    static let shared = EddingtonNumberCalculator()
    
    private struct CalculationResult{
        var edCode:         String = ""
        var edNum:          Int16 = 0
        var plusOne:        Int16 = 0
        var maturity:       Double = 0.0
        var annualEdCode:   String = ""
        var annual:         Int16 = 0
        var annPlusOne:     Int16 = 0
        var annMaturity:    Double = 0.0
        var lastUpdated:    Date = Date()
    }
    



    /* This calculates all LTD eddington numbers and saves them to Core Data. Currently
     this just adds to core data. ie running multiple times will create duplicates.
     Also this only does ActivityTypes - ALL. Need to change to do all sub activities as well
     - this eventually doesn't need to return the values
     REFACTOR
    */
    func calcEddingtonNumbersFromBaseData(forTrainingDiary td: TrainingDiary, andYear year: Int16) -> [EddingtonNumber]{
        var results: [EddingtonNumber] = []
        for a in Activity.allActivities{
            print("Starting \(a.rawValue)...")
            for at in a.typesForEddingtonNumbers(){
                print("--Starting \(at.rawValue)")
                for p in Period.baseDataPeriods{
                    print("----Starting \(p.rawValue)...")
                    for u in a.unitsForEddingtonNumbers(){
                        let result = calculate(forYear: year, activity: a, activityType: at, period: p, unit: u, forTrainingDiary: td)
                        if(result.edNum > 0){
                            //this call gets eddington number instance if it exists, otherwise creates it.
                            let eddingtonNumber = CoreDataStackSingleton.shared.getEddingtonNumber(forYear: year, activity: a, activityType: at, period: p, unit: u, trainingDiary: td)
                            eddingtonNumber.setValue(result.edNum, forKey: EddingtonNumberProperty.value.rawValue)
                            eddingtonNumber.setValue(result.plusOne, forKey: EddingtonNumberProperty.plusOne.rawValue)
                            eddingtonNumber.setValue(result.maturity, forKey: EddingtonNumberProperty.maturity.rawValue)
                            eddingtonNumber.setValue(result.annual, forKey: EddingtonNumberProperty.annual.rawValue)
                            eddingtonNumber.setValue(result.annPlusOne, forKey: EddingtonNumberProperty.annualPlusOne.rawValue)
                            eddingtonNumber.setValue(result.annMaturity, forKey: EddingtonNumberProperty.annualMaturity.rawValue)
                            eddingtonNumber.setValue(result.lastUpdated, forKey: EddingtonNumberProperty.lastUpdated.rawValue)
                            results.append(eddingtonNumber)
                        }
                    }
                }
            }
        }
        td.setValue(Date(), forKey: TrainingDiaryProperty.eddingtonNumberLastUpdate.rawValue)
        return results
    }
 
    
    //results are inserted in the Eddington Number
    func calculate(forEddingtonNumbers es: [EddingtonNumber], forTrainingDiary td: TrainingDiary){
        for e in es{
            update(eddingtonNumber: e, forTrainingDiary: td)
        }
    }
    

    //MARK: - Private
    

    private func update(eddingtonNumber e: EddingtonNumber, forTrainingDiary td: TrainingDiary){
        
        let result = calculate(forYear: e.year, activity: Activity(rawValue: e.activity!)!, activityType: ActivityType(rawValue: e.activityType!)!, period: Period(rawValue: e.period!)!, unit: Unit(rawValue: e.unit!)!, forTrainingDiary: td)
        
        e.setValue(result.maturity, forKey: EddingtonNumberProperty.maturity.rawValue)
        e.setValue(result.plusOne, forKey: EddingtonNumberProperty.plusOne.rawValue)
        e.setValue(result.edNum, forKey: EddingtonNumberProperty.value.rawValue)
        e.setValue(result.annMaturity, forKey: EddingtonNumberProperty.annualMaturity.rawValue)
        e.setValue(result.annPlusOne, forKey: EddingtonNumberProperty.annualPlusOne.rawValue)
        e.setValue(result.annual, forKey: EddingtonNumberProperty.annual.rawValue)
        e.setValue(result.lastUpdated, forKey: EddingtonNumberProperty.lastUpdated.rawValue)
    }
    
    private func calculate(forYear y: Int16, activity a: Activity, activityType at: ActivityType, period p: Period, unit u: Unit, forTrainingDiary td: TrainingDiary) -> CalculationResult{
        
        var result:  CalculationResult =  CalculationResult.init()
        
        // this is values to end of year.
        let ltdData = CoreDataStackSingleton.shared.baseDataValues(toYearEnd: y, activity: a, activityType: at, period: p, unit: u, forTrainingDiary: td)
        print("\(ltdData.values.count) records returned for LTD calc")
        
        // this is values for the year
        let annualData = CoreDataStackSingleton.shared.baseDataValues(forYear: y, activity: a, activityType: at, period: p, unit: u, forTrainingDiary: td)
        print("\(annualData.values.count) records returned for Annual calc")

        if ltdData.values.count > 0{
            let edNum = quickEddingNumberCalcForDoubles(values: ltdData.values)
            print("\(ltdData.eddingtonCode):\(edNum)")
            //set code to match the code in base data
            
            result.edCode = ltdData.eddingtonCode
            result.plusOne = Int16.init(edNum.plusOne)
            result.edNum = Int16.init(edNum.ednum)
            result.maturity = edNum.maturity
            
            //annual calc
            if annualData.values.count > 0{
                let annEdNum = quickEddingNumberCalcForDoubles(values: annualData.values)
                print("Annual calc gives: \(annEdNum)")
                result.annual = Int16.init(annEdNum.ednum)
                result.annPlusOne = Int16.init(annEdNum.plusOne)
                result.annMaturity = annEdNum.maturity
            }
            result.lastUpdated = Date()
        }else{
            let key = a.rawValue + ":" + at.rawValue + ":" + p.rawValue + ":" + u.rawValue
            print("~*~*~ NO data found in Base Data for \(key) and year \(y)")
        }
        return result
    }
    
    //check this = can't we overload and name this quickEddingtonNumberCalc(values: [Double])  ???
    private func quickEddingNumberCalcForDoubles(values: [Double]) -> (ednum: Int,plusOne: Int, maturity: Double ){
        return quickEddingtonNumberCalc(values: values.map{Int($0)})
    }
    
    private func quickEddingtonNumberCalc(values: [Int]) -> (ednum: Int,plusOne: Int, maturity: Double ){
        /* This orders the  array descending. Then goes down till the rank is greater than the value. The previous one is the eddington number. Note the comparison is against the Int part of the value
         */
        if values.count == 0 { return (0,0,0.0) }
        if values.count == 1 { return (1,1,0.0) } // this case is strictly right since one elemnt less than one is edd num of 0.

        let sortedValues = values.sorted{$0 > $1}
        var rank: Int = 1
        // arrays are indexed from zero but we want ranks starting from 1. Hence the '-1' in the array index
        while rank<=values.count && sortedValues[rank-1] >= rank {
            rank += 1
        }
         //note when we exit the rank has increment one above so need to subtract 1 for eddington number
        let edNum = rank-1
        // calculate +1 value. First count number of elements > ed num
        let greatThanNumbers = sortedValues.filter({$0 > edNum})
        let plusOne = (edNum + 1) - greatThanNumbers.count
        
        
        //calculate maturity
        var maturity: Double = max(0, 1.0 - Double(rank)/Double(values.count))
        if(values[0] == edNum){
            //this means there is no value great than the eddington number
            maturity = 1.0
        }
        

        return (edNum,plusOne, maturity)
    }

    
    private init(){
    }
    
}
