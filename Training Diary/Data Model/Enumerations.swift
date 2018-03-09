//
//  Constants.swift
//  Training Diary
//
//  Created by Steven Lord on 17/10/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//


import Foundation

//provides string used in FMP JSON
protocol FileMakerProJSONString{
    func fmpString() -> String
}

enum WeekDay: Int{
    case gregorianSunday = 1
    case gregorianMonday = 2
    case gregorianTuesday = 3
    case gregorianWednesday = 4
    case gregorianThursday = 5
    case gregorianFriday = 6
    case gregorianSaturday = 7
    
    func previousWeekDay() -> WeekDay{
        switch self{
        case .gregorianSunday:      return .gregorianSaturday
        case .gregorianMonday:      return .gregorianSunday
        case .gregorianTuesday:     return .gregorianMonday
        case .gregorianWednesday:   return .gregorianTuesday
        case .gregorianThursday:    return .gregorianWednesday
        case .gregorianFriday:      return .gregorianThursday
        case .gregorianSaturday:    return .gregorianFriday
        }
    }
    
}

enum TSSMethod: String{
    case RPE
    case TRIMPS
    case PacePower
    
    static var AllMethods = [RPE, TRIMPS, PacePower]
}

//these will be included with the app and cannot be deleted.
enum FixedActivity: String{
    case Swim, Bike, Run, Gym
    static let All = [Swim, Bike, Run, Gym]
}

enum DayType: String{
    case Normal
    case Race
    case Holiday
    case Rest
    case Recovery
    case Travel
    case Injured
    case Niggle
    case Ill
    case Camp
    
    static var AllTypes = [Normal, Race, Camp, Holiday, Rest, Recovery, Travel, Injured, Niggle, Ill]
}

enum SleepQuality: String{
    case Excellent
    case Good
    case Average
    case Poor
    case VeryPoor = "Very Poor"
    static var All = [Excellent, Good, Average, Poor, VeryPoor]
}

enum Constant: Double {

    case KmPerMile          = 1.60934
    case MilesPerKM         = 0.621371
    case MinutesPerSecond   = 0.01666667
    case HoursPerSecond     = 0.00027777
    case SecondsPerMinute   = 60.0
    case SecondsPerHour     = 3600.0
    case SecondsPerDay      = 86400.0
    case FeetPerMetre       = 3.28084
    case LbsPerKg           = 2.20462
    case SecondsPer365Days  = 31_536_000
    case ATLDays            = 7
    case CTLDays            = 42
    case WorkoutThresholdForEdNumberCount = 10
}

enum ConstantString: String{
    case EddingtonAll       = "All"
}


//MARK: -  Base Data Support

enum Period: String{
    case Day            = "Day"
    case Week           = "Wk-Mon"
    case Month          = "Month"
    case Year           = "Year"
    case WeekToDate     = "WTD-Mon"
    case MonthToDate    = "MTD"
    case YearToDate     = "YTD"
    case rWeek          = "RWeek"
    case rMonth         = "RMonth"
    case rYear          = "RYear"
    case Lifetime       = "Lifetime"
    case Adhoc          = "Adhoc"
    case WeekTue        = "Wk-Tue"
    case WeekWed        = "Wk-Wed"
    case WeekThu        = "Wk-Thu"
    case WeekFri        = "Wk-Fri"
    case WeekSat        = "Wk-Sat"
    case WeekSun        = "Wk-Sun"
    case WTDTue         = "WTD-Tue"
    case WTDWed         = "WTD-Wed"
    case WTDThu         = "WTD-Thu"
    case WTDFri         = "WTD-Fri"
    case WTDSat         = "WTD-Sat"
    case WTDSun         = "WTD-Sun"
    case Workout        = "Workout"

