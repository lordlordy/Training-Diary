//
//  Day+Extension.swift
//  Training Diary
//
//  Created by Steven Lord on 07/10/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Foundation

extension Day{
    
    
    /* We do not want this to fail as when requesting a value for a particular combination of activity, type and unit a valid answer is zero. For example: if this gets asked what the swim squad ascent is then the correct answer is zero.
    */

    func valueFor(activity: Activity, activityType: ActivityType, unit: Unit) -> Double{
        var result = 0.0
        if activityType == ActivityType.All{
            //this is small optimisation in case a simple calculated propery is available for this.
            //Note that if no value is available we'll drop through this to the generic method
            if let value = self.value(forKey: activity.keyString(forUnit: unit)){
                return value as! Double
            }
        }
        if unit.summable{
            result = sumOverWorkouts(forActivities: [activity], andTypes: [activityType], andUnit: unit)
        }else{
            result = weightedAverageOverWorkouts(forActivities: [activity], andTypes: [activityType], andUnit: unit)
        }
        return result
    }

    /* Over ridden this to avoid exceptions being fired if ask for a key that doesn't exist. Instead return nil.
     This allows me to check for value. Main reason is method valueFor(activity:,activityType:unit:)
 */
    public override func value(forUndefinedKey key: String) -> Any? {
        return nil
    }
    
    func valueFor(period p: Period, activity a: Activity, activityType at: ActivityType, unit u: Unit ) -> Double{
        switch p{
        case .Day:
            return valueFor(activity: a, activityType: at, unit: u)
        case .Week:
            if self.date!.isEndOfWeek(){
                return valueFor(period: Period.rWeek, activity: a, activityType: at, unit: u)
            }else{
                return 0.0
            }
        case .Month:
            if self.date!.isEndOfMonth(){
                return valueFor(period: Period.rMonth, activity: a, activityType: at, unit: u)
            }else{
                return 0.0
            }
        case .Year:
            if self.date!.isEndOfYear(){
                return valueFor(period: Period.rYear, activity: a, activityType: at, unit: u)
            }else{
                return 0.0
            }
        case .WeekToDate:
            return recursiveAdd(toDate: self.date!.startOfWeek(), activity: a, activityType: at, unit: u)
        case .MonthToDate:
            return recursiveAdd(toDate: self.date!.startOfMonth(), activity: a, activityType: at, unit: u)
        case .YearToDate:
            return recursiveAdd(toDate: self.date!.startOfYear(), activity: a, activityType: at, unit: u)
        case .rWeek:
            return recursiveAdd(toDate: self.date!.startOfRWeek(), activity: a, activityType: at, unit: u)
        case .rMonth:
            return recursiveAdd(toDate: self.date!.startOfRMonth(), activity: a, activityType: at, unit: u)
        case .rYear:
            return recursiveAdd(toDate: self.date!.startOfRYear(), activity: a, activityType: at, unit: u)
        case .Lifetime:
            return recursiveAdd(toDate: self.trainingDiary!.firstDayOfDiary, activity: a, activityType: at, unit: u)
        case .Adhoc:
            return 0.0
        }
        
        
    }
    
    /*This is the method that needs implementing to ensure calculated properties update when the properties
    they depend on change.
     */
    override public class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String>{
        let keyPaths = super.keyPathsForValuesAffectingValue(forKey: key)
        switch key {
        case DayCalculatedProperty.numberOfWorkouts.rawValue:
            return keyPaths.union(Set([DayProperty.workouts.rawValue]))
//        case DayCalculatedProperty.swimTSB.rawValue:
  //          return keyPaths.union(Set([DayProperty.swimATL.rawValue, DayProperty.swimCTL.rawValue]))
    //    case DayCalculatedProperty.bikeTSB.rawValue:
      //      return keyPaths.union(Set([DayProperty.bikeATL.rawValue, DayProperty.bikeCTL.rawValue]))
//        case DayCalculatedProperty.runTSB.rawValue:
  //          return keyPaths.union(Set([DayProperty.runATL.rawValue, DayProperty.runCTL.rawValue]))
    //    case DayCalculatedProperty.allTSB.rawValue:
      //      return keyPaths.union(Set([DayProperty.allATL.rawValue, DayProperty.allCTL.rawValue]))
  //      case DayCalculatedProperty.allCTL.rawValue:
    //        return keyPaths.union(Set([DayProperty.swimCTL.rawValue, DayProperty.bikeCTL.rawValue, DayProperty.runCTL.rawValue, DayProperty.gymCTL.rawValue, DayProperty.walkCTL.rawValue, DayProperty.otherCTL.rawValue]))
  //      case DayCalculatedProperty.allATL.rawValue:
    //        return keyPaths.union(Set([DayProperty.swimATL.rawValue, DayProperty.bikeATL.rawValue, DayProperty.runATL.rawValue, DayProperty.gymATL.rawValue, DayProperty.walkATL.rawValue, DayProperty.otherATL.rawValue]))
//        case _ where DayCalculatedProperty.ALL.map{$0.rawValue}.contains(key):
  //          return keyPaths.union(Set([DayProperty.workoutChanged.rawValue]))
        default:
            return keyPaths
        }
    }

    
    //MARK: - Calculated properties - these are for display in GUI

