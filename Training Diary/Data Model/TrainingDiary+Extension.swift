//
//  TrainingDiary+Extension.swift
//  Training Diary
//
//  Created by Steven Lord on 08/11/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Foundation

/* class WorkoutHistory {
    var date: Date
    var workout: Workout
    var kmTD: Double
    var ascentMetresTD: Double
    var kjTD: Double
    var repsTD: Double
    var secondsTD: Double
    var tssTD: Double
    
    init(_ w: Workout){
        date = w.day!.date!
        workout = w
        kmTD = w.km
        ascentMetresTD = w.ascentMetres
        kjTD = w.kj
        repsTD = w.reps
        secondsTD = w.seconds
        tssTD = w.tss
    }
    
    func incrementFrom(previous: WorkoutHistory){
        kmTD = previous.kmTD + workout.km
        ascentMetresTD = previous.ascentMetresTD + workout.ascentMetres
        kjTD = previous.kjTD + workout.kj
        repsTD = previous.repsTD + workout.reps
        secondsTD = previous.secondsTD + workout.seconds
        tssTD = previous.tssTD + workout.tss
    }
 
    func printHistory(){
        print("\(date): km:\(kmTD) metres:\(ascentMetresTD) kj:\(kjTD) reps:\(repsTD) seconds:\(secondsTD) tss: \(tssTD)")
    }

    
}
*/
/*@objc class BikeHistory: NSObject{
    @objc dynamic var name: String
    @objc dynamic var isValid: Bool{
        return BikeName(rawValue: name) != nil
    }
    @objc dynamic var history: NSSet?
    
    override convenience init(){
        self.init(BikeName.IFSSX.rawValue)
    }
    
    init(_ name: String){
        self.name = name
    }
}
*/
extension TrainingDiary{
    
    //MARK: - for display in GUI summary
    @objc dynamic var totalBikeKM:  Double{ return total(forKey: "bikeKM") }
    @objc dynamic var totalSwimKM:  Double{ return total(forKey: "swimKM") }
    @objc dynamic var totalRunKM:   Double{ return total(forKey: "runKM") }
    @objc dynamic var totalSeconds: Double{ return total(forKey: "allSeconds")}
    @objc dynamic var totalTime: TimeInterval{ return TimeInterval(totalSeconds)}
    
    @objc dynamic var ltdEdNumCount: Int{
        return self.lTDEdNumbers?.count ?? 0
    }
    
    @objc dynamic var edNumCount: Int{
        return self.eddingtonNumbers?.count ?? 0
    }
    
    @objc dynamic var weightsCount: Int{
        return self.weights?.count ?? 0
    }
    
    @objc dynamic var physiologicalsCount: Int{
        return self.physiologicals?.count ?? 0
    }
    
    // don't think this really need @objc dynamic - check and remove
    @objc dynamic var firstDayOfDiary: Date{
        let days = ascendingOrderedDays()
        if days.count > 0{
            if let day = days[0].date{ return day }
        }
        return Date()
    }
    
    // don't think this really need @objc dynamic - check and remove
    @objc dynamic var lastDayOfDiary: Date{
        return latestDay()?.date ?? Date()
    }
    
    @objc dynamic var workouts: [Workout]{
        return CoreDataStackSingleton.shared.workouts(forTrainingDiary: self)
    }
    
    //MARK: - Validation functions
    func findDuplicates(){
        var results: [Date] = []
        if let allObjects = days?.allObjects{
            let days = allObjects as! [Day]
            let dates = days.map{$0.date!}.sorted(by: {$0 > $1})
            print(dates.count)
            var previousDate: Date?
            for d in dates{
                if previousDate != nil && d.isSameDate(asDate: previousDate!){
                    results.append(d)
                }
                previousDate = d
            }
            
        }
        print("\(results.count) duplicates found.")
        if results.count > 0{
            print("Dates are:")
            for r in results{
                print(r)
            }
            
        }
    
    }
    
