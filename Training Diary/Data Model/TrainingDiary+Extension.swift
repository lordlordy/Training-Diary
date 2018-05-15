//
//  TrainingDiary+Extension.swift
//  Training Diary
//
//  Created by Steven Lord on 08/11/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Foundation

struct HRVData{
    var date: Date

    var rmssdMean: Double
    var rmssdStdDev: Double
    var rmssdEasy: Double
    var rmssdHard: Double
    var rmssdOff: Double

    var sdnnMean: Double
    var sdnnStdDev: Double
    var sdnnEasy: Double
    var sdnnHard: Double
    var sdnnOff: Double

}

extension TrainingDiary{
//    extension TrainingDiary: TrainingDiaryValues{

    
    //MARK: - Lifetime for display in GUI summary
    @objc dynamic var totalBikeKM:          Double { return total(forKey: DayCalculatedProperty.bikeKM.rawValue) }
    @objc dynamic var totalSwimKM:          Double { return total(forKey: DayCalculatedProperty.swimKM.rawValue) }
    @objc dynamic var totalRunKM:           Double { return total(forKey: DayCalculatedProperty.runKM.rawValue) }
    @objc dynamic var totalReps:            Double { return total(forKey: DayCalculatedProperty.totalReps.rawValue) }
    @objc dynamic var totalAscentMetres:    Double { return total(forKey: DayCalculatedProperty.allAscentMetres.rawValue)}
    @objc dynamic var totalSeconds:         Double { return total(forKey: DayCalculatedProperty.allSeconds.rawValue)}
    @objc dynamic var totalTime:            TimeInterval { return TimeInterval(totalSeconds)}
    @objc dynamic var campDays:             Int { return dayCount(forType: DayType.Camp)}
    @objc dynamic var holidayDays:          Int { return dayCount(forType: DayType.Holiday)}
    @objc dynamic var illDays:              Int { return dayCount(forType: DayType.Ill)}
    @objc dynamic var injuredDays:          Int { return dayCount(forType: DayType.Injured)}
    @objc dynamic var niggleDays:           Int { return dayCount(forType: DayType.Niggle)}
    @objc dynamic var normalDays:           Int { return dayCount(forType: DayType.Normal)}
    @objc dynamic var raceDays:             Int { return dayCount(forType: DayType.Race)}
    @objc dynamic var recoveryDays:         Int { return dayCount(forType: DayType.Recovery)}
    @objc dynamic var restDays:             Int { return dayCount(forType: DayType.Rest)}
    @objc dynamic var travelDays:           Int { return dayCount(forType: DayType.Travel)}
   
    @objc dynamic var nameNotSet: Bool {
        if let n = name{
            return n == ""
        }
        return true
    }

    @objc dynamic var bikes: NSSet?{ return bikeMutableSet() }
    
