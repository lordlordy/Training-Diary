//
//  Day+Extension.swift
//  Training Diary
//
//  Created by Steven Lord on 07/10/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Foundation

extension Day: TrainingDiaryValues{
    
    
    /* We do not want this to fail as when requesting a value for a particular combination of activity, type and unit a valid answer is zero. For example: if this gets asked what the swim squad ascent is then the correct answer is zero.
    */
    func valueFor(activity a: Activity?, activityType at: ActivityType? = nil, equipment e: Equipment? = nil, unit u: Unit) -> Double{
        let ALL = ConstantString.EddingtonAll.rawValue
        return valueFor(activity: a?.name ?? ALL, activityType: at?.name ?? ALL, equipment: e?.name ?? ALL, unit: u)
    }

    func valueFor(activity: String, activityType: String, equipment: String, unit: Unit) -> Double{
        var result = 0.0
        if !unit.isActivityBased{
            //have a day based unit (eg fatigue, sleep, restingHR)
            return value(forKey: unit.rawValue) as! Double
        }
        
        
        if activityType == ConstantString.EddingtonAll.rawValue && equipment == ConstantString.EddingtonAll.rawValue{
            //this is small optimisation in case a simple calculated propery is available for this.
            //Note that if no value is available we'll drop through this to the generic method
            if  activity == ConstantString.EddingtonAll.rawValue{
                //no activity ... so asking for all
                if let value = self.value(forKey: unit.allKey){
                    return value as! Double
                }
            }else{
                if let value = self.value(forKey: activity.lowercased() + unit.rawValue){
                    return value as! Double
                }
            }
        }
        if unit.summable{
            result = sumOverWorkouts(activity: activity, activityType : activityType, equipment: equipment, unit: unit)
        }else{
            result = weightedAverageOverWorkouts(activity: activity, activityType: activityType, equipment: equipment, unit: unit)
        }
        return result
    }
    
    /* Over ridden this to avoid exceptions being fired if ask for a key that doesn't exist. Instead return nil.
     This allows me to check for value. Main reason is method valueFor(activity:,activityType:unit:)
 */
    public override func value(forUndefinedKey key: String) -> Any? {
        return nil
    }
    
    //MARK: - TrainingDiaryValues implementation
    
    func valuesFor(activity a: String, activityType at: String, equipment e: String, period p: Period, unit u: Unit, from: Date? = nil, to: Date? = nil) -> [(date: Date, value: Double)]{
        var v: Double = 0.0
        switch p{
        case .Day:
            v = valueFor(activity: a, activityType: at, equipment: e, unit: u)
        case .Week:
            if self.date!.isEndOfWeek(){
                v = valuesFor( activity: a, activityType: at, equipment: e, period: Period.rWeek, unit: u)[0].value
            }
        case .Month:
            if self.date!.isEndOfMonth(){
                v = valuesFor( activity: a, activityType: at, equipment: e, period: Period.rMonth, unit: u)[0].value
            }
        case .Year:
            if self.date!.isEndOfYear(){
                v = valuesFor( activity: a, activityType: at, equipment: e, period: Period.rYear, unit: u)[0].value
            }
        case .WeekToDate:
            v = recursiveAdd(toDate: self.date!.startOfWeek(), activity: a, activityType: at, equipment: e, unit: u)
        case .MonthToDate:
            v = recursiveAdd(toDate: self.date!.startOfMonth(), activity: a, activityType: at, equipment: e, unit: u)
        case .YearToDate:
            v = recursiveAdd(toDate: self.date!.startOfYear(), activity: a, activityType: at, equipment: e, unit: u)
        case .rWeek:
            v = recursiveAdd(toDate: self.date!.startOfRWeek(), activity: a, activityType: at, equipment: e, unit: u)
        case .rMonth:
            v = recursiveAdd(toDate: self.date!.startOfRMonth(), activity: a, activityType: at, equipment: e, unit: u)
        case .rYear:
            v = recursiveAdd(toDate: self.date!.startOfRYear(), activity: a, activityType: at, equipment: e, unit: u)
        case .Lifetime:
            v = recursiveAdd(toDate: self.trainingDiary!.firstDayOfDiary, activity: a, activityType: at, equipment: e, unit: u)
        case .Adhoc:
            v = 0.0
        }
        return [(date!,v)]
    }
    
