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

extension TrainingDiary: TrainingDiaryValues{
    
    
    //MARK: - Lifetime for display in GUI summary
    @objc dynamic var totalBikeKM:  Double{ return total(forKey: "bikeKM") }
    @objc dynamic var totalSwimKM:  Double{ return total(forKey: "swimKM") }
    @objc dynamic var totalRunKM:   Double{ return total(forKey: "runKM") }
    @objc dynamic var totalSeconds: Double{ return total(forKey: "allSeconds")}
    @objc dynamic var totalTime: TimeInterval{ return TimeInterval(totalSeconds)}
    
    
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
    
    // don't think this really need @objc dynamic - check and remove
    @objc dynamic var lastDayOfDiary: Date{
        return latestDay()?.date ?? Date()
    }
    
    @objc dynamic var workouts: [Workout]{
        return CoreDataStackSingleton.shared.workouts(forTrainingDiary: self)
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
    

    
    func equipmentArray() -> [Equipment]{
        var equipment: [Equipment] = []
        for a in activitiesArray(){
            equipment.append(contentsOf: a.validEquipment())
        }
        return equipment
    }
    
    //MARK: - Eddington String
    
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
    
    func ltdEddingtonNumberExists(activity a: String, activityType at: String, equipment e: String, period p: String, unit u: String ) -> Bool{
        let edCode = EddingtonNumber.code(activity: a, activityType: at, equipment: e, period: p, unit: u)
        let currentEdNums = ltdEddingtonNumbersArray()
        let filtered = currentEdNums.filter({$0.code == edCode})
        
        return filtered.count > 0
    }
    
    //MARK: - TrainingDiaryValues protocol

    func valuesFor(activity a: String, activityType at: String, equipment e: String, period p: Period, unit u: Unit, from: Date? = nil, to: Date? = nil) -> [(date: Date, value: Double)]{
        var fromDate = firstDayOfDiary
        var toDate = lastDayOfDiary
        if let f = from { fromDate = f}
        if let t = to   { toDate = t}
        return getValues(forActivity: a, andActivityType: at, andEquipment: e, andPeriod: p, andUnit: u, fromDate: fromDate, toDate: toDate)
    }
    
    func valuesFor(activity a: Activity?, activityType at: ActivityType?, equipment e: Equipment?, period p: Period, unit u: Unit, from: Date? = nil, to: Date? = nil) -> [(date: Date, value: Double)] {
        let ALL = ConstantString.EddingtonAll.rawValue
        return valuesFor(activity: a?.name ?? ALL, activityType: at?.name ?? ALL, equipment: e?.name ?? ALL, period: p, unit: u, from: from, to: to)
    }
    

    func valuesAreForTrainingDiary() -> TrainingDiary { return self }
    
    //MARK: - Getting values

    // note this can be pretty time consuming if asking for things like RYear
    private func getValues(forActivity a: String, andActivityType at: String, andEquipment e: String, andPeriod period: Period, andUnit unit: Unit, fromDate from: Date, toDate to: Date) -> [(date: Date, value:Double)]{
        
        if let optimizedResults = optimisedCalculation(forActivity: a, andActivityType: at, andEquipment: e, andPeriod: period, andUnit: unit, fromDate: from, toDate: to){
            return optimizedResults
        }
        
        //if we get to this point it means optimization calculation hasn't worked.
        //This will then sum through days / workouts recursively. This can be slow
        //it also means averaging is rather tricky and hasn't been implemented (yet?)
        var result: [(date: Date, value: Double)] = []
        
        if period != Period.Day && !unit.summable{
            print("getValues(forActivity:) in Training Diary has not implemented weighted averaging so cannot return values for \(unit.rawValue)")
            return result
        }
        
        let sortedDays = ascendingOrderedDays(fromDate: from, toDate: to)
        if sortedDays.count > 0 {
            for day in sortedDays{
                let r = day.valuesFor(activity: a, activityType: at, equipment: e, period: period, unit: unit)
                result.append(r[0])
            }
        }
        return result
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
        
        let factors = self.tsbFactors(forActivity: activity)
        for day in self.ascendingOrderedDays(fromDate: d){
            let tss = day.valueFor(activity: activity, unit: Unit.TSS)
            var atl = tss * factors.atlDayFactor
            var ctl = tss * factors.ctlDayFactor
            
            if let yesterday = day.yesterday{
                let yATL = yesterday.metric(forActivity: activity, andMetric: Unit.ATL)?.value ?? 0.0
                let yCTL = yesterday.metric(forActivity: activity, andMetric: Unit.CTL)?.value ?? 0.0
                atl += yATL * factors.atlYDayFactor
                ctl += yCTL * factors.ctlYDayFactor
            }

            day.setMetricValue(forActivity: activity, andMetric: Unit.ATL, toValue: atl)
            day.setMetricValue(forActivity: activity, andMetric: Unit.CTL, toValue: ctl)
            day.setMetricValue(forActivity: activity, andMetric: Unit.TSB, toValue: ctl - atl)
            
        }
        print("Calc TSB for \(activity.name!) took \(Date().timeIntervalSince(start)) seconds")
        
    }
    
    func calculateMonotonyAndStrain(){
        for a in activitiesArray(){
            calculateMonotonyAndStrain(forActivity: a)
        }
    }
    
    //no return as this will be stored in Core Data as another metric.
    func calculateMonotonyAndStrain(forActivity a: Activity){
        let start = Date()
        let q = RollingSumQueue(size: Int(monotonyDays))
        let mathematics = Maths()
        for d in ascendingOrderedDays(){
            _ = q.addAndReturnAverage(value: d.valueFor(activity: a, unit: Unit.TSS))
            let mAndStrain = mathematics.monotonyAndStrain(q.array())
            d.setMetricValue(forActivity: a, andMetric: Unit.Monotony, toValue: mAndStrain.monotony)
            d.setMetricValue(forActivity: a, andMetric: Unit.Strain, toValue: mAndStrain.strain)
        }
        print("Calc strain for \(a.name) took \(Date().timeIntervalSince(start))s")
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

    public func restingSDNN(forDate d: Date) -> Double{
        if let physio = physiological(forDate: d){
            return physio.restingSDNN
        }
        return 0.0
    }
    
    public func restingRMSSD(forDate d: Date) -> Double{
        if let physio = physiological(forDate: d){
            return physio.restingRMSSD
        }
        return 0.0
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

    func getLTDEddingtonNumber(forActivity a: String) -> LTDEddingtonNumber{
        if let array = ltdEddingtonNumbers?.allObjects as? [LTDEddingtonNumber]{
            let filtered = array.filter({$0.name! == a})
            if filtered.count == 1{
                return filtered[0]
            }else if filtered.count > 1{
                // shouldn't be more than this many
                print("\(filtered.count) children of name \(a) in \(String(describing: name)) - should be unique by name")
                return filtered[0]
            }
        }
        
        let newChild = CoreDataStackSingleton.shared.newLTDEddingtonNumber(a)
        mutableSetValue(forKey: TrainingDiaryProperty.ltdEddingtonNumbers.rawValue).add(newChild)
        return newChild
    }
  
    func addLTDEddingtonNumber(forActivity a: String, type at: String, equipment e: String, period p: Period, unit u: Unit, value v: Int, plusOne: Int, maturity: Double){
        
        
        let aLevel = getLTDEddingtonNumber(forActivity: a)
        aLevel.activity = a
        aLevel.lastUpdate = Date()
        
        let eLevel = aLevel.getChild(forName: e)
        eLevel.activityType = a
        eLevel.equipment = e
        eLevel.lastUpdate = Date()

        let tLevel = eLevel.getChild(forName: at)
        tLevel.activity = a
        tLevel.equipment = e
        tLevel.activityType = at
        tLevel.lastUpdate = Date()

        let uLevel = tLevel.getChild(forName: u.rawValue)
        uLevel.activity = a
        uLevel.equipment = e
        uLevel.activityType = at
        uLevel.unit = u.rawValue
        uLevel.lastUpdate = Date()

        let pLevel = uLevel.getChild(forName: p.rawValue)
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
    private func optimisedCalculation(forActivity activity: String, andActivityType activityType: String, andEquipment e: String, andPeriod period: Period, andUnit unit: Unit, fromDate from: Date, toDate to: Date) -> [(date: Date, value:Double)]?{
//        print("STARTING optimized calculation for \(activity):\(activityType.rawValue):\(period.rawValue):\(unit)...")
        var result: [(date: Date, value:Double)] = []
        
        if unit.summable{
            var rSum: RollingPeriodSum
            switch period{
            case .rWeek:        rSum = RollingPeriodSum(size: 7)
            case .rMonth:       rSum = RollingPeriodSum(size: 30)
            case .rYear:        rSum = RollingPeriodSum(size: 365)
            case .WeekToDate:   rSum  = ToDateSum(size: 7, rule: {$0.isEndOfWeek()})
            case .WTDTue:       rSum  = ToDateSum(size: 7, rule: {$0.isMonday()})
            case .WTDWed:       rSum  = ToDateSum(size: 7, rule: {$0.isTuesday()})
            case .WTDThu:       rSum  = ToDateSum(size: 7, rule: {$0.isWednesday()})
            case .WTDFri:       rSum  = ToDateSum(size: 7, rule: {$0.isThursday()})
            case .WTDSat:       rSum  = ToDateSum(size: 7, rule: {$0.isFriday()})
            case .WTDSun:       rSum  = ToDateSum(size: 7, rule: {$0.isSaturday()})
            case .MonthToDate:  rSum  = ToDateSum(size: 31, rule: {$0.isEndOfMonth()})
            case .YearToDate:   rSum  = ToDateSum(size: 366, rule: {$0.isEndOfYear()})
            case .Week:         rSum  = PeriodSum(size: 7, rule: {$0.isEndOfWeek()})
            case .WeekTue:      rSum  = PeriodSum(size: 7, rule: {$0.isMonday()})
            case .WeekWed:      rSum  = PeriodSum(size: 7, rule: {$0.isTuesday()})
            case .WeekThu:      rSum  = PeriodSum(size: 7, rule: {$0.isWednesday()})
            case .WeekFri:      rSum  = PeriodSum(size: 7, rule: {$0.isThursday()})
            case .WeekSat:      rSum  = PeriodSum(size: 7, rule: {$0.isFriday()})
            case .WeekSun:      rSum  = PeriodSum(size: 7, rule: {$0.isSaturday()})
            case .Month:        rSum  = PeriodSum(size: 31, rule: {$0.isEndOfMonth()})
            case .Year:         rSum  = PeriodSum(size: 366, rule: {$0.isEndOfYear()})
            default:
                return nil
            }
            
            for d in ascendingOrderedDays(fromDate: rSum.preLoadData(forDate: from), toDate: to){
                let sum = rSum.addAndReturnSum(forDate: d.date!, value: d.valueFor(activity: activity, activityType: activityType, equipment: e, unit: unit))
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
            case .WTDTue:       rAverage = ToDateWeightedAverage(size: 7, rule: {$0.isMonday()})
            case .WTDWed:       rAverage = ToDateWeightedAverage(size: 7, rule: {$0.isTuesday()})
            case .WTDThu:       rAverage = ToDateWeightedAverage(size: 7, rule: {$0.isWednesday()})
            case .WTDFri:       rAverage = ToDateWeightedAverage(size: 7, rule: {$0.isThursday()})
            case .WTDSat:       rAverage = ToDateWeightedAverage(size: 7, rule: {$0.isFriday()})
            case .WTDSun:       rAverage = ToDateWeightedAverage(size: 7, rule: {$0.isSaturday()})
            case .MonthToDate:  rAverage = ToDateWeightedAverage(size: 31, rule: {$0.isEndOfMonth()})
            case .YearToDate:   rAverage = ToDateWeightedAverage(size: 366, rule: {$0.isEndOfYear()})
            case .Week:         rAverage = PeriodWeightedAverage(size: 7, rule: {$0.isEndOfWeek()})
            case .WeekTue:      rAverage = PeriodWeightedAverage(size: 7, rule: {$0.isMonday()})
            case .WeekWed:      rAverage = PeriodWeightedAverage(size: 7, rule: {$0.isTuesday()})
            case .WeekThu:      rAverage = PeriodWeightedAverage(size: 7, rule: {$0.isWednesday()})
            case .WeekFri:      rAverage = PeriodWeightedAverage(size: 7, rule: {$0.isThursday()})
            case .WeekSat:      rAverage = PeriodWeightedAverage(size: 7, rule: {$0.isFriday()})
            case .WeekSun:      rAverage = PeriodWeightedAverage(size: 7, rule: {$0.isSaturday()})
            case .Month:        rAverage = PeriodWeightedAverage(size: 31, rule: {$0.isEndOfMonth()})
            case .Year:         rAverage = PeriodWeightedAverage(size: 366, rule: {$0.isEndOfYear()})
            default:
                return nil
            }
            
            
            for d in ascendingOrderedDays(fromDate: rAverage.preLoadData(forDate: from), toDate: to){
                var weight: Double = 1.0
                if unit.type() == UnitType.Activity{
                    weight = d.valueFor(activity: activity, activityType: activityType, equipment: e, unit: Unit.Seconds)
                }
                let sum = rAverage.addAndReturnAverage(forDate: d.date!, value: d.valueFor(activity: activity, activityType: activityType, equipment: e, unit: unit), wieghting: weight)
                if d.date! >= from{
                    if let s = sum{
                        result.append((d.date!, s))
                    }
                }
            }
        }
        

        return result
    }
    
    private func tsbFactors(forActivity activity: Activity) -> (ctlYDayFactor: Double,ctlDayFactor:Double, atlYDayFactor: Double, atlDayFactor: Double){
        
        let constants = tsbConstants(forActivity: activity)
        
        let ctlYDF = exp(-1.0/constants.ctlDays)
        let ctlDF = 1.0 - ctlYDF
        let atlYDF = exp(-1.0/constants.atlDays)
        let atlDF = 1.0 - atlYDF
        
        return (ctlYDayFactor: ctlYDF, ctlDayFactor: ctlDF, atlYDayFactor: atlYDF, atlDayFactor: atlDF)
        
    }
    
    private func tsbConstants(forActivity activity: Activity) -> (atlDays: Double, ctlDays: Double){
        
        var atl = Constant.ATLDays.rawValue
        var ctl = Constant.CTLDays.rawValue
        
        if let overrides = tsbConstants{
            for c in overrides{
                let override = c as! TSBConstant
                if override.activity! == activity.name!{
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
    
}
