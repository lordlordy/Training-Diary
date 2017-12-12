//
//  EddingtonNumber+Extension.swift
//  Training Diary
//
//  Created by Steven Lord on 31/10/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Foundation

extension EddingtonNumber{
    
    var nextEddingtonNumber: Int16{ return value + 1}
    var nextAnnualEddingtonNumber: Int16 { return annual + 1}
    @objc dynamic var plusOne: Int16 { return nextEddingtonNumber - Int16(contributorsToNext().count) }
    @objc dynamic var annualPlusOne: Int16 { return nextAnnualEddingtonNumber  - Int16(contributorsToAnnualNext().count) }
    @objc dynamic var maturity: Double{ return calculateMaturity() }
    @objc dynamic var daysSinceLastContributor: Double { return calculateDaysSinceLastContributor() }

    @objc dynamic var requiresCalculation: Bool{ return lastUpdated == nil}
    
    @objc dynamic var eddingtonCode: String{
        var result = ""
        if let a = activity {
            result += a
            if let at = activityType {
                result += ":" + at
                if let p = period {
                    result += ":" + p
                    if let u = unit {
                        result += ":" + u
                    }
                }
            }
        }
        return result
    }
    
    func contributorsToNext() -> [EddingtonContributor]{
        let currentContributors = getContributors()
        return currentContributors.filter({$0.value >= Double(nextEddingtonNumber)})
    }
    
    func contributorsToAnnualNext() -> [EddingtonAnnualContributor]{
        let currentAnnualContributors = getAnnualContributors()
        return currentAnnualContributors.filter({$0.value >= Double(nextAnnualEddingtonNumber)})
    }
    
    public func updateFor(date d: Date, value v: Double){
        updateLTDFor(date: d, value: v)
        updateAnnualFor(date: d, value: v)
    }
    
    //this removes all history and contributors
    func clearData(){
        mutableSetValue(forKey: EddingtonNumberProperty.annualContributors.rawValue).removeAllObjects()
        mutableSetValue(forKey: EddingtonNumberProperty.annualHistory.rawValue).removeAllObjects()
        mutableSetValue(forKey: EddingtonNumberProperty.contributors.rawValue).removeAllObjects()
        mutableSetValue(forKey: EddingtonNumberProperty.history.rawValue).removeAllObjects()
        //effectively no calculation now done ... so remove lastUpdated
        self.lastUpdated = nil
    }
    

    public func getSortedHistory() -> [EddingtonHistory]{
        let all = self.mutableSetValue(forKey: EddingtonNumberProperty.history.rawValue).allObjects as! [EddingtonHistory]
        return all.sorted(by: {$0.date! < $1.date!})
    }
    
    public func getSortedAnnualHistory() -> [EddingtonAnnualHistory]{
        let all = self.mutableSetValue(forKey: EddingtonNumberProperty.annualHistory.rawValue).allObjects as! [EddingtonAnnualHistory]
        return all.sorted(by: {$0.date! < $1.date!})
    }
    
    public func getSortedContributors() -> [EddingtonContributor]{
        return getContributors().sorted(by: {$0.date! < $1.date!})
    }
    
    public func getContributors() -> [EddingtonContributor]{
        if let c = self.contributors{
            return c.allObjects as! [EddingtonContributor]
        }
        return []
    }

    
    
    override public class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String>{
        let keyPaths = super.keyPathsForValuesAffectingValue(forKey: key)
        switch key {
        case "eddingtonCode":
            return keyPaths.union(Set(["activity","activityType","period","unit"]))
        case "maturity":
            return keyPaths.union(Set(["lastUpdated"]))
        default:
            return keyPaths
        }
    }
    
    //MARK: - Private
    
    private func updateLTDFor(date d: Date, value v: Double){
        if v < Double(nextEddingtonNumber) { return } // doesn't contribute
        
        //value at least the next eddington number - this means it contributes so add it
        // it also means at least one of eddington number or plusOne count as changed so add history
        
        let newContributor = CoreDataStackSingleton.shared.newEddingtonContributor()
        newContributor.date = d
        newContributor.value = v
        self.mutableSetValue(forKey: EddingtonNumberProperty.contributors.rawValue).add(newContributor)
        
        if contributorsToNext().count >= nextEddingtonNumber{
            //have a new eddington number
            value = nextEddingtonNumber
            // strip out non contributors
            removeNonContributors()
        }
        
        let newHistory = CoreDataStackSingleton.shared.newEddingtonHistory()
        newHistory.date = d
        newHistory.value = value
        newHistory.plusOne = plusOne
        
        let historyMutableSet = self.mutableSetValue(forKey: EddingtonNumberProperty.history.rawValue)
        historyMutableSet.add(newHistory)
    }
    
