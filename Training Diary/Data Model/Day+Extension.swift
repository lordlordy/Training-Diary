//
//  Day+Extension.swift
//  Training Diary
//
//  Created by Steven Lord on 07/10/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Foundation

extension Day: TrainingDiaryValues, PeriodNode{

    
    
    /* We do not want this to fail as when requesting a value for a particular combination of activity, type and unit a valid answer is zero. For example: if this gets asked what the swim squad ascent is then the correct answer is zero.
    */
    func valueFor(dayType dt: DayType?, activity a: Activity?, activityType at: ActivityType? = nil, equipment e: Equipment? = nil, unit u: Unit) -> Double{
        let ALL = ConstantString.EddingtonAll.rawValue
        return valueFor(dayType: dt?.rawValue ?? ALL, activity: a?.name ?? ALL, activityType: at?.name ?? ALL, equipment: e?.name ?? ALL, unit: u)
    }

    func valueFor(dayType dt: String, activity a: String, activityType at: String, equipment e: String, unit u: Unit) -> Double{
        var result = 0.0
        
        if (dt == ConstantString.EddingtonAll.rawValue || dt == type || dt == date?.dayOfWeekName()){
            if !u.isActivityBased{
                //have a day based unit (eg fatigue, sleep, restingHR)
                if u.isDerived(){
                    if let d = u.dataForDerivation(){
                        let baseValue = value(forKey: d.unit.rawValue) as! Double
                        return baseValue * d.multiple.rawValue
                    }
                }else{
                    return value(forKey: u.rawValue) as! Double
                }
            }
            
            
            if at == ConstantString.EddingtonAll.rawValue && e == ConstantString.EddingtonAll.rawValue{
                //this is small optimisation in case a simple calculated propery is available for this.
                //Note that if no value is available we'll drop through this to the generic method
                if  a == ConstantString.EddingtonAll.rawValue{
                    //no activity ... so asking for all
                    if let value = self.value(forKey: u.allKey){
                        return value as! Double
                    }
                }else{
                    if let value = self.value(forKey: a.lowercased() + u.rawValue){
                        return value as! Double
                    }
                }
            }
            //check for metric here as they are held by the Day not the workout
            if u.isMetric{
                return metricValue(forActivity: a, andMetric: u)
            }else if u.summable{
                result = sumOverWorkouts(dayType: dt, activity: a, activityType : at, equipment: e, unit: u)
            }else{
                result = weightedAverageOverWorkouts(dayType: dt, activity: a, activityType: at, equipment: e, unit: u)
            }
        }
        
        return result
    }
    
    /* Over ridden this to avoid exceptions being fired if ask for a key that doesn't exist. Instead return nil.
     This allows me to check for value. Main reason is method valueFor(activity:,activityType:unit:)
 */
    public override func value(forUndefinedKey key: String) -> Any? {
        return nil
    }
    
    //MARK: - PeriodNode implementation
    @objc var name: String { return String(date!.dayOfMonthAndDayName()) }
    @objc var isLeaf: Bool { return children.count == 0 }
    @objc var isRoot: Bool { return false}
    @objc var isWorkout: Bool { return false}
    @objc var children: [PeriodNode] { return getWorkouts() }
    @objc var childCount: Int { return children.count }
    @objc var totalKM: Double { return allKM}
    @objc var totalSeconds: TimeInterval { return allSeconds }
    @objc var totalTSS: Double { return allTSS }
    @objc var fromDate: Date { return date! }
    @objc var toDate: Date { return date! }
    func inPeriod(_ p: PeriodNode) -> Bool{
        return (p.fromDate <= fromDate) && (p.toDate >= toDate)
    }
    func child(forName n: String) -> PeriodNode?{
        for node in children{
            if node.name == n{
                return node
            }
        }
        return nil
    }
    func add(child: PeriodNode) {
        if let w = child as? Workout{
            mutableSetValue(forKey: DayProperty.workouts.rawValue).add(w)
        }
    }
    
    //MARK: - TrainingDiaryValues implementation
    