    func findMissingYesterdayOrTomorrow(){
        var yesterdays:[Date] = []
        var tomorrows:[Date] = []
        var yesterday: Day?
        if let allDays = days?.allObjects as? [Day]{
            for d in allDays.sorted(by: {$0.date! < $1.date!}){
                if d.yesterday == nil{
                    yesterdays.append(d.date!)
                    if let y = yesterday{
                        if d.date!.isYesterday(day: y.date!){
                            print("Found yesterday for \(d.date!.dateOnlyString()) and its \(y.date!.dateOnlyString()). So fixing...")
                            d.yesterday = y
                            print("Fixed")
                        }
                    }
                }
                if d.tomorrow == nil{
                    tomorrows.append(d.date!)
                }
                yesterday = d
            }
        }
        print("\(yesterdays.count) days found without yesterday set")
        for r in yesterdays.sorted(){ print(r) }
        print("\(tomorrows.count) days found without tomorrow set")
        for r in tomorrows.sorted(){ print(r) }

    }
    
    //MARK: -
    
/*    func calculateBikeHistory(){
        let bikeWorkouts = CoreDataStackSingleton.shared.workouts(forActivity: ActivityEnum.Bike, andTrainingDiary: self)
        var results: [String:[WorkoutHistory]] = [:]
        for b in bikeWorkouts.sorted(by: {$0.day!.date! < $1.day!.date!}){
            if results[b.bike!] != nil{
                let lastHistory = results[b.bike!]![results[b.bike!]!.count - 1]
                results[b.bike!]!.append(createNextHistory(previous: lastHistory, workout: b))
            }else{
                results[b.bike!] = [createNextHistory( workout: b)]
            }
        }
        
        for r in results{
            print("\(r.key) workouts: \(r.value.count)")
            for i in r.value{
                print(i.printHistory())
            }
        }
        
    }
    */
    func connectWorkouts(forBike bike: Bike){
         CoreDataStackSingleton.shared.connectWorkouts(toBike: bike)
    }
    
    func uniqueActivityTypePairs() -> [String]{
        
        var result: [String] = []
        
        for a in ActivityEnum.allActivities{
            let workouts = CoreDataStackSingleton.shared.workouts(forActivity: a, andTrainingDiary: self)
            for w in workouts{
                var possibleValue: String = w.activity!
                possibleValue += ":"
                possibleValue += w.activityType!
                if possibleValue == "Swim:Road"{
                    print("\(possibleValue) - \(w.day!.date!.dateOnlyShorterString())")
                }
                if possibleValue == "Run:Solo"{
                    print("\(possibleValue) - \(w.day!.date!.dateOnlyShorterString())")
                }
                if !result.contains(possibleValue){
                    result.append(possibleValue)
                }
            }
        }
        return result
        
    }
    
    func activity(forString a: String) -> Activity?{
        let a = activitiesArray().filter({$0.name == a})
        if a.count == 1{
            return a[0]
        }
        return nil
    }
    
    func validActivityTypes(forActivityString a: String) -> [ActivityType]{
        if let activity = activity(forString: a){
            if let types = activity.activityTypes?.allObjects as? [ActivityType]{
                return types
            }
        }
        return []
    }
    
    func activitiesArray() -> [Activity]{
        if let a = activities{
            let result = a.allObjects as! [Activity]
            return result.sorted(by: {$0.name! < $1.name!})
        }
        return []
    }
    
    func bikeArray() -> [Bike]{
        if let b = bikes{
            return b.allObjects as! [Bike]
        }
        return []
    }
    
    func activeBikes() -> [Bike]{
        return bikeArray().filter({$0.active})
    }
    
    func orderedActiveBikes() -> [Bike]{
        return activeBikes().sorted(by: {$0.name! < $1.name!})
    }
    
    func bike(forName name: String) -> Bike?{
        let possibleBike = bikeArray().filter({$0.name == name})
        if possibleBike.count == 1{
            return possibleBike[0]
        }
        return nil
    }
    