    private func updateAnnualFor(date d: Date, value v: Double){
        let edAnnualContributors = mutableSetValue(forKey: EddingtonNumberProperty.annualContributors.rawValue)
        let edAnnualHistory = mutableSetValue(forKey: EddingtonNumberProperty.annualHistory.rawValue)

        if let lastDate = lastAnnualEddingtonNumberDate(){
            if d.endOfYear() != lastDate{
                //have a new year. Need to reset everything
                annual = 0
                edAnnualContributors.removeAllObjects()
                //set date of history to end of year - do we really need to do this ?
                setLastHistoryToEndOfYear()
                //append new history element
                let newEdAnnualHistory = CoreDataStackSingleton.shared.newEddingtonAnnualHistory()
                newEdAnnualHistory.date = d.endOfYear()
                newEdAnnualHistory.value = 0
                newEdAnnualHistory.plusOne = 0
                edAnnualHistory.add(newEdAnnualHistory)
            }
        }else{
            // no entries added yet -set up first one
            let newEdAnnualHistory = CoreDataStackSingleton.shared.newEddingtonAnnualHistory()
            newEdAnnualHistory.date = d.endOfYear()
            newEdAnnualHistory.value = 0
            newEdAnnualHistory.plusOne = 0
            edAnnualHistory.add(newEdAnnualHistory)
        }
        
        if v < Double(nextAnnualEddingtonNumber) { return } // doesn't contribute
        
        let newContributor = CoreDataStackSingleton.shared.newEddingtonAnnualContributor()
        newContributor.date = d
        newContributor.value = v
        edAnnualContributors.add(newContributor)
        
        if contributorsToAnnualNext().count >=  nextAnnualEddingtonNumber{
            annual = nextAnnualEddingtonNumber
            // strip out non contributors
            removeAnnualNonContributors()
        }
        // amend last element
        let sortedAnnualHistory = getSortedAnnualHistory()
        sortedAnnualHistory[sortedAnnualHistory.count - 1].date = d
        sortedAnnualHistory[sortedAnnualHistory.count - 1].value = annual
        sortedAnnualHistory[sortedAnnualHistory.count - 1].plusOne = annualPlusOne
        
    }
    
    
    private func getAnnualContributors() -> [EddingtonAnnualContributor]{
        if let c = self.annualContributors{
            return c.allObjects as! [EddingtonAnnualContributor]
        }
        return []
    }
    
    private func removeNonContributors(){
        //strip out all contributors that are less than the current eddington number
        let currentEddingtonNumber = Double(value)
        let currentContributors = self.mutableSetValue(forKey: EddingtonNumberProperty.contributors.rawValue)
        for cc in currentContributors{
            let c = cc as! EddingtonContributor
            if c.value <= currentEddingtonNumber{
                currentContributors.remove(cc)
            }
        }
    }
    
    private func removeAnnualNonContributors(){
        //strip out all contributors that are less than the current eddington number
        let currentEddingtonNumber = Double(annual)
        let currentContributors = self.mutableSetValue(forKey: EddingtonNumberProperty.annualContributors.rawValue)
        for cc in currentContributors{
            let c = cc as! EddingtonAnnualContributor
            if c.value <= currentEddingtonNumber{
                currentContributors.remove(cc)
            }
        }
    }
    
    private func lastAnnualEddingtonNumberDate() -> Date?{

        let sortedHistory = getSortedAnnualHistory()
        
        if sortedHistory.count == 0{
            // nothing there yet
            return nil
        }
        return sortedHistory[sortedHistory.count - 1].date?.endOfYear()
    }
    
    private func setLastHistoryToEndOfYear(){
        let sortedHistory = getSortedAnnualHistory()
        sortedHistory[sortedHistory.count - 1].date = sortedHistory[sortedHistory.count - 1].date?.endOfYear()
    }
    

    
    private func calculateMaturity() -> Double{

        let daysSinceLastContributor = calculateDaysSinceLastContributor()
        return 1 - 1 / ( exp(daysSinceLastContributor/365))
        
    }
    
    private func calculateDaysSinceLastContributor() -> Double{
        let sortedContributors = getSortedContributors()
        if sortedContributors.count > 0{
            if let now = trainingDiary?.lastDayOfDiary{
                let seconds = now.timeIntervalSince(sortedContributors[sortedContributors.count - 1].date!)
                return seconds / Constant.SecondsPerDay.rawValue
            }
        }
        return 0.0
    }
    
    
}