    static var eddingtonNumberPeriods = [Day, Week, Month, Year, WeekToDate, MonthToDate, YearToDate, rWeek, rMonth, rYear, WeekTue, WeekWed, WeekThu, WeekFri, WeekSat, WeekSun, WTDTue, WTDWed, WTDThu, WTDFri, WTDSat, WTDSun, Workout]
    static var All = [Day,Week,Month,Year, WeekToDate,MonthToDate, YearToDate,rWeek,rMonth,rYear, Lifetime, Adhoc, WeekTue, WeekWed, WeekThu, WeekFri, WeekSat, WeekSun, WTDTue, WTDWed, WTDThu, WTDFri, WTDSat, WTDSun, Workout]
    
    
    /* Returns the periods range of dates for a given date. This gives the period this ends with except where this doesn't make sense
     when it gives period this date is within.
     Returns period ending on date for: Day, WeekToDate, MonthToDate, YearToDate, rWeek, rMonth and rYear
     Returns period containing the date for: Week, Month, Year
     Adhoc and Lifetime make no sense just just returns same as Day for now.
     */
    public func periodRange(forDate d: Date) -> (from: Date, to: Date){
        switch self{
        case .Day, .Adhoc, .Lifetime, .Workout:
                            return (from: d, to: d)
        case .Week:         return (from: d.startOfWeek(), to: d.endOfWeek())
        case .Month:        return (from: d.startOfMonth(), to: d.endOfMonth())
        case .Year:         return (from: d.startOfYear(), to: d.endOfYear())
        case .WeekToDate:   return (from: d.startOfWeek(), to: d)
        case .MonthToDate:  return (from: d.startOfMonth(), to: d)
        case .YearToDate:   return (from: d.startOfYear(), to: d)
        case .rWeek:        return (from: d.startOfRWeek(), to: d)
        case .rMonth:       return (from: d.startOfRMonth(), to: d)
        case .rYear:        return (from: d.startOfRYear(), to: d)
        case .WTDTue:       return (from: d.startOfWeek(firstDayOfWeek: .gregorianTuesday), to: d)
        case .WTDWed:       return (from: d.startOfWeek(firstDayOfWeek: .gregorianWednesday), to: d)
        case .WTDThu:       return (from: d.startOfWeek(firstDayOfWeek: .gregorianThursday), to: d)
        case .WTDFri:       return (from: d.startOfWeek(firstDayOfWeek: .gregorianFriday), to: d)
        case .WTDSat:       return (from: d.startOfWeek(firstDayOfWeek: .gregorianSaturday), to: d)
        case .WTDSun:       return (from: d.startOfWeek(firstDayOfWeek: .gregorianSunday), to: d)
        case .WeekTue:
            return (from: d.startOfWeek(firstDayOfWeek: .gregorianTuesday), to: d.endOfWeek(firstDayOfWeek: .gregorianTuesday))
        case .WeekWed:
            return (from: d.startOfWeek(firstDayOfWeek: .gregorianWednesday), to: d.endOfWeek(firstDayOfWeek: .gregorianWednesday))
        case .WeekThu:
            return (from: d.startOfWeek(firstDayOfWeek: .gregorianThursday), to: d.endOfWeek(firstDayOfWeek: .gregorianThursday))
        case .WeekFri:
            return (from: d.startOfWeek(firstDayOfWeek: .gregorianFriday), to: d.endOfWeek(firstDayOfWeek: .gregorianFriday))
        case .WeekSat:
            return (from: d.startOfWeek(firstDayOfWeek: .gregorianSaturday), to: d.endOfWeek(firstDayOfWeek: .gregorianSaturday))
        case .WeekSun:
            return (from: d.startOfWeek(firstDayOfWeek: .gregorianSunday), to: d.endOfWeek(firstDayOfWeek: .gregorianSunday))
        }
    }
  
}


enum UnitType: String{
    case Activity, Day
}

/* The raw values to match the Core Date syntax. Where there is a corresponding
 property in Core Data this should match it
 */
enum Unit: String{
    case AscentFeet, AscentMetres, Brick, Cadence, Hours
    case HR, KJ, KM, Miles, Minutes, Reps, RPETSS, Seconds
    case TSS, Watts, ATL, CTL, TSB, Monotony, Strain
    //do we want these here. They're day based units - not activity based units
    case fatigue, fatPercent, kg, lbs, motivation, restingHR, restingSDNN, restingRMSSD, sleep, sleepMinutes
    
    static var activityUnits = [AscentMetres,AscentFeet, Cadence, Hours, HR, KJ, KM, Miles, Minutes, Reps, RPETSS, Seconds, TSS, Watts]
    static var dayUnits = [ fatigue, fatPercent, kg, lbs, motivation, restingHR, restingSDNN, restingRMSSD, sleep, sleepMinutes]
    static var allUnits = [AscentMetres,AscentFeet, Cadence, Hours, HR, KJ, KM, Miles, Minutes, Reps, RPETSS, Seconds, TSS, Watts, ATL, CTL, TSB, Monotony, Strain, fatigue, fatPercent, kg, lbs, motivation, restingHR, restingSDNN, restingRMSSD, sleep, sleepMinutes]
    static var metrics = [ATL, CTL, TSB, Monotony, Strain]
    