    func latestDay() -> Day?{
        let days = ascendingOrderedDays()
        if days.count > 0{ return days[days.count-1] }
        return nil
    }
    
    func firstYear() -> Int{ return Calendar.current.dateComponents([.year], from: firstDayOfDiary).year! }
    func lastYear() -> Int{ return Calendar.current.dateComponents([.year], from: lastDayOfDiary).year! }
    
    func kgAscendingDateOrder() -> [(date: Date, value: Double)]{
        var result: [(date: Date, value: Double)] = []
        if let orderedWeights = weightsAscendingDateOrder(){
            for w in orderedWeights{
                result.append((w.fromDate!, w.kg))
            }
        }
        return result
    }
    
    func fatPercentageDateOrder() -> [(date: Date, value: Double)]{
        var result: [(date: Date, value: Double)] = []
        if let orderedWeights = weightsAscendingDateOrder(){
            for w in orderedWeights{
                result.append((w.fromDate!, w.fatPercent))
            }
        }
        return result
    }
    
    func sleepDateOrder() -> [(date: Date, value: Double)]{
        var result: [(date: Date, value: Double )] = []
        for d in ascendingOrderedDays(){
            result.append((d.date!, d.sleep))
        }
        return result
    }

    func motivationDateOrder() -> [(date: Date, value: Double)]{
        var result: [(date: Date, value: Double )] = []
        for d in ascendingOrderedDays(){
            result.append((d.date!, d.motivation))
        }
        return result
    }
    
    func fatigueDateOrder() -> [(date: Date, value: Double)]{
        var result: [(date: Date, value: Double )] = []
        for d in ascendingOrderedDays(){
            result.append((d.date!, d.fatigue))
        }
        return result
    }
    
    func hrDateOrder() -> [(date: Date, value: Double)]{
        var result: [(date: Date, value: Double)] = []
        if let orderedPhysios = physiologicalsAscendingDateOrder(){
            for o in orderedPhysios{
                result.append((o.fromDate!, o.restingHR))
            }
        }
        return result
    }
    
    func sdnnDateOrder() -> [(date: Date, value: Double)]{
        var result: [(date: Date, value: Double)] = []
        if let orderedPhysios = physiologicalsAscendingDateOrder(){
            for o in orderedPhysios{
                result.append((o.fromDate!, o.restingSDNN))
            }
        }
        return result
    }

    func rmssdDateOrder() -> [(date: Date, value: Double)]{
        var result: [(date: Date, value: Double)] = []
        if let orderedPhysios = physiologicalsAscendingDateOrder(){
            for o in orderedPhysios{
                result.append((o.fromDate!, o.restingRMSSD))
            }
        }
        return result
    }
    
    
    //MARK: - Getting values
    func getValues(forActivity activity: ActivityEnum, andActivityType activityType: ActivityTypeEnum, andPeriod period: Period, andUnit unit: Unit) -> [(date: Date, value:Double)]{
        return getValues(forActivity: activity, andActivityType: activityType, andPeriod: period, andUnit: unit, fromDate: firstDayOfDiary)
    }

    // note this can be pretty time consuming if asking for things like RYear
    func getValues(forActivity activity: ActivityEnum, andActivityType activityType: ActivityTypeEnum, andPeriod period: Period, andUnit unit: Unit, fromDate from: Date) -> [(date: Date, value:Double)]{
        return getValues(forActivity: activity, andActivityType: activityType, andPeriod: period, andUnit: unit, fromDate: from, toDate: lastDayOfDiary)
    }