    @objc dynamic var swimATL: Double{
        return metricValue(forActivity: Activity.Swim, andMetric: Unit.ATL)
    }

    @objc dynamic var swimCTL: Double{
        return metricValue(forActivity: Activity.Swim, andMetric: Unit.CTL)
    }

    @objc dynamic var swimHours: Double{
        return swimSeconds / Constant.SecondsPerHour.rawValue
    }
 
    @objc dynamic var swimKJ: Double{
        return sumOverWorkouts(forActivities: [Activity.Swim], andTypes: [ActivityType.All], andUnit: WorkoutProperty.kj.unit()!)
    }
    @objc dynamic var swimKM: Double{
        return sumOverWorkouts(forActivities: [Activity.Swim], andTypes: [ActivityType.All], andUnit: WorkoutProperty.km.unit()!)
    }
    @objc dynamic var swimMinutes: Double{
        return swimSeconds / Constant.SecondsPerMinute.rawValue
    }
    @objc dynamic var swimSeconds: Double{
        return sumOverWorkouts(forActivities: [Activity.Swim], andTypes: [ActivityType.All], andUnit: WorkoutProperty.seconds.unit()!)
    }
    @objc dynamic var swimTSB: Double{
        return metricValue(forActivity: Activity.Swim, andMetric: Unit.TSB)
    }
    @objc dynamic var swimTSS: Double{
        return sumOverWorkouts(forActivities: [Activity.Swim], andTypes: [ActivityType.All], andUnit: WorkoutProperty.tss.unit()!)
    }
    @objc dynamic var swimWatts: Double{
        return weightedAverageOverWorkouts(forActivities: [Activity.Swim], andTypes: [ActivityType.All], andUnit: WorkoutProperty.watts.unit()!)
    }
    
    @objc dynamic var bikeATL: Double{
        return metricValue(forActivity: Activity.Bike, andMetric: Unit.ATL)
    }
    
    @objc dynamic var bikeCTL: Double{
        return metricValue(forActivity: Activity.Bike, andMetric: Unit.CTL)
    }
    
    @objc dynamic var bikeAscentFeet: Double{
        return bikeAscentMetres * Constant.FeetPerMetre.rawValue
    }
    @objc dynamic var bikeAscentMetres: Double{
        return sumOverWorkouts(forActivities: [Activity.Bike], andTypes: [ActivityType.All], andUnit: WorkoutProperty.ascentMetres.unit()!)
    }
    @objc dynamic var bikeHours: Double{
        return bikeSeconds / Constant.SecondsPerHour.rawValue
    }
    @objc dynamic var bikeHR: Double{
        return weightedAverageOverWorkouts(forActivities: [Activity.Bike], andTypes: [ActivityType.All], andUnit: WorkoutProperty.hr.unit()!)
    }
    @objc dynamic var bikeKJ: Double{
        return sumOverWorkouts(forActivities: [Activity.Bike], andTypes: [ActivityType.All], andUnit: WorkoutProperty.kj.unit()!)
    }
    @objc dynamic var bikeKM: Double{
        return sumOverWorkouts(forActivities: [Activity.Bike], andTypes: [ActivityType.All], andUnit: WorkoutProperty.km.unit()!)
    }
    @objc dynamic var bikeMinutes: Double{
        return bikeSeconds / Constant.SecondsPerMinute.rawValue
    }
    @objc dynamic var bikeSeconds: Double{
        return sumOverWorkouts(forActivities: [Activity.Bike], andTypes: [ActivityType.All], andUnit: WorkoutProperty.seconds.unit()!)
    }
    @objc dynamic var bikeTSS: Double{
        return sumOverWorkouts(forActivities: [Activity.Bike], andTypes: [ActivityType.All], andUnit: WorkoutProperty.tss.unit()!)
    }
    @objc dynamic var bikeTSB: Double{
        return metricValue(forActivity: Activity.Bike, andMetric: Unit.TSB)
    }

    @objc dynamic var bikeWatts: Double{
        return weightedAverageOverWorkouts(forActivities: [Activity.Bike], andTypes: [ActivityType.All], andUnit: WorkoutProperty.watts.unit()!)
    }
    