    var summable: Bool{
        switch self{
        case .Cadence, .HR, .Watts, .fatigue, .fatPercent, .kg, .lbs, .motivation, .restingHR, .ATL, .CTL, .TSB: return false
        default: return true
        }
    }
    
    var isActivityBased:    Bool{ return Unit.activityUnits.contains(self) || Unit.metrics.contains(self) }
    var isMetric:           Bool{ return Unit.metrics.contains(self) }
    var allKey:             String{ return "all" + self.rawValue}
    
    func type() -> UnitType{
        if Unit.dayUnits.contains(self){
            return .Day
        }else{
            return .Activity
        }
    }
    
    func workoutPropertyName() -> String?{
        switch self{
        case .AscentFeet:    return "ascentFeet"
        case .AscentMetres:  return "ascentMetres"
        case .Brick:         return "brick"
        case .Cadence:       return "cadence"
        case .Hours:         return "hours"
        case .HR:            return "hr"
        case .KJ:            return "kj"
        case .KM:            return "km"
        case .Miles:         return "miles"
        case .Minutes:       return "minutes"
        case .Reps:          return "reps"
        case .RPETSS:        return "rpeTSS"
        case .Seconds:       return "seconds"
        case .TSS:           return "tss"
        case .Watts:         return "watts"
        //metrics
        case .ATL:           return nil
        case .CTL:           return nil
        case .TSB:           return nil
        case .Monotony:      return nil
        case .Strain:        return nil
        //Day units
        case .fatigue:       return nil
        case .fatPercent:    return nil
        case .kg:            return nil
        case .lbs:           return nil
        case .motivation:    return nil
        case .restingHR:     return nil
        case .restingSDNN:   return nil
        case .restingRMSSD:  return nil
        case .sleep:         return nil
        case .sleepMinutes:  return nil
        }
 
    }
    
    /* Responds if a unit is derived from another unit.
     */
    func isDerived() -> Bool{
        switch self{
        case .AscentFeet, .Hours, .Minutes, .Miles, .sleepMinutes: return true
        default: return false
        }
    }
    
    func dataForDerivation() -> (unit: Unit, multiple: Constant)?{
        switch self{
        case .AscentFeet: return (unit: .AscentMetres, multiple: Constant.FeetPerMetre)
        case .Minutes: return (unit: .Seconds, multiple: Constant.MinutesPerSecond)
        case .Hours: return (unit: .Seconds, multiple: Constant.HoursPerSecond)
        case .Miles: return (unit: .KM, multiple: Constant.MilesPerKM)
        case .sleepMinutes: return (unit: .sleep, multiple: Constant.SecondsPerMinute)
        default: return nil
        }
    }

}

//TO DO - This should not be an enum as the user needs to be able to set up bikes
enum BikeName: String{
    case IFXS       = "IF XS"
    case Merckx     = "Merckx"
    case P3C        = "P3C"
    case Pista      = "Pista"
    case Look576    = "Look 576"
    case Roberts    = "Roberts"
    case IFTiTT     = "IF Ti TT"
    case QRCD01     = "QR CD0.1"
    case IFSSX      = "IF SSX"
    case Giant      = "Giant"
    case Pretorius  = "Pretorius Fixed"
    case Soma       = "Soma"
    case Cannondale = "Cannondale"
    case DEMO       = "Demo Bikes"
    case Moots      = "Moots"
    case All        = "All"
    
    static var ActiveBikes = [IFXS, Merckx, P3C, Pista, Look576, Roberts, IFTiTT, IFSSX, Pretorius, DEMO]
    static var AllBikes = [IFXS, Merckx, P3C, Pista, Look576, Roberts, IFTiTT, QRCD01, IFSSX, Giant, Pretorius, Soma, Cannondale, DEMO, Moots, All]
}

//MARK: - JSON Support
// strings used in Parsing which aren't directly mapped to core data properties
enum FPMJSONString: String, FileMakerProJSONString{
    case Date           = "Date"
    case Day            = "Day"
    case Created        = "Created"
    case Workout        = "Workout"
    case Physiological  = "Physiological"
    case Measurement    = "Measurement"
    case Weight         = "Weight"
    
