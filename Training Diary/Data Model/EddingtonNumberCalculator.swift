//
//  EddingtonNumberCalculator.swift
//  Training Diary
//
//  Created by Steven Lord on 18/10/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Foundation

//probably don't need this class anymore. Methods can be placed in EddingtonNumber directly
public class EddingtonNumberCalculator: NSObject{

    var eddingtonNumber: Int = 0
    var annualEddingtonNumber: Int = 0
    var plusOne: Int {return nextEddingtonNumber - contributorsToNext.count}
    var annualPlusOne: Int {return nextAnnualEddingtonNumber - annualContributorsToNext.count}
    var contributors: [(date: Date, value: Double)] = []
    var annualContributors: [(date: Date, value: Double)] = []
    var history: [(date: Date, value: Int, plusOne: Int)] = []
    var annualHistory: [(date: Date, value: Int, plusOne: Int)] = []
    
    private var nextEddingtonNumber: Int {return eddingtonNumber + 1}
    private var nextAnnualEddingtonNumber: Int {return annualEddingtonNumber + 1}
    private var contributorsToNext: [(date: Date, value: Double)]{
        return contributors.filter({$0.value >= Double(nextEddingtonNumber)})
    }
    private var annualContributorsToNext: [(date: Date, value: Double)]{
        return annualContributors.filter({$0.value >= Double(nextAnnualEddingtonNumber)})
    }

    func calculate(eddingtonNumber: EddingtonNumber){
        
        if let a = Activity(rawValue: eddingtonNumber.activity!){
            if let p = Period(rawValue: eddingtonNumber.period!){
                if let u = Unit(rawValue: eddingtonNumber.unit!){
                    
                    
                    let values = eddingtonNumber.trainingDiary!.getValues(forActivity: a, andPeriod: p, andUnit: u)
                    let usefulValues = values.filter({$0.value >= 1.0})
                    
                    eddingtonCalculation(forValues: usefulValues)
                    
                    
                }
            }
        }
        
        
    }
    
    func calculateEddingtonNumber(forEddingtonNumber eddingtonNumber: EddingtonNumber){

        if let a = Activity(rawValue: eddingtonNumber.activity!){
            if let p = Period(rawValue: eddingtonNumber.period!){
                if let u = Unit(rawValue: eddingtonNumber.unit!){
                    
                    eddingtonNumber.clearData()
                    
                    let values = eddingtonNumber.trainingDiary!.getValues(forActivity: a, andPeriod: p, andUnit: u)
                    let usefulValues = values.filter({$0.value >= 1.0})
                    
                    
                    for v in usefulValues{
                        eddingtonNumber.updateFor(date: v.date, value: v.value)
                    }
                    
                    eddingtonNumber.lastUpdated = Date()
                    
                }
            }
        }
        
        
    }

    func updateEddingtonNumber(forEddingtonNumber eddingtonNumber: EddingtonNumber){
        if let lastUpdated = eddingtonNumber.lastUpdated{
            if let a = Activity(rawValue: eddingtonNumber.activity!){
                if let p = Period(rawValue: eddingtonNumber.period!){
                    if let u = Unit(rawValue: eddingtonNumber.unit!){
                        
                        let values = eddingtonNumber.trainingDiary!.getValues(forActivity: a, andPeriod: p, andUnit: u, fromDate: lastUpdated)
                                                
                        for v in values{
                            eddingtonNumber.updateFor(date: v.date, value: v.value)
                        }
                        eddingtonNumber.lastUpdated = Date()
                        
                    }
                }
            }

        }else{
            // never been updated so calculated
            calculateEddingtonNumber(forEddingtonNumber: eddingtonNumber)
        }
    }
    


    

    //MARK: - Private
    
    /* This isn't as quick as the "quick calc" as it creates a history so it needs to run through the
     values in date order.
 */
    private func eddingtonCalculation(forValues values: [(date: Date, value: Double)]){
        
        //sort ascending
        let sortedValues = values.sorted(by: {$0.date < $1.date})
        
        // initialise to a date before any date that will be in the diary
        var previousYearEnd: Date = Calendar.current.date(from: DateComponents(year: 1899, month: 12, day: 31))!
        
        for v in sortedValues{
            //start LTD calc
            if v.value > Double(eddingtonNumber){
                // new contributor
                contributors.append(v)
                
                if contributorsToNext.count >= nextEddingtonNumber{
                    //new eddington number
                    eddingtonNumber = nextEddingtonNumber
                }
                
                history.append((v.date, eddingtonNumber, plusOne))
            }
            //start annual calc
            if v.date > previousYearEnd{
                //new year. Grab ed number in to history
                //then reset everything
                if annualEddingtonNumber > 0{
                    annualHistory.append((previousYearEnd, annualEddingtonNumber, annualPlusOne))
                }
                annualEddingtonNumber = 0
                annualContributors = []
                //add new entry to history
                
            }
            if v.value > Double(annualEddingtonNumber){
                annualContributors.append(v)
                
                if annualContributorsToNext.count >= nextAnnualEddingtonNumber{
                    //new eddington number
                    annualEddingtonNumber = nextAnnualEddingtonNumber
                }
                
            }
            previousYearEnd = v.date.endOfYear()
        }
        //slot in the current eddington number
        annualHistory.append((previousYearEnd, annualEddingtonNumber, annualPlusOne))
        //finally remove contributors less than final eddington number
        contributors = contributors.filter({$0.value >= Double(eddingtonNumber)})
    }
    
    //check this = can't we overload and name this quickEddingtonNumberCalc(values: [Double])  ???
    private func quickEddingNumberCalc(forDoubleValues values: [Double]) -> (ednum: Int,plusOne: Int, maturity: Double ){
        return quickEddingtonNumberCalc(forIntValues: values.map{Int($0)})
    }
    
    private func quickEddingtonNumberCalc(forIntValues values: [Int]) -> (ednum: Int,plusOne: Int, maturity: Double ){
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

 
    
}