    @objc dynamic var runATL: Double{
        return metricValue(forActivity: Activity.Run, andMetric: Unit.ATL)
    }
    
    @objc dynamic var runCTL: Double{
        return metricValue(forActivity: Activity.Run, andMetric: Unit.CTL)
    }
    
    @objc dynamic var runAscentFeet: Double{
        return runAscentMetres * Constant.FeetPerMetre.rawValue
    }
    @objc dynamic var runAscentMetres: Double{
        return sumOverWorkouts(forActivities: [Activity.Run], andTypes: [ActivityType.All], andUnit: WorkoutProperty.ascentMetres.unit()!)
    }
    @objc dynamic var runHours: Double{
        return runSeconds / Constant.SecondsPerHour.rawValue
    }
    @objc dynamic var runHR: Double{
        return weightedAverageOverWorkouts(forActivities: [Activity.Run], andTypes: [ActivityType.All], andUnit: WorkoutProperty.hr.unit()!)
    }
    @objc dynamic var runKJ: Double{
        return sumOverWorkouts(forActivities: [Activity.Run], andTypes: [ActivityType.All], andUnit: WorkoutProperty.kj.unit()!)
    }
    @objc dynamic var runKM: Double{
        return sumOverWorkouts(forActivities: [Activity.Run], andTypes: [ActivityType.All], andUnit: WorkoutProperty.km.unit()!)
    }
    @objc dynamic var runMinutes: Double{
        return runSeconds / Constant.SecondsPerMinute.rawValue
    }
    @objc dynamic var runSeconds: Double{
        return sumOverWorkouts(forActivities: [Activity.Run], andTypes: [ActivityType.All], andUnit: WorkoutProperty.seconds.unit()!)
    }
    @objc dynamic var runTSS: Double{
        return sumOverWorkouts(forActivities: [Activity.Run], andTypes: [ActivityType.All], andUnit: WorkoutProperty.tss.unit()!)
    }
    @objc dynamic var runTSB: Double{
        return metricValue(forActivity: Activity.Run, andMetric: Unit.TSB)
    }
    @objc dynamic var runWatts: Double{
        return weightedAverageOverWorkouts(forActivities: [Activity.Run], andTypes: [ActivityType.All], andUnit: WorkoutProperty.watts.unit()!)
    }
    
    @objc dynamic var allAscentFeet: Double{
        return allAscentMetres * Constant.FeetPerMetre.rawValue
    }
    @objc dynamic var allAscentMetres: Double{
        return sumOverWorkouts(forActivities: Activity.allActivities, andTypes: [ActivityType.All], andUnit: WorkoutProperty.ascentMetres.unit()!)
    }
    @objc dynamic var allHours: Double{
        return allSeconds / Constant.SecondsPerHour.rawValue
    }
    @objc dynamic var allKJ: Double{
        return sumOverWorkouts(forActivities: Activity.allActivities, andTypes: [ActivityType.All], andUnit: WorkoutProperty.kj.unit()!)
    }
    @objc dynamic var allKM: Double{
        return sumOverWorkouts(forActivities: Activity.allActivities, andTypes: [ActivityType.All], andUnit: WorkoutProperty.km.unit()!)
    }
    @objc dynamic var allMinutes: Double{
        return allSeconds / Constant.SecondsPerMinute.rawValue
    }
    @objc dynamic var allSeconds: Double{
        return sumOverWorkouts(forActivities: Activity.allActivities, andTypes: [ActivityType.All], andUnit: WorkoutProperty.seconds.unit()!)
    }
    @objc dynamic var allTSS: Double{
        return sumOverWorkouts(forActivities: Activity.allActivities, andTypes: [ActivityType.All], andUnit: WorkoutProperty.tss.unit()!)
    }
    
    @objc dynamic var allATL: Double{
        return swimATL + bikeATL + runATL + gymATL + walkATL + otherATL
    }
    
    @objc dynamic var allCTL: Double{
        return swimCTL + bikeCTL + runCTL + gymCTL + walkCTL + otherCTL
    }
    
    @objc dynamic var allTSB: Double{
        return allCTL - allATL
    }
    
    @objc dynamic var gymATL: Double{
        return metricValue(forActivity: Activity.Gym, andMetric: Unit.ATL)
    }
    
    @objc dynamic var gymCTL: Double{
        return metricValue(forActivity: Activity.Gym, andMetric: Unit.CTL)
    }
    
    @objc dynamic var gymTSB: Double{
        return metricValue(forActivity: Activity.Gym, andMetric: Unit.TSB)
    }
    
    @objc dynamic var walkATL: Double{
        return metricValue(forActivity: Activity.Walk, andMetric: Unit.ATL)
    }
    
    @objc dynamic var walkCTL: Double{
        return metricValue(forActivity: Activity.Walk, andMetric: Unit.CTL)
    }
    