    func fmpString() -> String {
        return self.rawValue
    }
}

//MARK: - Core Data Entities and Properties

enum ENTITY: String{
    case TrainingDiary, Day, Workout, Weight, Physiological, Metric, Equipment
    case EddingtonNumber, EddingtonAnnualContributor, EddingtonAnnualHistory
    case EddingtonContributor, EddingtonHistory, LTDEddingtonNumber
    case Activity, ActivityType
    
    static let ALL = [.TrainingDiary, .Day, .Workout, .Weight, Physiological, .Metric, .Equipment, .EddingtonNumber, .EddingtonAnnualContributor, .EddingtonAnnualHistory, .EddingtonContributor, .EddingtonHistory, .LTDEddingtonNumber, .Activity, .ActivityType]
}

enum EquipmentProperty: String{
    case name
    case km,miles,ascentFeet,ascentMetres, seconds, tss, kj, hours, preDiaryKMs, workoutCount
    //relationships
    case workouts

}

enum MetricProperty: String{
    case activity, name, value, uniqueKey
}

enum ActivityProperty: String{
    case name, activityTypes, trainingDiary, equipment
}

enum ActivityTypeProperty: String{
    case name, activity
}

enum WeightProperty: String, FileMakerProJSONString{
    
    case fatPercent, kg, lbs
    case fromDate, toDate, recordingDate
    case trainingDiary
    
    static let jsonProperties = [recordingDate, kg, fatPercent]
    
    func fmpString() -> String {
        switch self{
        case .fatPercent:       return "Body Fat"
        case .fromDate:         return "From"
        case .kg:               return "KG"
        case .lbs:              return ""
        case .toDate:           return "To"
        case .trainingDiary:    return ""
        case .recordingDate:    return ""
        }
    }
}

enum PhysiologicalProperty: String, FileMakerProJSONString{
    case fromDate, toDate, maxHR, recordingDate
    case restingHR, restingRMSSD, restingSDNN
    case standingHR, standingRMSSD, standingSDNN
    //relationships
    case trainingDiary
    
    static let jsonProperties = [recordingDate, restingHR, restingRMSSD, restingSDNN]
    
    func fmpString() -> String {
        switch self{
        case .fromDate:         return "From"
        case .maxHR:            return "Max HR"
        case .restingHR:        return "Resting HR"
        case .restingSDNN:      return "Resting SDNN"
        case .restingRMSSD:     return "Resting rMSSD"
        case .standingHR:       return "Standing HR"
        case .standingSDNN:     return "Standing SDNN"
        case .standingRMSSD:    return "Standing RMSSD"
        case .toDate:           return "To"
        case .recordingDate:    return ""
        case .trainingDiary:    return ""
        }
    }
}

//change all to lower case start so no need to specify teh string
enum TrainingDiaryProperty: String, FileMakerProJSONString{
    case name, firstDate, lastDate
    case baseDataLastUpdate, eddingtonNumberLastUpdate
    case swimATLDays, swimCTLDays, bikeATLDays, bikeCTLDays, runATLDays, runCTLDays, atlDays, ctlDays

    //relationships
    case eddingtonNumbers, ltdEddingtonNumbers
    case days, physiologicals, weights
    case activities
    
    static let jsonProperties = [name, firstDate, lastDate ]
    
    func fmpString() -> String {
        switch self{
        case .days: return "Days"
        default: return ""
        }
    }
}

enum WorkoutProperty: String, FileMakerProJSONString{
    case activity, activityType, ascentFeet, ascentMetres, equipmentName, brick, cadence, comments, hr
    case isRace, keywords, kj, km, reps, rpe, seconds, rpeTSS, hours, miles
    case tss, tssMethod, watts, wattsEstimated, notBike, estimatedKJ
    case activityString, activityTypeString, equipmentOK, activityTypeOK
    