    func valuesFor(dayType dt: String, activity a: String, activityType at: String, equipment e: String, period p: Period, unit u: Unit, from: Date? = nil, to: Date? = nil) -> [(date: Date, value: Double)]{
        
        var v: Double = 0.0
        
        
        if (dt == ConstantString.EddingtonAll.rawValue || dt == self.type || dt == date?.dayOfWeekName()){
            switch p{
            case .Workout: return workoutValuesMatching(dayType: dt, activity: a, activityType: at, equipment: e, period: p, unit: u)
            case .Day:
                v = valueFor(dayType: dt, activity: a, activityType: at, equipment: e, unit: u)
            case .Week:
                if self.date!.isEndOfWeek(){ // this is checking for Sunday
                    v = valuesFor(dayType: dt, activity: a, activityType: at, equipment: e, period: Period.rWeek, unit: u)[0].value
                }
            case .WeekTue:
                if self.date!.isMonday(){
                    v = valuesFor( dayType: dt, activity: a, activityType: at, equipment: e, period: Period.rWeek, unit: u)[0].value
                }
            case .WeekWed:
                if self.date!.isTuesday(){
                    v = valuesFor( dayType: dt, activity: a, activityType: at, equipment: e, period: Period.rWeek, unit: u)[0].value
                }
            case .WeekThu:
                if self.date!.isWednesday(){
                    v = valuesFor( dayType: dt, activity: a, activityType: at, equipment: e, period: Period.rWeek, unit: u)[0].value
                }
            case .WeekFri:
                if self.date!.isThursday(){
                    v = valuesFor( dayType: dt, activity: a, activityType: at, equipment: e, period: Period.rWeek, unit: u)[0].value
                }
            case .WeekSat:
                if self.date!.isFriday(){
                    v = valuesFor( dayType: dt, activity: a, activityType: at, equipment: e, period: Period.rWeek, unit: u)[0].value
                }
            case .WeekSun:
                if self.date!.isSaturday(){
                    v = valuesFor( dayType: dt, activity: a, activityType: at, equipment: e, period: Period.rWeek, unit: u)[0].value
                }
            case .Month:
                if self.date!.isEndOfMonth(){
                    v = valuesFor( dayType: dt, activity: a, activityType: at, equipment: e, period: Period.rMonth, unit: u)[0].value
                }
            case .Year:
                if self.date!.isEndOfYear(){
                    v = valuesFor( dayType: dt, activity: a, activityType: at, equipment: e, period: Period.rYear, unit: u)[0].value
                }
            case .WeekToDate:
                v = recursiveAdd(toDate: self.date!.startOfWeek(), dayType: dt, activity: a, activityType: at, equipment: e, unit: u)
            case .WTDTue:
                v = recursiveAdd(toDate: self.date!.startOfWeek(firstDayOfWeek: WeekDay.gregorianTuesday), dayType: dt, activity: a, activityType: at, equipment: e, unit: u)
            case .WTDWed:
                v = recursiveAdd(toDate: self.date!.startOfWeek(firstDayOfWeek: WeekDay.gregorianWednesday), dayType: dt, activity: a, activityType: at, equipment: e, unit: u)
            case .WTDThu:
                v = recursiveAdd(toDate: self.date!.startOfWeek(firstDayOfWeek: WeekDay.gregorianThursday), dayType: dt, activity: a, activityType: at, equipment: e, unit: u)
            case .WTDFri:
                v = recursiveAdd(toDate: self.date!.startOfWeek(firstDayOfWeek: WeekDay.gregorianFriday), dayType: dt, activity: a, activityType: at, equipment: e, unit: u)
            case .WTDSat:
                v = recursiveAdd(toDate: self.date!.startOfWeek(firstDayOfWeek: WeekDay.gregorianSaturday), dayType: dt, activity: a, activityType: at, equipment: e, unit: u)
            case .WTDSun:
                v = recursiveAdd(toDate: self.date!.startOfWeek(firstDayOfWeek: WeekDay.gregorianSunday), dayType: dt, activity: a, activityType: at, equipment: e, unit: u)
            case .MonthToDate:
                v = recursiveAdd(toDate: self.date!.startOfMonth(), dayType: dt, activity: a, activityType: at, equipment: e, unit: u)
            case .YearToDate:
                v = recursiveAdd(toDate: self.date!.startOfYear(), dayType: dt, activity: a, activityType: at, equipment: e, unit: u)
            case .rWeek:
                v = recursiveAdd(toDate: self.date!.startOfRWeek(), dayType: dt, activity: a, activityType: at, equipment: e, unit: u)
            case .rMonth:
                v = recursiveAdd(toDate: self.date!.startOfRMonth(), dayType: dt, activity: a, activityType: at, equipment: e, unit: u)
            case .rYear:
                v = recursiveAdd(toDate: self.date!.startOfRYear(), dayType: dt, activity: a, activityType: at, equipment: e, unit: u)
            case .Lifetime:
                v = recursiveAdd(toDate: self.trainingDiary!.firstDayOfDiary, dayType: dt, activity: a, activityType: at, equipment: e, unit: u)
            case .Adhoc:
                v = 0.0
            }
        }
        

        return [(date!,v)]
    }
    