    // note this can be pretty time consuming if asking for things like RYear
    func getValues(forActivity activity: ActivityEnum, andActivityType activityType: ActivityTypeEnum, andPeriod period: Period, andUnit unit: Unit, fromDate from: Date, toDate to: Date) -> [(date: Date, value:Double)]{
        
        if let optimizedResults = optimisedCalculation(forActivity: activity, andActivityType: activityType, andPeriod: period, andUnit: unit, fromDate: from, toDate: to){
            return optimizedResults
        }
        
        //if we get to this point it means optimization calculation hasn't worked.
        //This will then sum through days / workouts recursively. This can be slow
        //it also means averaging is rather tricky and hasn't been implemented (yet?)
        var result: [(date: Date, value: Double)] = []
        
        if period != Period.Day && !unit.summable{
            print("getValues(forActivity in Training Diary has not implemented weighted averaging so cannot return values for \(unit.rawValue)")
            return result
        }
        
        let sortedDays = ascendingOrderedDays(fromDate: from, toDate: to)
        if sortedDays.count > 0 {
            for day in sortedDays{
                result.append((date: day.date!, value: day.valueFor(period: period, activity: activity, activityType: activityType, unit: unit)))
            }
        }
        return result
    }
    
    func calcTSB(forActivity activity: ActivityEnum, fromDate d: Date){
        let start = Date()
        
        if !(activity == ActivityEnum.All){ // all is a calculated property
            let factors = tsbFactors(forActivity: activity)
            for day in ascendingOrderedDays(fromDate: d){
                let tss = day.valueFor(activity: activity, activityType: ActivityTypeEnum.All, unit: Unit.TSS)
                var atl = tss * factors.atlDayFactor
                var ctl = tss * factors.ctlDayFactor
                
                if let yesterday = day.yesterday{
                    let yATL = yesterday.value(forKey: activity.keyString(forUnit: .ATL)) as! Double
                    let yCTL = yesterday.value(forKey: activity.keyString(forUnit: .CTL)) as! Double
                    atl += yATL * factors.atlYDayFactor
                    ctl += yCTL * factors.ctlYDayFactor
                }

                let s = Date()
                day.setMetricValue(forActivity: activity, andMetric: Unit.ATL, toValue: atl)
                let s2 = Date()
                day.setMetricValue(forActivity: activity, andMetric: Unit.CTL, toValue: ctl)
                 let finish = Date()
                day.setMetricValue(forActivity: activity, andMetric: Unit.TSB, toValue: ctl - atl)
                if s2.timeIntervalSince(s) > TimeInterval(0.1){ print("ATL for \(activity) took \(s2.timeIntervalSince(s)) seconds") }
                if finish.timeIntervalSince(s2) > TimeInterval(0.1){ print("CTL for \(activity) took \(finish.timeIntervalSince(s2)) seconds") }

                
                if Date().timeIntervalSince(start) > TimeInterval(5.0){
                    print("exiting TSB calc for \(activity) as taking too long (ie more than 5s)")
                    return
                }
                
            }
            print("Calc TSB for \(activity.rawValue) took \(Date().timeIntervalSince(start)) seconds")
            
        }
        
    }
    
    
    public func kg(forDate d: Date) -> Double{
        if let w = weight(forDate: d){ return w.kg }
        return 0.0
    }

    public func fatPercentage(forDate d: Date) -> Double{
        if let w = weight(forDate: d){ return w.fatPercent }
        return 0.0
    }
    
    public func restingHeartRate(forDate d: Date) -> Int{
        if let physio = physiological(forDate: d){
            return Int(physio.restingHR)
        }
        return 0
    }
    
    //MARK: - Eddington Number Support
    func clearAllLTDEddingtonNumbers(){
        mutableSetValue(forKey: TrainingDiaryProperty.lTDEdNumbers.rawValue).removeAllObjects()
    }
    
    func addLTDEddingtonNumber(forActivity a: ActivityEnum, type at: ActivityTypeEnum, period p: Period, unit u: Unit, value v: Int, plusOne: Int){
        let len = CoreDataStackSingleton.shared.newLTDEdNum()
        len.activity = a.rawValue
        len.activityType = at.rawValue
        len.period = p.rawValue
        len.unit = u.rawValue
        len.value = Int16(v)
        len.plusOne = Int16(plusOne)
        len.lastUpdated = Date()
        self.addToLTDEdNumbers(len)
//        mutableSetValue(forKey: TrainingDiaryProperty.lTDEdNumbers.rawValue).add(len)
    }
    

    
    //MARK: - Private
    