    @objc dynamic var walkTSB: Double{
        return metricValue(forActivity: Activity.Walk, andMetric: Unit.TSB)
    }
    
    @objc dynamic var otherATL: Double{
        return metricValue(forActivity: Activity.Other, andMetric: Unit.ATL)
    }
    
    @objc dynamic var otherCTL: Double{
        return metricValue(forActivity: Activity.Other, andMetric: Unit.CTL)
    }
    
    @objc dynamic var otherTSB: Double{
        return metricValue(forActivity: Activity.Other, andMetric: Unit.TSB)
    }
    
    @objc dynamic var kg: Double{
        return CoreDataStackSingleton.shared.getWeightAndFat(forDay: self.date!, andTrainingDiary: self.trainingDiary! ).weight
    }
    
    @objc dynamic var lbs: Double{
        return kg * Constant.LbsPerKg.rawValue
    }
    
    @objc dynamic var fatPercent: Double{
        return CoreDataStackSingleton.shared.getWeightAndFat(forDay: self.date!, andTrainingDiary: self.trainingDiary!).fatPercentage
    }
    @objc dynamic var restingHR: Int16{
        return CoreDataStackSingleton.shared.getRestingHeartRate(forDay: self.date!)
    }
    @objc dynamic var numberOfWorkouts: Int{
        if let w = workouts{
            return (w.count)
        }else{
            return 0
        }
    }
    @objc dynamic var pressUpReps: Double{
        return sumOverWorkouts(forActivities: [Activity.Gym], andTypes: [ActivityType.PressUp], andUnit: WorkoutProperty.reps.unit()!)
    }
    
    //MARK: - utility functions

    public func isTomorrow(day: Day) -> Bool{
        if let thisDaysDate = date{
            if let compareDate = day.date{
                return thisDaysDate.isTomorrow(day: compareDate)
            }
        }
        return false
    }

    public func isYesterday(day: Day) -> Bool{
        if let thisDaysDate = date{
            if let compareDate = day.date{
                return thisDaysDate.isYesterday(day: compareDate)
            }
        }
        return false
    }


    func setMetricValue(forActivity a: Activity, andMetric m: Unit, toValue v:Double){
        if let metric = metric(forActivity: a, andMetric: m){
            metric.value = v
        }
    }

    //MARK:- private
    
    private func metricValue(forActivity a: Activity, andMetric m: Unit ) -> Double{
        if let result = metricValuesDictionary()[Metric.key(forActivity: a, andUnit: m)]{
            return result
        }
        return 0.0
    }
    
    private func metric(forActivity a: Activity, andMetric m: Unit) -> Metric?{
        return metricDictionary()[Metric.key(forActivity: a, andUnit: m)]
    }

    private func metricDictionary() -> [String:Metric]{
        var result: [String:Metric] = [:]
        if let metricSet = metrics{
            for e in metricSet{
                if let element = e as? Metric{
                    result[element.uniqueKey] = element
                }
            }
        }
        return result
    }
    
    private func metricValuesDictionary() -> [String:Double]{
        var result: [String:Double] = [:]
        if let metricSet = metrics{
            for e in metricSet{
                if let element = e as? Metric{
                    result[element.uniqueKey] = element.value
                }
            }
        }
        return result
    }
    
    private func sumOverWorkouts(forActivities activities: [Activity], andTypes types: [ActivityType], andUnit unit: Unit) -> Double{
        var sum = 0.0
        for w in getWorkouts(){
            sum += w.valueFor(activities, types, unit)
        }
        return sum
    }

    private func recursiveAdd(toDate d: Date, activity a: Activity, activityType at: ActivityType, unit u: Unit) -> Double{
        var result = self.valueFor(activity: a, activityType: at, unit: u)
        if self.date!.isSameDate(asDate: d){
            return result
        }else{
            if let y = yesterday{
                result += y.recursiveAdd(toDate: d, activity: a, activityType: at, unit: u)
            }else{
                return result
            }
        }
        return result
    }
    
    private func weightedAverageOverWorkouts(forActivities activities: [Activity], andTypes types: [ActivityType], andUnit unit: Unit) ->  Double{
        var weighting = 0.0
        var weightedSum = 0.0
        for w in getWorkouts(){
            let value = w.valueFor(activities, types, unit)
            let weight = w.valueFor(activities, types, Unit.Seconds)
            if (value > 0.0){
                weighting += weight
                weightedSum += value*weight
            }
        }
        if(weighting>0){
            return weightedSum / weighting
        }else{
            return 0.0
        }
    }
    
    private func getWorkouts() -> [Workout]{
        if let array = workouts?.allObjects{
            return array as! [Workout]
        }else{
            return []
        }
    }
    

    
}