    func valuesFor(activity a: Activity? = nil, activityType at: ActivityType? = nil , equipment e: Equipment? = nil, period p: Period, unit u: Unit, from: Date? = nil, to: Date? = nil) -> [(date: Date, value: Double)]{
        let ALL = ConstantString.EddingtonAll.rawValue
        return valuesFor(activity: a?.name ?? ALL, activityType: at?.name ?? ALL, equipment: e?.name ?? ALL, period: p, unit: u, from: from, to: to)
    }
    
    func valuesAreForTrainingDiary() -> TrainingDiary { return trainingDiary! }
    
    //MARK: - Core Data dependent key values
    
    /*This is the method that needs implementing to ensure calculated properties update when the properties
    they depend on change.
     */
    override public class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String>{
        let keyPaths = super.keyPathsForValuesAffectingValue(forKey: key)
        switch key {
        case DayCalculatedProperty.numberOfWorkouts.rawValue:
            return keyPaths.union(Set([DayProperty.workouts.rawValue]))
        default:
            return keyPaths
        }
    }

    
    //MARK: - Calculated properties - these are for display in GUI

    @objc dynamic var swimATL: Double{
//        return metricValue(forActivity: ActivityEnum.Swim, andMetric: Unit.ATL)
        return 12.345
    }

    @objc dynamic var swimCTL: Double{
//        return metricValue(forActivity: ActivityEnum.Swim, andMetric: Unit.CTL)
  return 12.345
    }

    @objc dynamic var swimHours: Double{
        return swimSeconds / Constant.SecondsPerHour.rawValue
    }
 
    @objc dynamic var swimKJ: Double{
        return sumOverWorkouts(activity: activitySwim().name!, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, unit: WorkoutProperty.kj.unit()!)
    }
    @objc dynamic var swimKM: Double{
        return sumOverWorkouts(activity: activitySwim().name!, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, unit: WorkoutProperty.km.unit()!)
    }
    @objc dynamic var swimMinutes: Double{
        return swimSeconds / Constant.SecondsPerMinute.rawValue
    }
    @objc dynamic var swimSeconds: Double{
        return sumOverWorkouts(activity: activitySwim().name!, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, unit: WorkoutProperty.seconds.unit()!)
    }
    @objc dynamic var swimTSB: Double{
        return 12.345
        //return metricValue(forActivity: ActivityEnum.Swim, andMetric: Unit.TSB)
    }
    @objc dynamic var swimTSS: Double{
        return sumOverWorkouts(activity: activitySwim().name!, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, unit: WorkoutProperty.tss.unit()!)
    }
    @objc dynamic var swimWatts: Double{
        return weightedAverageOverWorkouts(activity: activitySwim().name!, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, unit: WorkoutProperty.watts.unit()!)
    }
    
    @objc dynamic var bikeATL: Double{
        return 12.345
        //return metricValue(forActivity: ActivityEnum.Bike, andMetric: Unit.ATL)
    }
    
    @objc dynamic var bikeCTL: Double{
        return 12.345
        //return metricValue(forActivity: ActivityEnum.Bike, andMetric: Unit.CTL)
    }
    
