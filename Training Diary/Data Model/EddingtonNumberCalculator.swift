//
//  EddingtonNumberCalculator.swift
//  Training Diary
//
//  Created by Steven Lord on 18/10/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Foundation

//probably don't need this class anymore. Methods can be placed in EddingtonNumber directly
public class EddingtonNumberCalculator{

    static let shared = EddingtonNumberCalculator()

    func calculateEddingtonNumber(forEddingtonNumber eddingtonNumber: EddingtonNumber){

        if let a = Activity(rawValue: eddingtonNumber.activity!){
            if let p = Period(rawValue: eddingtonNumber.period!){
                if let u = Unit(rawValue: eddingtonNumber.unit!){
                    
                    eddingtonNumber.clearData()
                    
                    let values = eddingtonNumber.trainingDiary!.getValues(forActivity: a, andPeriod: p, andUnit: u)
                    
                    for v in values{
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