    static var AllProperties = [activity, activityType, activityString, activityTypeString, ascentFeet, ascentMetres, equipmentName, brick, cadence, comments, estimatedKJ, hours, hr, isRace, keywords, kj, km, reps, rpe, seconds, rpeTSS, tss, tssMethod, watts, wattsEstimated, equipmentOK, activityTypeOK]
    static var ExportProperties = [activity, activityType, equipmentName, seconds, km, rpe, tss, tssMethod, watts, wattsEstimated, hr, kj, ascentMetres, brick, cadence, isRace, keywords, reps, comments]
    static var jsonProperties = [activityString, activityTypeString, equipmentName, seconds, km, rpe, tss, tssMethod, watts, wattsEstimated, hr, kj, ascentMetres, brick, cadence, isRace, keywords, reps, comments]
    static var DoubleProperties = [ascentFeet, ascentMetres, cadence, estimatedKJ, hr, hours, kj, km, miles, reps, rpe, seconds, rpeTSS, tss, watts]
    static var StringProperties = [activityString, activityTypeString, equipmentName, comments, keywords, tssMethod]
    static var BooleanProperties = [brick, isRace, wattsEstimated, equipmentOK, activityTypeOK]
    
    func isSummable() -> Bool{
        switch self{
        case .ascentFeet, .ascentMetres, .estimatedKJ, .hours, .kj, .km, .miles, .seconds, .rpeTSS, .tss: return true
        default: return false
        }
    }
    
    //this is the string used by Filemaker Pro DB as the marker in it's JSON
    func fmpString() -> String{
        switch self{
        case .activity:             return "Sport"
        case .activityString:       return "Sport"
        case .activityType:         return "Type"
        case .activityTypeOK:       return ""
        case .activityTypeString:   return "Type"
        case .ascentMetres:         return "Ascent"
        case .ascentFeet:           return ""
        case .equipmentName:        return "Bike"
        case .equipmentOK:      return ""
        case .brick:            return "Brick"
        case .cadence:          return "Cadence"
        case .comments:         return "Comments"
        case .estimatedKJ:      return ""
        case .hours:            return ""
        case .hr:               return "Heart Rate"
        case .isRace:           return "Race"
        case .keywords:         return "Keywords"
        case .kj:               return "Kj"
        case .km:               return "KM"
        case .miles:            return ""
        case .notBike:          return ""
        case .reps:             return "Reps"
        case .rpe:              return "RPE"
        case .rpeTSS:           return "RPE TSS"
        case .seconds:          return "Seconds"
        case .tss:              return "TSS"
        case .tssMethod:        return "TSS Method"
        case .watts:            return "Power"
        case .wattsEstimated:   return "Power is estimated"
        }
    }
    
    func unit() -> Unit?{
        switch self{
        case .activity:             return nil
        case .activityString:       return nil
        case .activityType:         return nil
        case .activityTypeOK:       return nil
        case .activityTypeString:   return nil
        case .ascentMetres:         return Unit.AscentMetres
        case .ascentFeet:       return Unit.AscentFeet
        case .equipmentName:    return nil
        case .equipmentOK:      return nil
        case .brick:            return Unit.Brick
        case .cadence:          return Unit.Cadence
        case .comments:         return nil
        case .estimatedKJ:      return nil
        case .hours:            return Unit.Hours
        case .hr:               return Unit.HR
        case .isRace:           return nil
        case .keywords:         return nil
        case .kj:               return Unit.KJ
        case .km:               return Unit.KM
        case .miles:            return Unit.Miles
        case .notBike:          return nil
        case .reps:             return Unit.Reps
        case .rpe:              return nil
        case .rpeTSS:           return Unit.RPETSS
        case .seconds:          return Unit.Seconds
        case .tss:              return Unit.TSS
        case .tssMethod:        return nil
        case .watts:            return Unit.Watts
        case .wattsEstimated:   return nil
        }
    }
}


/* These are properties where a calculated property is defined in Day+Extension
 */
enum DayCalculatedProperty: String{
    case allKM, allAscentFeet, allAscentMetres, allHours, allKJ, allMinutes, allSeconds, allTSS, allTSB, allATL, allCTL
    case bikeKM, bikeAscentFeet, bikeAscentMetres, bikeHours, BikeHR, bikeKJ, bikeMinutes, bikeSeconds, bikeTSS, bikeTSB, bikeWatts
    case runKM, runAscentFeet, runAscentMetres, runHours, runHR, runKJ, runMinutes, runSeconds, runTSS, runTSB, runWatts
    case swimKM, swimHours, swimKJ, swimMinutes, swimSeconds, swimTSS, swimTSB, swimWatts
    case totalReps
    case gymTSB, walkTSB, otherTSB
    