    @objc dynamic var bikeAscentFeet: Double{
        return bikeAscentMetres * Constant.FeetPerMetre.rawValue
    }
    @objc dynamic var bikeAscentMetres: Double{
        return sumOverWorkouts(activity: activityBike().name!, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, unit: WorkoutProperty.ascentMetres.unit()!)
    }
    @objc dynamic var bikeHours: Double{
        return bikeSeconds / Constant.SecondsPerHour.rawValue
    }
    @objc dynamic var bikeHR: Double{
        return weightedAverageOverWorkouts(activity: activityBike().name!, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, unit: WorkoutProperty.hr.unit()!)
    }
    @objc dynamic var bikeKJ: Double{
        return sumOverWorkouts(activity: activityBike().name!, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, unit: WorkoutProperty.kj.unit()!)
    }
    @objc dynamic var bikeKM: Double{
        return sumOverWorkouts(activity: activityBike().name!, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, unit: WorkoutProperty.km.unit()!)
    }
    @objc dynamic var bikeMinutes: Double{
        return bikeSeconds / Constant.SecondsPerMinute.rawValue
    }
    @objc dynamic var bikeSeconds: Double{
        return sumOverWorkouts(activity: activityBike().name!, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, unit: WorkoutProperty.seconds.unit()!)
    }
    @objc dynamic var bikeTSS: Double{
        return sumOverWorkouts(activity: activityBike().name!, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, unit: WorkoutProperty.tss.unit()!)
    }
    @objc dynamic var bikeTSB: Double{
        return 12.345
        //return metricValue(forActivity: ActivityEnum.Bike, andMetric: Unit.TSB)
    }

    @objc dynamic var bikeWatts: Double{
        return weightedAverageOverWorkouts(activity: activityBike().name!, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, unit: WorkoutProperty.watts.unit()!)
    }
    
    @objc dynamic var runATL: Double{
        return 12.345
        //return metricValue(forActivity: ActivityEnum.Run, andMetric: Unit.ATL)
    }
    
    @objc dynamic var runCTL: Double{
        return 12.345
        //return metricValue(forActivity: ActivityEnum.Run, andMetric: Unit.CTL)
    }
    
    @objc dynamic var runAscentFeet: Double{
        return runAscentMetres * Constant.FeetPerMetre.rawValue
    }
    @objc dynamic var runAscentMetres: Double{
        return sumOverWorkouts(activity: activityRun().name!, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, unit: WorkoutProperty.ascentMetres.unit()!)
    }
    @objc dynamic var runHours: Double{
        return runSeconds / Constant.SecondsPerHour.rawValue
    }
    @objc dynamic var runHR: Double{
        return weightedAverageOverWorkouts(activity: activityRun().name!, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, unit: WorkoutProperty.hr.unit()!)
    }
    @objc dynamic var runKJ: Double{
        return sumOverWorkouts(activity: activityRun().name!, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, unit: WorkoutProperty.kj.unit()!)
    }
    @objc dynamic var runKM: Double{
        return sumOverWorkouts(activity: activityRun().name!, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, unit: WorkoutProperty.km.unit()!)
    }
    @objc dynamic var runMinutes: Double{
        return runSeconds / Constant.SecondsPerMinute.rawValue
    }
    @objc dynamic var runSeconds: Double{
        return sumOverWorkouts(activity: activityRun().name!, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, unit: WorkoutProperty.seconds.unit()!)
    }
    @objc dynamic var runTSS: Double{
        return sumOverWorkouts(activity: activityRun().name!, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, unit: WorkoutProperty.tss.unit()!)
    }
    @objc dynamic var runTSB: Double{
        return 12.345
        //return metricValue(forActivity: ActivityEnum.Run, andMetric: Unit.TSB)
    }
    @objc dynamic var runWatts: Double{
        return weightedAverageOverWorkouts(activity: activityRun().name!, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, unit: WorkoutProperty.watts.unit()!)
    }
    
    @objc dynamic var allAscentFeet: Double{
        return allAscentMetres * Constant.FeetPerMetre.rawValue
    }
    @objc dynamic var allAscentMetres: Double{
        return sumOverWorkouts(activity: ConstantString.EddingtonAll.rawValue, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue,unit: WorkoutProperty.ascentMetres.unit()!)
    }
    @objc dynamic var allHours: Double{
        return allSeconds / Constant.SecondsPerHour.rawValue
    }
    @objc dynamic var allKJ: Double{
        return sumOverWorkouts(activity: ConstantString.EddingtonAll.rawValue, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue,unit: WorkoutProperty.kj.unit()!)
    }
    @objc dynamic var allKM: Double{
        return sumOverWorkouts(activity: ConstantString.EddingtonAll.rawValue, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue,unit: WorkoutProperty.km.unit()!)
    }
    @objc dynamic var allMinutes: Double{
        return allSeconds / Constant.SecondsPerMinute.rawValue
    }
    @objc dynamic var allSeconds: Double{
        return sumOverWorkouts(activity: ConstantString.EddingtonAll.rawValue, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue,unit: WorkoutProperty.seconds.unit()!)
    }
    @objc dynamic var allTSS: Double{
        return sumOverWorkouts(activity: ConstantString.EddingtonAll.rawValue, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, unit: WorkoutProperty.tss.unit()!)
    }
    