    private func weight(forDate d: Date) -> Weight?{
        if let ws = self.weights{
            let weightsArray = ws.allObjects as! [Weight]
            let weights = weightsArray.filter({$0.fromDate! <= d && d <= $0.toDate!})
            if weights.count > 0{
                return weights[0]
            }
        }
        return nil
    }
    
    private func physiological(forDate d: Date) -> Physiological?{
        if let ps = self.physiologicals{
            let physioArray = ps.allObjects as! [Physiological]
            let physios = physioArray.filter({$0.fromDate! <= d && d <= $0.toDate!})
            if physios.count > 0{
                return physios[0]
            }
        }
        return nil
    }
    
    private func weightsAscendingDateOrder() -> [Weight]?{
        if let ws = self.weights{
            let weightsArray = ws.allObjects as! [Weight]
            return weightsArray.sorted(by: { $0.fromDate! < $1.fromDate! })
        }
        return nil
    }
    
    private func physiologicalsAscendingDateOrder() -> [Physiological]?{
        if let ps = self.physiologicals{
            let physios = ps.allObjects as! [Physiological]
            return physios.sorted(by: { $0.fromDate! < $1.fromDate! })
        }
        return nil
    }
    
    private func total(forKey: String) ->Double{
        var result: Double = 0.0
        if let allDays = days{
            for d in allDays{
                let day = d as! Day
                result += day.value(forKey: forKey) as! Double
            }
        }
        return result
    }
    

    
    // this is focussed on the rolling periods. It is very time consuming to just loop through and ask each day for it's rolling period - by way of example. RollingYear for all days would require summing 365 days for every day - thats 5,000 x 365 sums - if we ask each day individually. If we run through the days and keep a total as we go there are ~ 2 sums per day. So should be ~ 180 times faster. Sacrifising generalisation for speed here. A second benefit is this method makes it easier to average units rather than just sum them.
    private func optimisedCalculation(forActivity activity: ActivityEnum, andActivityType activityType: ActivityTypeEnum, andPeriod period: Period, andUnit unit: Unit, fromDate from: Date, toDate to: Date) -> [(date: Date, value:Double)]?{
//        print("STARTING optimized calculation for \(activity):\(activityType.rawValue):\(period.rawValue):\(unit)...")
        var result: [(date: Date, value:Double)] = []
        
        if unit.summable{
            var rSum: RollingPeriodSum
            switch period{
            case .rWeek:        rSum = RollingPeriodSum(size: 7)
            case .rMonth:       rSum = RollingPeriodSum(size: 30)
            case .rYear:        rSum = RollingPeriodSum(size: 365)
            case .WeekToDate:   rSum  = ToDateSum(size: 7, rule: {$0.isEndOfWeek()})
            case .MonthToDate:  rSum  = ToDateSum(size: 31, rule: {$0.isEndOfMonth()})
            case .YearToDate:   rSum  = ToDateSum(size: 366, rule: {$0.isEndOfYear()})
            case .Week:         rSum  = PeriodSum(size: 7, rule: {$0.isEndOfWeek()})
            case .Month:        rSum  = PeriodSum(size: 31, rule: {$0.isEndOfMonth()})
            case .Year:         rSum  = PeriodSum(size: 366, rule: {$0.isEndOfYear()})
            default:
                return nil
            }
            
            for d in ascendingOrderedDays(fromDate: rSum.preLoadData(forDate: from), toDate: to){
                let sum = rSum.addAndReturnSum(forDate: d.date!, value: d.valueFor(activity: activity, activityType: activityType, unit: unit))
                if d.date! >= from{
                    if let s = sum{
                        result.append((d.date!, s))
                    }
                }
            }
            
        }else{
            var rAverage: RollingPeriodWeightedAverage
            switch period{
            case .rWeek:        rAverage = RollingPeriodWeightedAverage(size: 7)
            case .rMonth:       rAverage = RollingPeriodWeightedAverage(size: 30)
            case .rYear:        rAverage = RollingPeriodWeightedAverage(size: 365)
            case .WeekToDate:   rAverage = ToDateWeightedAverage(size: 7, rule: {$0.isEndOfWeek()})
            case .MonthToDate:  rAverage = ToDateWeightedAverage(size: 31, rule: {$0.isEndOfMonth()})
            case .YearToDate:   rAverage = ToDateWeightedAverage(size: 366, rule: {$0.isEndOfYear()})
            case .Week:         rAverage = PeriodWeightedAverage(size: 7, rule: {$0.isEndOfWeek()})
            case .Month:        rAverage = PeriodWeightedAverage(size: 31, rule: {$0.isEndOfMonth()})
            case .Year:         rAverage = PeriodWeightedAverage(size: 366, rule: {$0.isEndOfYear()})
            default:
                return nil
            }
            
            
            for d in ascendingOrderedDays(fromDate: rAverage.preLoadData(forDate: from), toDate: to){
                var weight: Double = 1.0
                if unit.type() == UnitType.Activity{
                    weight = d.valueFor(activity: activity, activityType: activityType, unit: Unit.Seconds)
                }
                let sum = rAverage.addAndReturnAverage(forDate: d.date!, value: d.valueFor(activity: activity, activityType: activityType, unit: unit), wieghting: weight)
                if d.date! >= from{
                    if let s = sum{
                        result.append((d.date!, s))
                    }
                }
            }
        }
        

        return result
    }
    