    func valuesFor(dayType dt: DayType?, activity a: Activity? = nil, activityType at: ActivityType? = nil , equipment e: Equipment? = nil, period p: Period, unit u: Unit, from: Date? = nil, to: Date? = nil) -> [(date: Date, value: Double)]{
        let ALL = ConstantString.EddingtonAll.rawValue
        return valuesFor(dayType: dt?.rawValue ?? ALL, activity: a?.name ?? ALL, activityType: at?.name ?? ALL, equipment: e?.name ?? ALL, period: p, unit: u, from: from, to: to)
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

    //this is for JSON serialisation
    @objc dynamic var iso8061DateString: String{
        return date!.iso8601Format()
    }
    
    //MARK: - Calculated properties - these are for display in GUI
    
    @objc dynamic var trainingDiaryName: String{ return trainingDiary?.name ?? "Missing"}
    
    @objc dynamic var dateString: String{ return date!.dateOnlyShorterString()}
    
    @objc dynamic var swimATL: Double{
        return metricValue(forActivity: FixedActivity.Swim.rawValue, andMetric: Unit.ATL)
    }

    @objc dynamic var swimCTL: Double{
        return metricValue(forActivity: FixedActivity.Swim.rawValue, andMetric: Unit.CTL)
    }

    @objc dynamic var swimHours: Double{
        return swimSeconds / Constant.SecondsPerHour.rawValue
    }
 
    @objc dynamic var swimKJ: Double{
        return sumOverWorkouts(dayType: ConstantString.EddingtonAll.rawValue, activity: activitySwim().name!, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, unit: WorkoutProperty.kj.unit()!)
    }
    @objc dynamic var swimKM: Double{
        return sumOverWorkouts(dayType: ConstantString.EddingtonAll.rawValue, activity: activitySwim().name!, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, unit: WorkoutProperty.km.unit()!)
    }
    @objc dynamic var swimMinutes: Double{
        return swimSeconds / Constant.SecondsPerMinute.rawValue
    }
    @objc dynamic var swimSeconds: Double{
        return sumOverWorkouts(dayType: ConstantString.EddingtonAll.rawValue, activity: activitySwim().name!, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, unit: WorkoutProperty.seconds.unit()!)
    }
    @objc dynamic var swimTSB: Double{
        return metricValue(forActivity: FixedActivity.Swim.rawValue, andMetric: Unit.TSB)
    }
    @objc dynamic var swimTSS: Double{
        return sumOverWorkouts(dayType: ConstantString.EddingtonAll.rawValue, activity: activitySwim().name!, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, unit: WorkoutProperty.tss.unit()!)
    }
    @objc dynamic var swimWatts: Double{
        return weightedAverageOverWorkouts(dayType: ConstantString.EddingtonAll.rawValue, activity: activitySwim().name!, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, unit: WorkoutProperty.watts.unit()!)
    }
    
    @objc dynamic var bikeATL: Double{
        return metricValue(forActivity: FixedActivity.Bike.rawValue, andMetric: Unit.ATL)
    }
    
    @objc dynamic var bikeCTL: Double{
        return metricValue(forActivity: FixedActivity.Bike.rawValue, andMetric: Unit.CTL)
    }
    
    @objc dynamic var bikeAscentFeet: Double{
        return bikeAscentMetres * Constant.FeetPerMetre.rawValue
    }
    @objc dynamic var bikeAscentMetres: Double{
        return sumOverWorkouts(dayType: ConstantString.EddingtonAll.rawValue, activity: activityBike().name!, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, unit: WorkoutProperty.ascentMetres.unit()!)
    }
    @objc dynamic var bikeHours: Double{
        return bikeSeconds / Constant.SecondsPerHour.rawValue
    }
    @objc dynamic var bikeHR: Double{
        return weightedAverageOverWorkouts(dayType: ConstantString.EddingtonAll.rawValue, activity: activityBike().name!, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, unit: WorkoutProperty.hr.unit()!)
    }
    @objc dynamic var bikeKJ: Double{
        return sumOverWorkouts(dayType: ConstantString.EddingtonAll.rawValue, activity: activityBike().name!, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, unit: WorkoutProperty.kj.unit()!)
    }
    @objc dynamic var bikeKM: Double{
        return sumOverWorkouts(dayType: ConstantString.EddingtonAll.rawValue, activity: activityBike().name!, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, unit: WorkoutProperty.km.unit()!)
    }
    @objc dynamic var bikeMinutes: Double{
        return bikeSeconds / Constant.SecondsPerMinute.rawValue
    }
    @objc dynamic var bikeSeconds: Double{
        return sumOverWorkouts(dayType: ConstantString.EddingtonAll.rawValue, activity: activityBike().name!, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, unit: WorkoutProperty.seconds.unit()!)
    }
    @objc dynamic var bikeTSS: Double{
        return sumOverWorkouts(dayType: ConstantString.EddingtonAll.rawValue, activity: activityBike().name!, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, unit: WorkoutProperty.tss.unit()!)
    }
    @objc dynamic var bikeTSB: Double{
        return metricValue(forActivity: FixedActivity.Bike.rawValue, andMetric: Unit.TSB)
    }

    @objc dynamic var bikeWatts: Double{
        return weightedAverageOverWorkouts(dayType: ConstantString.EddingtonAll.rawValue, activity: activityBike().name!, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, unit: WorkoutProperty.watts.unit()!)
    }
    
    @objc dynamic var runATL: Double{
        return metricValue(forActivity: FixedActivity.Run.rawValue, andMetric: Unit.ATL)
    }
    
    @objc dynamic var runCTL: Double{
        return metricValue(forActivity: FixedActivity.Run.rawValue, andMetric: Unit.CTL)
    }
    
    @objc dynamic var runAscentFeet: Double{
        return runAscentMetres * Constant.FeetPerMetre.rawValue
    }
    @objc dynamic var runAscentMetres: Double{
        return sumOverWorkouts(dayType: ConstantString.EddingtonAll.rawValue, activity: activityRun().name!, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, unit: WorkoutProperty.ascentMetres.unit()!)
    }
    @objc dynamic var runHours: Double{
        return runSeconds / Constant.SecondsPerHour.rawValue
    }
    @objc dynamic var runHR: Double{
        return weightedAverageOverWorkouts(dayType: ConstantString.EddingtonAll.rawValue, activity: activityRun().name!, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, unit: WorkoutProperty.hr.unit()!)
    }
    @objc dynamic var runKJ: Double{
        return sumOverWorkouts(dayType: ConstantString.EddingtonAll.rawValue, activity: activityRun().name!, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, unit: WorkoutProperty.kj.unit()!)
    }
    @objc dynamic var runKM: Double{
        return sumOverWorkouts(dayType: ConstantString.EddingtonAll.rawValue, activity: activityRun().name!, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, unit: WorkoutProperty.km.unit()!)
    }
    @objc dynamic var runMinutes: Double{
        return runSeconds / Constant.SecondsPerMinute.rawValue
    }
    @objc dynamic var runSeconds: Double{
        return sumOverWorkouts(dayType: ConstantString.EddingtonAll.rawValue, activity: activityRun().name!, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, unit: WorkoutProperty.seconds.unit()!)
    }
    @objc dynamic var runTSS: Double{
        return sumOverWorkouts(dayType: ConstantString.EddingtonAll.rawValue, activity: activityRun().name!, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, unit: WorkoutProperty.tss.unit()!)
    }
    @objc dynamic var runTSB: Double{
        return metricValue(forActivity: FixedActivity.Run.rawValue, andMetric: Unit.TSB)
    }
    @objc dynamic var runWatts: Double{
        return weightedAverageOverWorkouts(dayType: ConstantString.EddingtonAll.rawValue, activity: activityRun().name!, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, unit: WorkoutProperty.watts.unit()!)
    }
    
    @objc dynamic var allAscentFeet: Double{
        return allAscentMetres * Constant.FeetPerMetre.rawValue
    }
    @objc dynamic var allAscentMetres: Double{
        return sumOverWorkouts(dayType: ConstantString.EddingtonAll.rawValue, activity: ConstantString.EddingtonAll.rawValue, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue,unit: WorkoutProperty.ascentMetres.unit()!)
    }
    @objc dynamic var allHours: Double{
        return allSeconds / Constant.SecondsPerHour.rawValue
    }
    @objc dynamic var allKJ: Double{
        return sumOverWorkouts(dayType: ConstantString.EddingtonAll.rawValue, activity: ConstantString.EddingtonAll.rawValue, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue,unit: WorkoutProperty.kj.unit()!)
    }
    @objc dynamic var allKM: Double{
        return sumOverWorkouts(dayType: ConstantString.EddingtonAll.rawValue, activity: ConstantString.EddingtonAll.rawValue, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue,unit: WorkoutProperty.km.unit()!)
    }
    @objc dynamic var allMinutes: Double{
        return allSeconds / Constant.SecondsPerMinute.rawValue
    }
    @objc dynamic var allSeconds: Double{
        return sumOverWorkouts(dayType: ConstantString.EddingtonAll.rawValue, activity: ConstantString.EddingtonAll.rawValue, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue,unit: WorkoutProperty.seconds.unit()!)
    }
    @objc dynamic var allTSS: Double{
        return sumOverWorkouts(dayType: ConstantString.EddingtonAll.rawValue, activity: ConstantString.EddingtonAll.rawValue, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, unit: WorkoutProperty.tss.unit()!)
    }
    
    @objc dynamic var allATL: Double{
        return metricValue(forActivity: ConstantString.EddingtonAll.rawValue, andMetric: Unit.ATL)
    }
    
    @objc dynamic var allCTL: Double{
        return metricValue(forActivity: ConstantString.EddingtonAll.rawValue, andMetric: Unit.CTL)
    }
    
    @objc dynamic var allTSB: Double{
        return metricValue(forActivity: ConstantString.EddingtonAll.rawValue, andMetric: Unit.TSB)
    }
    
    @objc dynamic var gymATL: Double{
        return metricValue(forActivity: FixedActivity.Gym.rawValue, andMetric: Unit.ATL)
    }
    
    @objc dynamic var gymCTL: Double{
        return metricValue(forActivity: FixedActivity.Gym.rawValue, andMetric: Unit.CTL)
    }
    
    @objc dynamic var gymTSB: Double{
        return metricValue(forActivity: FixedActivity.Gym.rawValue, andMetric: Unit.TSB)
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
    @objc dynamic var restingHR: Double{
        if let td = trainingDiary{
            return td.restingHeartRate(forDate: self.date!)
        }
        return 0
    }
    
    @objc dynamic var restingSDNN: Double{
        if let td = trainingDiary{
            return td.restingSDNN(forDate: self.date!)
        }
        return 0.0
    }
    
    @objc dynamic var restingRMSSD: Double{
        if let td = trainingDiary{
            return td.restingRMSSD(forDate: self.date!)
        }
        return 0.0
    }
    
    @objc dynamic var numberOfWorkouts: Int{
        if let w = workouts{
            return (w.count)
        }else{
            return 0
        }
    }
    @objc dynamic var totalReps: Double{
        return sumOverWorkouts(dayType: ConstantString.EddingtonAll.rawValue, activity: FixedActivity.Gym.rawValue, activityType: ConstantString.EddingtonAll.rawValue, equipment: ConstantString.EddingtonAll.rawValue, unit: Unit.Reps)
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
        if let metric = metric(forActivity: a.name!, andMetric: m){
            metric.value = v
        }else{
            print("Unable to set metric \(m.rawValue) for \(String(describing: a.name)) for date \(date!.dateOnlyShorterString())")
        }
    }
    
    func metric(forActivity a: Activity, andMetric m: Unit) -> Metric?{
        return metric(forActivity: a.name!, andMetric: m)
    }


    //MARK:- private
    
    private func metricValue(forActivity a: String, andMetric m: Unit ) -> Double{
        if a == ConstantString.EddingtonAll.rawValue{
            // look for sum over all activities
            return sum(forMetric: m)
        }
        if let result = metricValuesDictionary()[Metric.key(forActivity: a, andUnit: m)]{
            return result
        }
        return 0.0
    }
    
    private func metric(forActivity a: String, andMetric m: Unit) -> Metric?{
        if let metric = metricDictionary()[Metric.key(forActivity: a, andUnit: m)]{
            return metric
        }else{
            //does exist so create and add the metric
            CoreDataStackSingleton.shared.populateMetricPlaceholders(forDay: self)
            return metricDictionary()[Metric.key(forActivity: a, andUnit: m)]
        }
    }
    
    private func sum(forMetric m: Unit) -> Double{
        var result = 0.0
        if m.isMetric {
            if let all = metrics?.allObjects as? [Metric]{
                let filter = all.filter({$0.name == m.rawValue})
                //figure out using reduce method eventually. for now:
//                result = filter.reduce(0.0) { (r, metric) -> Result in return r + metric.value }
                for f in filter{
                    result += f.value
                }
            }
        }
        return result
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
    
    private func sumOverWorkouts(dayType dt: String, activity a: String, activityType at: String, equipment e: String,  unit: Unit) -> Double{
        var sum = 0.0
        for w in getWorkouts(){
            sum += w.valuesFor(dayType: dt, activity: a, activityType: at, equipment: e, period: Period.Day, unit: unit)[0].value
        }
        return sum
    }

    private func recursiveAdd(toDate d: Date, dayType dt: String, activity a: String, activityType at: String, equipment e: String, unit u: Unit) -> Double{
        var result = self.valuesFor(dayType: dt, activity: a, activityType: at, equipment: e, period: Period.Day, unit: u)[0].value
        if self.date!.isSameDate(asDate: d){
            return result
        }else{
            if let y = yesterday{
                result += y.recursiveAdd(toDate: d, dayType: dt, activity: a, activityType: at, equipment: e, unit: u)
            }else{
                return result
            }
        }
        return result
    }
    
    private func weightedAverageOverWorkouts(dayType dt: String, activity a: String, activityType at: String, equipment e: String,  unit u: Unit) ->  Double{
        var weighting = 0.0
        var weightedSum = 0.0
        for w in getWorkouts(){
            let value = w.valuesFor(dayType: dt, activity: a, activityType: at, equipment: e, period: Period.Day, unit: u)[0].value
            let weight = w.valuesFor(dayType: dt, activity: a, activityType: at, equipment: e, period: Period.Day, unit: Unit.Seconds)[0].value
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

    private func workoutValuesMatching(dayType dt: String, activity a: String, activityType at: String, equipment e: String, period p: Period, unit u: Unit) -> [(date: Date, value: Double)]{
        // return for all workouts matching this.
        var result: [(date: Date, value: Double)] = []

        for w in getWorkouts(){
            let value = w.valuesFor(dayType: dt, activity: a, activityType: at, equipment: e, period: p, unit: u)
            if value[0].value > 0.0{
                result.append(value[0])
            }
        }
        
        return result
    }
    
}
