//
//  EddingtonNumberCalculator.swift
//  Training Diary
//
//  Created by Steven Lord on 18/10/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Foundation

//Seperate out the eddington calculation so it can be run in a seperate thread.
public class EddingtonNumberCalculator: NSObject{

    static func calculateMaturity(ednum: Int, plusOne: Int, max: Double) -> Double{
        let edSizeFactor = Double(ednum) / max
    //    let plusOneFactor = min(1.0, Double(plusOne) / Double(ednum))
       // return edSizeFactor * plusOneFactor
        return edSizeFactor
    }
    
    
    var eddingtonNumber: Int = 0
    var annualEddingtonNumber: Int = 0
    var plusOne: Int {return nextEddingtonNumber - contributorsToNext.count}
    var annualPlusOne: Int {return nextAnnualEddingtonNumber - annualContributorsToNext.count}
    var contributors: [(date: Date, value: Double)] = []
    var annualContributors: [(date: Date, value: Double)] = []
    var history: [(date: Date, value: Int, plusOne: Int, max: Double)] = []
    var annualHistory: [(date: Date, value: Int, plusOne: Int)] = []
    var maxContributor: Double? { return contributors.map({$0.value}).max()}
    
    private var nextEddingtonNumber: Int {return eddingtonNumber + 1}
    private var nextAnnualEddingtonNumber: Int {return annualEddingtonNumber + 1}
    private var contributorsToNext: [(date: Date, value: Double)]{
        return contributors.filter({$0.value >= Double(nextEddingtonNumber)})
    }
    private var annualContributorsToNext: [(date: Date, value: Double)]{
        return annualContributors.filter({$0.value >= Double(nextAnnualEddingtonNumber)})
    }
    
    private var currentMax: Double = 1.0

    func quickCaclulation(forActivity a: String, andType at: String, equipment e: String, andPeriod p: Period, andUnit u: Unit, inTrainingDiary td: TrainingDiary) -> (ednum: Int,plusOne: Int, maturity: Double ){
        
        let values = td.valuesFor(activity: a, activityType: at, equipment: e, period: p, unit: u)
        return quickEddingNumberCalc(forDoubleValues: values.map({$0.value}).filter({$0 >= 1.0}))
        
    }
    
    func calculate(eddingtonNumber e: EddingtonNumber){
        if let p = Period(rawValue: e.period!){
            if let u = Unit(rawValue: e.unit!){
                let values = e.trainingDiary!.valuesFor(activity: e.activity!, activityType: e.activityType!, equipment: e.equipment!, period: p, unit: u)
                let usefulValues = values.filter({$0.value >= 1.0})
                eddingtonCalculation(forValues: usefulValues)
            }
        }
    }
    
    // updates from last updateded date
    func update(eddingtonNumber e: EddingtonNumber){
        if let from = e.lastUpdated{
            if let p = Period(rawValue: e.period!){
                if let u = Unit(rawValue: e.unit!){
                    populateCalc(forEddingtonNumber: e)
                    let values = e.trainingDiary!.valuesFor(activity: e.activity!, activityType: e.activityType!, equipment: e.equipment!, period: p, unit: u, from: from.startOfDay())
                    eddingtonCalculation(forValues: values, from: from)
                }
            }
        }else{
            //never updated so do the calc from scratch
            calculate(eddingtonNumber: e)
        }
    }
    
    //MARK: - Private

    private func eddingtonCalculation(forValues values: [(date: Date, value: Double)]){
        // need to make sure we doa  from date thats prior to start of the dates
        //is it worth changing this to sort through the dates, find the earliest and go to the year before ?
        let veryEarlyDate: Date = Calendar.current.date(from: DateComponents(year: 1899, month: 12, day: 31))!
        eddingtonCalculation(forValues: values, from: veryEarlyDate)

    }
    
    /* This isn't as quick as the "quick calc" as it creates a history so it needs to run through the
     values in date order.
 */
    private func eddingtonCalculation(forValues values: [(date: Date, value: Double)], from: Date ){
        
        //sort ascending
        let sortedValues = values.sorted(by: {$0.date < $1.date})
        
        // initialise to a date before any date that will be in the diary
        var previousYearEnd: Date = from.endOfYear()
        
        for v in sortedValues{
            //start LTD calc
            if v.value >= Double(nextEddingtonNumber){
                if v.value > currentMax { currentMax = v.value}
                // new contributor
                contributors.append(v)
                
                if contributorsToNext.count >= nextEddingtonNumber{
                    //new eddington number
                    eddingtonNumber = nextEddingtonNumber
                }
                
                history.append((v.date, eddingtonNumber, plusOne, currentMax))
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
            if v.value >= Double(nextAnnualEddingtonNumber){
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
    
    //not remove anything from the lastUpdated date. Reason is any update will include that date
    private func populateCalc(forEddingtonNumber edNum: EddingtonNumber){
        eddingtonNumber = Int(edNum.value)
        annualEddingtonNumber = Int(edNum.annual)
        
        if let contribs = edNum.contributors{
            let array = contribs.allObjects as! [EddingtonContributor]
            for i in array.sorted(by: {$0.date! < $1.date!}){
                contributors.append((i.date!, i.value))

            }

        }
        
        if let annContribs = edNum.annualContributors{
            let array = annContribs.allObjects as! [EddingtonAnnualContributor]
            for i in array.sorted(by: {$0.date! < $1.date!}){
                annualContributors.append((i.date!, i.value))
            }
        }
        
        if let hist = edNum.history{
            let array = hist.allObjects as! [EddingtonHistory]
            for i in array.sorted(by: {$0.date! < $1.date!}){
                history.append((i.date!, Int(i.value), Int(i.plusOne), i.max))
            }
        }
        
        if let annHist = edNum.annualHistory{
            let array = annHist.allObjects as! [EddingtonAnnualHistory]
            for i in array.sorted(by: {$0.date! < $1.date!}){
                annualHistory.append((i.date!, Int(i.value), Int(i.plusOne)))
            }
        }
        
        if let lastUpdate = edNum.lastUpdated{
            contributors = contributors.filter({$0.date < lastUpdate.startOfDay()})
            annualContributors = annualContributors.filter({$0.date < lastUpdate.startOfDay()})
            history = history.filter({$0.date < lastUpdate.startOfDay()})
            annualHistory = annualHistory.filter({$0.date < lastUpdate.startOfDay()})

        }
        
    }
    
    //MARK: - QUICK CALC
    
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