    private func tsbFactors(forActivity activity: ActivityEnum) -> (ctlYDayFactor: Double,ctlDayFactor:Double, atlYDayFactor: Double, atlDayFactor: Double){
        
        let constants = tsbConstants(forActivity: activity)
        
        let ctlYDF = exp(-1.0/constants.ctlDays)
        let ctlDF = 1.0 - ctlYDF
        let atlYDF = exp(-1.0/constants.atlDays)
        let atlDF = 1.0 - atlYDF
        
        return (ctlYDayFactor: ctlYDF, ctlDayFactor: ctlDF, atlYDayFactor: atlYDF, atlDayFactor: atlDF)
        
    }
    
    private func tsbConstants(forActivity activity: ActivityEnum) -> (atlDays: Double, ctlDays: Double){
        
        var atl = Constant.ATLDays.rawValue
        var ctl = Constant.CTLDays.rawValue
        
        if let overrides = tsbConstants{
            for c in overrides{
                let override = c as! TSBConstant
                if override.activity! == activity.rawValue{
                    atl = override.atlDays
                    ctl = override.ctlDays
                }
            }
        }
        
        return (atl,ctl)
    }
    
    private func ascendingOrderedDays(fromDate from: Date, toDate to: Date) -> [Day]{
        return ascendingOrderedDays().filter({$0.date! >= from && $0.date! <= to})
    }
    
    private func ascendingOrderedDays(fromDate d: Date) -> [Day]{
        return ascendingOrderedDays().filter({$0.date! >= d})
    }
    
    private func ascendingOrderedDays() -> [Day]{
        if let diaryDays = self.days{
            var days: [Day] = []
            for fd in diaryDays{
                days.append(fd as! Day)
            }
            return days.sorted(by: {$0.date! < $1.date!})
        }
        return []
    }
    
/*    private func createNextHistory(previous: WorkoutHistory? = nil, workout w: Workout) -> WorkoutHistory{

        let result = WorkoutHistory.init(w)
        if let p = previous{
            result.incrementFrom(previous: p)
        }
        return result
        
    }
 */
}