    @objc dynamic var ltdEdNumCount: Int{
        var c = 0
        for i in ltdEddingtonNumbersArray(){
            c += i.leafCount
        }
        return c
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
    
    //ISO format for JSON export
//    @objc dynamic var firstDate: String{ return firstDayOfDiary.iso8601Format() }
  //  @objc dynamic var lastDate: String{ return lastDayOfDiary.iso8601Format() }

    // don't think this really need @objc dynamic - check and remove
    @objc dynamic var lastDayOfDiary: Date{
        return latestDay()?.date ?? Date()
    }
    
    @objc dynamic var workouts: [Workout]{
        return CoreDataStackSingleton.shared.workouts(forTrainingDiary: self)
    }
    
    @objc dynamic var ltdEddingtonNumberLeafs: [LTDEddingtonNumber]{
        var result: [LTDEddingtonNumber] = []
        for l in ltdEddingtonNumbersArray(){
            result.append(contentsOf: l.getLeaves())
        }
        return result
    }
    @objc dynamic var ltdLeafsCount: Int{
        return ltdEddingtonNumberLeafs.count
    }
    

    func getDaysDictionary(fromDate d: Date) -> [String: Day]{
        let startOfDay = d.startOfDay()
        let days = ascendingOrderedDays().filter({$0.date! > startOfDay})
        var result: [String:Day] = [:]
        for d in days{
            result[d.date!.dateOnlyShorterString()] = d
        }
        return result
    }
    
    func getDay(forDate d: Date) -> Day?{
        if let day = daysDictionary()[d.dateOnlyShorterString()]{
            return day
        }
        return nil
    }
    
    func ascendingOrderedDays() -> [Day]{
        let daysArray = days!.allObjects as! [Day]
        return daysArray.sorted(by: {$0.date! < $1.date!})
    }
    
    func descendingOrderedDays() -> [Day]{
        let daysArray = days!.allObjects as! [Day]
        return daysArray.sorted(by: {$0.date! > $1.date!})
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
    

    func connectWorkouts(forEquipment equipment: Equipment){
        CoreDataStackSingleton.shared.connectWorkouts(toEquipment: equipment)
    }
    
    
    func allWorkouts() -> [Workout]{ return CoreDataStackSingleton.shared.workouts(forTrainingDiary: self) }
    
    //MARK: -
    
    func uniqueActivityTypePairs() -> [String]{
        
        var result: [String] = []
        
        for a in activitiesArray(){
            let workouts = CoreDataStackSingleton.shared.workouts(forActivity: a, andTrainingDiary: self)
            for w in workouts{
                var possibleValue: String = w.activityString!
                possibleValue += ":"
                possibleValue += w.activityTypeString!
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
    
    //MARK - getting activity, type and equipment
     // NB these create it if not present
    // TO DO - these shouldn't return optionals
    func activity(forString s: String) -> Activity?{
        let a = activitiesArray().filter({$0.name == s})
        if a.count > 0{
            return a[0]
        }

        return nil
    }
    
    //this returns existing if exists otherwise creates a new one and returns
    func addActivity(forString s: String) -> Activity{
        if let a = activity(forString: s){ return a }

        //create new activity
        let newActivity = CoreDataStackSingleton.shared.newActivity()
        newActivity.name = s
        let activitySet = self.mutableSetValue(forKey: TrainingDiaryProperty.activities.rawValue)
        activitySet.add(newActivity)
        return newActivity
    
    }
    
    func activityType(forActivity a: String, andType t: String) -> ActivityType?{
        if let activity = activity(forString: a){
            if let at = activity.activityTypes?.allObjects as? [ActivityType]{
                let filtered = at.filter({$0.name == t})
                if filtered.count > 0{
                    return filtered[0]
                }
            }
        }
        
        return nil
    }
    
    func addActivityType(forActivity a: String, andType t: String) -> ActivityType?{
        if let at = activityType(forActivity: a, andType: t) { return at }
        
        //create new
        if let activity = activity(forString: a){
            //create new activity type
            let at = CoreDataStackSingleton.shared.newActivityType()
            at.name = t
            let activityTypeSet = activity.mutableSetValue(forKey: ActivityProperty.activityTypes.rawValue)
            activityTypeSet.add(at)
            print("Created new activity type in Training Diary - type \(String(describing: at.name)) added to \(String(describing: activity.name))")
            return at
        }else{
            print("Can't add new Activity Type \(t) for activity \(a) as that activity does not exist")
        }
        
        return nil
    }
    
    func equipment(forActivity a: String, andName n: String) -> Equipment?{
        if let activity = activity(forString: a){
            if let possEquip = activity.equipment?.allObjects as? [Equipment]{
                let filtered = possEquip.filter({$0.name == n})
                if filtered.count > 0{
                    return filtered[0]
                }
            }
        }
        return nil
    }
    
    func addEquipment(forActivity a: String, andName n: String) -> Equipment?{
        if let e = equipment(forActivity: a, andName: n){ return e}
        
        //create new
        if let activity = activity(forString: a){
            //create new equipment
            let e = CoreDataStackSingleton.shared.newEquipment()
            e.name = n
            let equipmentSet = activity.mutableSetValue(forKey: ActivityProperty.equipment.rawValue)
            equipmentSet.add(e)
            print("Created new equipment in Training Diary - type \(String(describing: e.name)) added to \(String(describing: activity.name))")
            return e
        }else{
            print("Can't add new equipment \(n) for activity \(a) as that activity does not exist")
        }
        
        return nil
    }

    //MARK: -
    
    func validActivityTypes(forActivityString a: String) -> [ActivityType]{
        if let activity = activity(forString: a){
            if let types = activity.activityTypes?.allObjects as? [ActivityType]{
                return types
            }
        }
        return []
    }


    

 
    func validEquipment(forActivityString a: String) -> [Equipment]{
        return equipment(forActivityString: a).filter({$0.active})
    }
    
    func equipment(forActivityString a: String) -> [Equipment]{
        if let activity = activity(forString: a){
            if let types = activity.equipment?.allObjects as? [Equipment]{
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
    
    func activityStrings() -> [String]{
        var strings = activitiesArray().map({$0.name!})
        strings.append(ConstantString.EddingtonAll.rawValue)
        return strings
    }
    

    
    func equipmentArray() -> [Equipment]{
        var equipment: [Equipment] = []
        for a in activitiesArray(){
            equipment.append(contentsOf: a.validEquipment())
        }
        return equipment
    }
    
    //MARK: - Eddington String
    
    func eddingtonDayTypes() -> [String]{
        var result = DayType.AllTypes.map({$0.rawValue})
        result.append(ConstantString.EddingtonAll.rawValue)
        result.sort(by: {$0 < $1})
        return result
    }
    
    func eddingtonActivities() -> [String]{
        var result = activitiesArray().filter({$0.includeInEddingtonCalcs}).map({$0.name!})
        result.append(ConstantString.EddingtonAll.rawValue)
        return result
    }
    
    func eddingtonActivityTypes(forActivityString a: String) -> [String]{
        if a == ConstantString.EddingtonAll.rawValue{
            return [ConstantString.EddingtonAll.rawValue]
        }
        if let activity = activity(forString: a){
            if let types = activity.activityTypes?.allObjects as? [ActivityType]{
                var tStrings = types.filter({$0.includeInEddingtonCalcs}).map({$0.name!})
                tStrings.append(ConstantString.EddingtonAll.rawValue)
                return tStrings
            }
        }
        return []
    }
    
    func eddingtonEquipment(forActivityString a: String) -> [String]{
        if a == ConstantString.EddingtonAll.rawValue{
            return [ConstantString.EddingtonAll.rawValue]
        }
        if let activity = activity(forString: a){
            if let types = activity.equipment?.allObjects as? [Equipment]{
                var tStrings = types.filter({$0.includeInEddingtonCalcs}).map({$0.name!})
                tStrings.append(ConstantString.EddingtonAll.rawValue)
                return tStrings
            }
        }
        return [ConstantString.EddingtonAll.rawValue]
    }
    
    
    //MARK: - Access to Bikes
    
    // need to adjust this when add type
    func bikeMutableSet() -> NSMutableSet?{
        for a in activitiesArray(){
            if a.name! == FixedActivity.Bike.rawValue{
                return a.mutableSetValue(forKeyPath: ActivityProperty.equipment.rawValue)
            }
        }
        return nil
    }
    
    
    func uniqueBikeNames() -> [String]{
        let bikeWorkouts = CoreDataStackSingleton.shared.workouts(forActivity: activity(forString: FixedActivity.Bike.rawValue)!, andTrainingDiary: self)
        var result: [String] = []
        for b in bikeWorkouts{
            if let name = b.equipmentName{
                if !result.contains(name){ result.append(name)}
            }else{
                print("No bike string set for workout dated \(String(describing: b.day?.date?.dateOnlyShorterString()))")
            }
        }
        
        
        return result
    }
    
    func activeBikes() ->[Equipment]{
        for a in activitiesArray(){
            if a.name! == FixedActivity.Bike.rawValue{
                return a.equipment?.allObjects as? [Equipment] ?? []
            }
        }
        return []
    }
    
    func orderedActiveBikes() -> [Equipment]{
        return activeBikes().sorted(by: {$0.name! < $1.name!})
    }
    
    //MARK: -
    
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

    func bmiAscendingDateOrder() -> [(date: Date, value: Double)]{
        var result: [(date: Date, value: Double)] = []
        if let orderedWeights = weightsAscendingDateOrder(){
            for w in orderedWeights{
                result.append((w.fromDate!, w.bmi))
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
    
    func ltdEddingtonNumberExists(dayType dt: String, activity a: String, activityType at: String, equipment e: String, period p: String, unit u: String ) -> Bool{
        let edCode = EddingtonNumber.code(dayType: dt, activity: a, activityType: at, equipment: e, period: p, unit: u)
        let currentEdNums = ltdEddingtonNumbersArray()
        let filtered = currentEdNums.filter({$0.code == edCode})
        
        return filtered.count > 0
    }
    
    //MARK: - TrainingDiaryValues protocol

    func valuesFor(dayType dt: String, activity a: String, activityType at: String, equipment e: String, period p: Period, aggregationMethod am: AggregationMethod, unit u: Unit, from: Date? = nil, to: Date? = nil) -> [(date: Date, value: Double)]{
        return getValues(forDayType: DayType(rawValue: dt), andActivity: activity(forString: a), andActivityType: activityType(forActivity: a, andType: at), andEquipment: equipment(forActivity: a, andName: e), andPeriod: p, aggregationMethod: am, andUnit: u, fromDate: from ?? firstDayOfDiary, toDate: to ?? lastDayOfDiary)
    }
    
    func valuesFor(dayType dt: DayType? = nil, activity a: Activity? = nil, activityType at: ActivityType? = nil, equipment e: Equipment? = nil, period p: Period, aggregationMethod am: AggregationMethod, unit u: Unit, from: Date? = nil, to: Date? = nil) -> [(date: Date, value: Double)]{
        return getValues(forDayType: dt, andActivity: a, andActivityType: at, andEquipment: e, andPeriod: p, aggregationMethod: am, andUnit: u, fromDate: from ?? firstDayOfDiary, toDate: to ?? lastDayOfDiary)
    }
    
    func valuesFor(dataSeriesDefinition dsd: DataSeriesDefinition) -> [(date: Date, value: Double)]{
        return getValues(forDayType: dsd.dayType, andActivity: dsd.activity, andActivityType: dsd.activityType, andEquipment: dsd.equipment, andPeriod: dsd.period, aggregationMethod: dsd.aggregationMethod, andUnit: dsd.unit, fromDate: firstDayOfDiary, toDate: lastDayOfDiary)
    }
 
    
    //MARK: - Getting values

    // this is focussed on the rolling periods. It is very time consuming to just loop through and ask each day for it's rolling period - by way of example. RollingYear for all days would require summing 365 days for every day - thats 5,000 x 365 sums - if we ask each day individually. If we run through the days and keep a total as we go there are ~ 2 sums per day. So should be ~ 180 times faster. Sacrifising generalisation for speed here. A second benefit is this method makes it easier to average units rather than just sum them.
    // note that passing in nil means ALL
    private func getValues(forDayType dt: DayType?, andActivity a: Activity?, andActivityType at: ActivityType?, andEquipment e: Equipment?, andPeriod period: Period, aggregationMethod am: AggregationMethod, andUnit unit: Unit, fromDate from: Date, toDate to: Date) -> [(date: Date, value:Double)]{
        
        var aggregator: DayAggregatorProtocol
        
        switch am{
        case .Sum:
            aggregator = SumAggregator(dayType: dt, activity: a, activityType: at, equipment: e, period: period, unit: unit, weighting: nil, from: from, to: to)
        case .Mean:
            aggregator = MeanAggregator(dayType: dt, activity: a, activityType: at, equipment: e, period: period, unit: unit, weighting: nil, from: from, to: to)
        case .WeightedMean:
            aggregator = MeanAggregator(dayType: dt, activity: a, activityType: at, equipment: e, period: period, unit: unit, weighting: Unit.seconds, from: from, to: to)
        case .None:
            aggregator = DayAggregator(dayType: dt, activity: a, activityType: at, equipment: e, period: period, unit: unit, from: from, to: to)
        }
        
        let results = aggregator.aggregate(data: days?.allObjects as? [Day] ?? [])
        return results
        
    }
    
    //MARK: -
    
    //this does whole diary for every activity
    func recalcTSB(){
        for a in activitiesArray(){
            calcTSB(forActivity: a, fromDate: firstDayOfDiary)
        }
    }
    
    func calcTSB(forActivity activity: Activity, fromDate d: Date ){
        
        let start = Date()
        
        for day in self.ascendingOrderedDays(fromDate: d){
            let tss = day.valueFor(activity: activity, unit: Unit.tss)
   
            var yCTL = 0.0
            var yATL = 0.0
            
            if let yesterday = day.yesterday{
                yATL = yesterday.metric(forActivity: activity, andMetric: Unit.atl)?.value ?? 0.0
                yCTL = yesterday.metric(forActivity: activity, andMetric: Unit.ctl)?.value ?? 0.0
            }
  
            let ctl = activity.ctl(yesterdayCTL: yCTL, tss: tss)
            let atl = activity.atl(yesterdayATL: yATL, tss: tss)
            
            day.setMetricValue(forActivity: activity, andMetric: Unit.atl, toValue: atl)
            day.setMetricValue(forActivity: activity, andMetric: Unit.ctl, toValue: ctl)
            day.setMetricValue(forActivity: activity, andMetric: Unit.tsb, toValue: ctl - atl)
            
        }
        print("Calc TSB for \(activity.name!) took \(Date().timeIntervalSince(start)) seconds")
        
    }
    

    
    func calculateMonotonyAndStrain(){
        for a in activitiesArray(){
            calculateMonotonyAndStrain(forActivity: a, fromDate: firstDayOfDiary)
        }
    }
    
    
    //no return as this will be stored in Core Data as another metric.
    func calculateMonotonyAndStrain(forActivity a: Activity, fromDate: Date){
        let start = Date()
        let q = RollingSumQueue(size: Int(monotonyDays))
        let orderedDays = ascendingOrderedDays()
        //need to pre load the RollingSumQ
        for d in orderedDays.filter({$0.date! >= fromDate.addDays(numberOfDays: Int(-monotonyDays)) && $0.date! < fromDate} ){
            _ = q.addAndReturnAverage(value: d.valueFor(activity: a, unit: Unit.tss))
        }
        
        let mathematics = Maths()
        for d in orderedDays.filter({$0.date! >= fromDate}){
            _ = q.addAndReturnAverage(value: d.valueFor(activity: a, unit: Unit.tss))
            let mAndStrain = mathematics.monotonyAndStrain(q.array())
            d.setMetricValue(forActivity: a, andMetric: Unit.monotony, toValue: mAndStrain.monotony)
            d.setMetricValue(forActivity: a, andMetric: Unit.strain, toValue: mAndStrain.strain)
        }
        print("Calc strain for \(String(describing: a.name)) took \(Date().timeIntervalSince(start))s")
    }
    
    public func kg(forDate d: Date) -> Double{
        let maths = Maths()
        let mapped = kgArray().map({(x:$0.date, y:$0.kg)})
        return maths.linearInterpolate(forX: d.timeIntervalSince1970, fromValues: mapped)
    }

    public func fatPercentage(forDate d: Date) -> Double{
        let maths =  Maths()
        let mapped = fatPercentageArray().map({(x:$0.date, y:$0.fatPercent)})
        return maths.linearInterpolate(forX: d.timeIntervalSince1970, fromValues: mapped)
    }
    
    public func restingHeartRate(forDate d: Date) -> Double{
        let maths = Maths()
        let mapped = restingHRArray().map({(x: $0.date, y: $0.hr)})
        return maths.linearInterpolate(forX: d.timeIntervalSince1970, fromValues: mapped)
    }

    public func restingSDNN(forDate d: Date) -> Double{
        let maths = Maths()
        let mapped = restingSDNNArray().map({(x: $0.date, y: $0.sdnn)})
        return maths.linearInterpolate(forX: d.timeIntervalSince1970, fromValues: mapped)
    }
    
    public func restingRMSSD(forDate d: Date) -> Double{
        let maths = Maths()
        let mapped = restingRMSSDArray().map({(x: $0.date, y: $0.rMSSD)})
        return maths.linearInterpolate(forX: d.timeIntervalSince1970, fromValues: mapped)
    }
    
    func calculatedHRVData() -> [HRVData]{
        var result: [HRVData] = []
        let mathCalculator = Maths()
        
        let offSDs = mathCalculator.normalCDFInverse(hrvOffPercentile / 100 )
        let easySDs = mathCalculator.normalCDFInverse(hrvEasyPercentile / 100 )
        let hardSDs = mathCalculator.normalCDFInverse(hrvHardPercentile / 100 )
        
        if let firstDate = earliestRMSSDDate(){
            let rQ = RollingSumQueue(size: 91)
            let sQ = RollingSumQueue(size: 91)
            
            for d in ascendingOrderedDays(fromDate: firstDate){
                if let p = physiological(forDate: d.date!){
    
                    let rMean = rQ.addAndReturnAverage(value:p.restingRMSSD)
                    let rStDev = mathCalculator.standardDeviation(rQ.array())
                    let rHard = rMean + hardSDs * rStDev
                    let rEasy = rMean + easySDs * rStDev
                    let rOff = rMean + offSDs * rStDev
                    
                    let sMean = sQ.addAndReturnAverage(value: p.restingSDNN)
                    let sStDev = mathCalculator.standardDeviation(sQ.array())
                    let sHard = sMean + hardSDs * sStDev
                    let sEasy = sMean + easySDs * sStDev
                    let sOff = sMean + offSDs * sStDev
                    
                    result.append(HRVData(date: d.date!, rmssdMean: rMean, rmssdStdDev: rStDev, rmssdEasy: rEasy, rmssdHard: rHard, rmssdOff: rOff, sdnnMean: sMean, sdnnStdDev: sStDev, sdnnEasy: sEasy, sdnnHard: sHard, sdnnOff: sOff))

                }
            }
        }
        return result
    }
    

    
    //MARK: - Eddington Number Support

    func getLTDEddingtonNumber(forDayType dt: String) -> LTDEddingtonNumber{
        if let array = ltdEddingtonNumbers?.allObjects as? [LTDEddingtonNumber]{
            let filtered = array.filter({$0.name! == dt})
            if filtered.count == 1{
                return filtered[0]
            }else if filtered.count > 1{
                // shouldn't be more than this many
                print("\(filtered.count) children of name \(dt) in \(String(describing: name)) - should be unique by name")
                return filtered[0]
            }
        }
        
        let newChild = CoreDataStackSingleton.shared.newLTDEddingtonNumber(dt)
        mutableSetValue(forKey: TrainingDiaryProperty.ltdEddingtonNumbers.rawValue).add(newChild)
        return newChild
    }
  
    func addLTDEddingtonNumber(forDayType dt: String, forActivity a: String, type at: String, equipment e: String, period p: Period, unit u: Unit, value v: Int, plusOne: Int, maturity: Double){
        
        
        let dLevel = getLTDEddingtonNumber(forDayType: dt)
        dLevel.dayType = dt
        dLevel.lastUpdate = Date()
        
        let aLevel = dLevel.getChild(forName: a)
        aLevel.dayType = dt
        aLevel.activity = a
        aLevel.lastUpdate = Date()
        
        let eLevel = aLevel.getChild(forName: e)
        eLevel.dayType = dt
        eLevel.activity = a
        eLevel.equipment = e
        eLevel.activityType = nil
        eLevel.lastUpdate = Date()

        let tLevel = eLevel.getChild(forName: at)
        tLevel.dayType = dt
        tLevel.activity = a
        tLevel.equipment = e
        tLevel.activityType = at
        tLevel.lastUpdate = Date()

        let uLevel = tLevel.getChild(forName: u.rawValue)
        uLevel.dayType = dt
        uLevel.activity = a
        uLevel.equipment = e
        uLevel.activityType = at
        uLevel.unit = u.rawValue
        uLevel.lastUpdate = Date()

        let pLevel = uLevel.getChild(forName: p.rawValue)
        pLevel.dayType = dt
        pLevel.activity = a
        pLevel.equipment = e
        pLevel.activityType = at
        pLevel.unit = u.rawValue
        pLevel.period = p.rawValue
        pLevel.value = Int16(v)
        pLevel.plusOne = Int16(plusOne)
        pLevel.maturity = maturity
        pLevel.lastUpdate = Date()

        
    }
    

    //MARK: - Private
    
    private func kgArray() -> [(date: Double, kg: Double)]{
    
        var result:[(date: Double, kg: Double)] = []
        
        for w in weightsArray(){
            if let d = w.fromDate{
                result.append((d.timeIntervalSince1970, w.kg))
            }
        }
        
        return result
    }
    
    private func fatPercentageArray() -> [(date: Double, fatPercent: Double)]{
        
        var result:[(date: Double, fatPercent: Double)] = []
        
        for w in weightsArray(){
            if let d = w.fromDate{
                result.append((d.timeIntervalSince1970, w.fatPercent))
            }
        }
        
        return result
    }
    
    
    private func restingHRArray() -> [(date: Double, hr: Double)]{
        
        var result:[(date: Double, hr: Double)] = []
        
        for w in physiologicalArray(){
            if let d = w.fromDate{
                result.append((d.timeIntervalSince1970, w.restingHR))
            }
        }
        
        return result
    }
    
    private func restingSDNNArray() -> [(date: Double, sdnn: Double)]{
        
        var result:[(date: Double, sdnn: Double)] = []
        
        for w in physiologicalArray(){
            if let d = w.fromDate{
                result.append((d.timeIntervalSince1970, w.restingSDNN))
            }
        }
        
        return result
    }
    
    private func restingRMSSDArray() -> [(date: Double, rMSSD: Double)]{
        
        var result:[(date: Double, rMSSD: Double)] = []
        
        for w in physiologicalArray(){
            result.append((w.fromDate!.timeIntervalSince1970, w.restingRMSSD))
        }
        
        return result
    }
    
    
    private func weight(forDate d: Date) -> Weight?{
        
        let array = weightsArray()
        let weightsAfter = array.filter({$0.fromDate! >= d}).sorted(by: {$0.fromDate! < $1.fromDate!})
        if weightsAfter.count > 0{
            return weightsAfter[0]
        }
        return nil
    }
    
    private func weightsArray() -> [Weight]{
        if let ws = self.weights{
            return ws.allObjects as! [Weight]
        }
        return []
    }
    
    private func physiological(forDate d: Date) -> Physiological?{
        let array = physiologicalArray()
        let physios = array.filter({$0.fromDate! >= d}).sorted(by: {$0.fromDate! < $1.fromDate!})
        if physios.count > 0{
            return physios[0]
        }
        return nil
    }
    
    private func physiologicalArray() -> [Physiological]{
        if let ps = self.physiologicals{
            return ps.allObjects as! [Physiological]
        }
        return []
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
    

    

    

    private func ascendingOrderedDays(fromDate from: Date, toDate to: Date) -> [Day]{
        return ascendingOrderedDays().filter({$0.date! >= from && $0.date! <= to})
    }
    
    private func ascendingOrderedDays(fromDate d: Date) -> [Day]{
        return ascendingOrderedDays().filter({$0.date! >= d})
    }
    
    private func ltdEddingtonNumbersArray() -> [LTDEddingtonNumber]{
        return ltdEddingtonNumbers?.allObjects as? [LTDEddingtonNumber] ?? []
    }
    
    // returning nil means no RMSSD data found
    private func earliestRMSSDDate() -> Date?{
        if let hrData = physiologicals?.allObjects as? [Physiological]{
            for s in hrData.sorted(by: {$0.fromDate! < $1.fromDate!}){
                if s.restingRMSSD > 0{
                    return s.fromDate!
                }
            }
        }
        return nil
    }
    
    private func dayCount(forType t: DayType) -> Int{
        if let d = days?.allObjects as? [Day]{
            return d.filter({$0.type! == t.rawValue}).count
        }
        return 0
    }
    
    //the string is the result of dateOnlyShorterString() call on date
    private func daysDictionary() -> [String:Day]{
        var result: [String:Day] = [:]
        
        if let diaryDays = self.days?.allObjects as? [Day]{
            for d in diaryDays{
                if let date = d.date{
                    result[date.dateOnlyShorterString()] = d
                }
            }
        }
        return result
    }
    
    

    
}