    case numberOfWorkouts

    static let ALL = [ allKM, allAscentFeet, allAscentMetres, allHours, allKJ, allMinutes, allSeconds, allTSS, allATL, allCTL, bikeKM, bikeAscentFeet, bikeAscentMetres, bikeHours, BikeHR, bikeKJ, bikeMinutes, bikeSeconds, bikeTSS, bikeWatts, runKM, runAscentFeet, runAscentMetres, runHours, runHR, runKJ, runMinutes, runSeconds, runTSS, runWatts, swimKM, swimHours, swimKJ, swimMinutes, swimSeconds, swimTSS, swimWatts,allTSB, swimTSB, bikeTSB, runTSB, totalReps, gymTSB, walkTSB, otherTSB, numberOfWorkouts]
    
}

enum DayProperty: String, FileMakerProJSONString{
    case comments, date, iso8061DateString, fatigue, motivation, sleep, sleepQuality, type
    case workoutChanged
    case swimHours, swimKJ, swimKM, swimMinutes, swimSeconds, swimTSB, swimWatts, swimATL, swimCTL
    case bikeAscentFeet, bikeAscentMetres, bikeHR, bikeHours, bikeJ, bikeKM, bikeMinutes, bikeSeconds, bikeTSB, bikeWatts, bikeATL, bikeCTL
    case runAscentFeet, runAscentMetres, runHR, runHours, runKJ, runKM, runMinutes, runSeconds, runTSB, runWatts, runATL, runCTL
    case allAscentFeet, allAscentMetres, allHR, allHours, allKJ, allKM, allMinutes, allSeconds, allTSB, allWatts, allATL, allCTL
    case gymCTL, walkCTL, otherCTL
    case gymATL, walkATL, otherATL
    case kg, lbs, fatPercent, restingHR, restingSDNN, restingRMSSD
    case numberOfWorkouts, totalReps
    
    static let ExportProperties = [date, fatigue, motivation, sleep, sleepQuality, type, comments]
    static let jsonProperties = [iso8061DateString, fatigue, motivation, sleep, sleepQuality, type, comments]
    
    static let doubleProperties = [fatigue, motivation, sleep, swimHours, swimKJ, swimKM, swimMinutes, swimSeconds, swimTSB, swimWatts, swimATL, swimCTL, bikeAscentFeet, bikeAscentMetres, bikeHR, bikeHours, bikeJ, bikeKM, bikeMinutes, bikeSeconds, bikeTSB, bikeWatts, bikeATL, bikeCTL, runAscentFeet, runAscentMetres, runHR, runHours, runKJ, runKM, runMinutes, runSeconds, runTSB, runWatts, runATL, runCTL, allAscentFeet, allAscentMetres, allHR, allHours, allKJ, allKM, allMinutes, allSeconds, allTSB, allWatts, allATL, allCTL, gymCTL, walkCTL, otherCTL, gymATL, walkATL, otherATL, kg, lbs, fatPercent, restingSDNN, restingRMSSD, totalReps]
    static let stringProperties = [comments, sleepQuality, type]
    static let intProperties = [restingHR, numberOfWorkouts]
    static let dateProperties = [date]
    
    //relationships
    case trainingDiary, workouts, metrics

    func fmpString() -> String {
        switch self{
        case .comments:         return "Comments"
        case .date:             return "Date"
        case .fatigue:          return "Fatigue"
        case .motivation:       return "Motivation"
        case .sleep:            return "Sleep Hours"
        case .sleepQuality:     return "Sleep Quality"
        case .type:             return "Type"
        case .workouts:         return "Workouts"
        default: return ""
        }
    }
}



enum EddingtonNumberProperty: String{
    case activity, activityType, lastUpdated, maturity, period, plusOne, unit, value
    case annualContributors, annualHistory, contributors, history, trainingDiary
    //calculated:
    case eddingtonCode
}

enum LTDEddingtonNumberProperty: String{
    case activity, activityType, dayType, equipment, period, unit, code, shortCode
    case lastUpdate, maturity, plusOne, value, isWeekDay
    case children, parent
    
    static var StringProperties = [activity, activityType, dayType, equipment, period, unit, code, shortCode]
    
}

enum DayOfWeek: String{
    case Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday
    
    static var all = [Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday]
    
}