    @objc dynamic var allATL: Double{
        return 12.345
    }
    
    @objc dynamic var allCTL: Double{
        return 12.345 * 2.0
    }
    
    @objc dynamic var allTSB: Double{
        return allCTL - allATL
    }
    
    @objc dynamic var gymATL: Double{
        return 12.345
        // return metricValue(forActivity: ActivityEnum.Gym, andMetric: Unit.ATL)
    }
    
    @objc dynamic var gymCTL: Double{
        return 12.345
        //return metricValue(forActivity: ActivityEnum.Gym, andMetric: Unit.CTL)
    }
    
    @objc dynamic var gymTSB: Double{
        return 12.345
        //return metricValue(forActivity: ActivityEnum.Gym, andMetric: Unit.TSB)
    }
    


    
    @objc dynamic var kg: Double{
        if let td = trainingDiary{
            return td.kg(forDate: self.date!)
        }
        return 0.0
    }
    
    @objc dynamic var lbs: Double{
        return kg * Constant.LbsPerKg.rawValue
    }
    
    @objc dynamic var fatPercent: Double{
        if let td = trainingDiary{
            return td.fatPercentage(forDate: self.date!)
        }
        return 0.0
    }
    @objc dynamic var restingHR: Int{
        if let td = trainingDiary{
            return td.restingHeartRate(forDate: self.date!)
        }
        return 0
    }
    
    @objc dynamic var numberOfWorkouts: Int{
        if let w = workouts{
            return (w.count)
        }else{
            return 0
        }
    }
    @objc dynamic var pressUpReps: Double{
        return 12.345
        //return sumOverWorkouts(forActivities: [ActivityEnum.Gym], andTypes: [ActivityTypeEnum.PressUp], andUnit: WorkoutProperty.reps.unit()!)
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
    
    private func sumOverWorkouts(activity a: String, activityType at: String, equipment e: String,  unit: Unit) -> Double{
        var sum = 0.0
        for w in getWorkouts(){
            sum += w.valuesFor(activity: a, activityType: at, equipment: e, period: Period.Day, unit: unit)[0].value
        }
        return sum
    }

    private func recursiveAdd(toDate d: Date, activity a: String, activityType at: String, equipment e: String, unit u: Unit) -> Double{
        var result = self.valuesFor(activity: a, activityType: at, equipment: e, period: Period.Day, unit: u)[0].value
        if self.date!.isSameDate(asDate: d){
            return result
        }else{
            if let y = yesterday{
                result += y.recursiveAdd(toDate: d, activity: a, activityType: at, equipment: e, unit: u)
            }else{
                return result
            }
        }
        return result
    }
    
    private func weightedAverageOverWorkouts( activity a: String, activityType at: String, equipment e: String,  unit u: Unit) ->  Double{
        var weighting = 0.0
        var weightedSum = 0.0
        for w in getWorkouts(){
            let value = w.valuesFor(activity: a, activityType: at, equipment: e, period: Period.Day, unit: u)[0].value
            let weight = w.valuesFor(activity: a, activityType: at, equipment: e, period: Period.Day, unit: Unit.Seconds)[0].value
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
    
    private func activitySwim() ->  Activity{ return trainingDiary!.activity(forString: FixedActivity.Swim.rawValue)! }
    private func activityBike() ->  Activity{ return trainingDiary!.activity(forString: FixedActivity.Bike.rawValue)! }
    private func activityRun() ->   Activity{ return trainingDiary!.activity(forString: FixedActivity.Run.rawValue)! }
    private func activityGym() ->   Activity{ return trainingDiary!.activity(forString: FixedActivity.Gym.rawValue)! }

}
