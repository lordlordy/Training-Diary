//
//  Constants.swift
//  Training Diary
//
//  Created by Steven Lord on 17/10/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//


import Foundation

protocol TrainingDiaryPropertyProtocol{
    //string for key value protocol
    func propertyName() -> String
    //user friendly name
    func displayName() -> String
}

enum JSONGenerator: String{
    case SwiftTrainingDiary, FileMakerProTrainingDiary
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
    
    static let All: [WeekDay] = [.gregorianMonday, .gregorianTuesday, .gregorianWednesday, .gregorianThursday, .gregorianFriday, .gregorianSaturday, .gregorianSunday]
    
    func name() -> String{
        switch self{
        case .gregorianSunday:      return "Sunday"
        case .gregorianMonday:      return "Monday"
        case .gregorianTuesday:     return "Tuesday"
        case .gregorianWednesday:   return "Wednesday"
        case .gregorianThursday:    return "Thursday"
        case .gregorianFriday:      return "Friday"
        case .gregorianSaturday:    return "Saturday"
        }
    }
    
}

enum FileExtension: String{
    case json, csv, html
    
    static let exportTypes = [json, csv, html]
    static let importTypes = [json, csv]
    
}

enum TSSMethod: String{
    case RPE
    case TRIMPS
    case PacePower
    
    static var AllMethods = [RPE, TRIMPS, PacePower]
}

//these will be included with the app and cannot be deleted.
enum FixedActivity: String{
    case Swim, Bike, Run, Gym, Walk, Other
    static let All = [Swim, Bike, Run, Gym, Walk, Other]
}

enum DayType: String{
    case Normal, Race, Holiday, Rest, Recovery, Travel, Injured, Niggle, Ill, Camp
    case Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday
    case January, February, March, April, May, June, July, August, September, October, November, December

    static var InputTypes = [Normal, Race, Camp, Holiday, Rest, Recovery, Travel, Injured, Niggle, Ill]
    static var DerivedTypes = [Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday, January, February, March, April, May, June, July, August, September, October, November, December]
    
    static var AllTypes = [Normal, Race, Holiday, Rest, Recovery, Travel, Injured, Niggle, Ill, Camp,Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday, January, February, March, April, May, June, July, August, September, October, November, December]
    
    func isDerived() -> Bool{
        return DayType.DerivedTypes.contains(self)
    }
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
    case WorkoutThresholdForEdNumberCount = 0
}

enum ConstantString: String{
    case EddingtonAll       = "All"
    case NotSet             = "Not Set"
}


//MARK: -  Base Data Support

enum Period: String{
    case Day            = "Day"
    case Week           = "Wk-Mon"
    case WeekTue        = "Wk-Tue"
    case WeekWed        = "Wk-Wed"
    case WeekThu        = "Wk-Thu"
    case WeekFri        = "Wk-Fri"
    case WeekSat        = "Wk-Sat"
    case WeekSun        = "Wk-Sun"
    case WeekToDate     = "WTD-Mon"
    case WTDTue         = "WTD-Tue"
    case WTDWed         = "WTD-Wed"
    case WTDThu         = "WTD-Thu"
    case WTDFri         = "WTD-Fri"
    case WTDSat         = "WTD-Sat"
    case WTDSun         = "WTD-Sun"
    case rWeek          = "RWeek"
    case Month          = "Month"
    case MonthToDate    = "MTD"
    case rMonth         = "RMonth"
    case Year           = "Year"
    case YearToDate     = "YTD"
    case rYear          = "RYear"
    case Lifetime       = "Lifetime"
    case Adhoc          = "Adhoc"
    case Workout        = "Workout"

    static var eddingtonNumberPeriods = [Day, Week, Month, Year, WeekToDate, MonthToDate, YearToDate, rWeek, rMonth, rYear, WeekTue, WeekWed, WeekThu, WeekFri, WeekSat, WeekSun, WTDTue, WTDWed, WTDThu, WTDFri, WTDSat, WTDSun, Workout]
    static var All = [Day,Week,Month,Year, WeekToDate,MonthToDate, YearToDate,rWeek,rMonth,rYear, Lifetime, Adhoc, WeekTue, WeekWed, WeekThu, WeekFri, WeekSat, WeekSun, WTDTue, WTDWed, WTDThu, WTDFri, WTDSat, WTDSun, Workout]
    
    
    func size() -> Int{
        switch self{
        case .Workout, .Day:
            return 1
        case .Week, .WeekTue, .WeekWed, .WeekThu, .WeekFri, .WeekSat, .WeekSun, .WeekToDate, .WTDTue, .WTDWed, .WTDThu, .WTDFri, .WTDSat, .WTDSun, .rWeek:
            return 7
        case .Month, .MonthToDate, .rMonth:
            return 31
        case .rYear:
            return 365
        case .Year, .YearToDate:
            return 366
        case .Lifetime:
            return Int.max
        case .Adhoc:
            return 0
        }
    }
    
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

enum AggregationMethod: String{
    case Sum, Mean, WeightedMean
    case None // special case where aggregating just a single thing eg Day
    static let All: [AggregationMethod] = [.Sum, .Mean, .WeightedMean]
}

enum UnitType: String{
    case Activity, Day
}

/* The raw values to match the Core Date syntax. Where there is a corresponding
 property in Core Data this should match it
 */
enum Unit: String{
    case ascentFeet, ascentMetres, brick, cadence, hours
    case hr, kj, km, miles, minutes, reps, rpeTSS, seconds, rpe
    case tss, watts, atl, ctl, tsb, monotony, strain
    //do we want these here. They're day based units - not activity based units
    case fatigue, fatPercent, kg, lbs, motivation, restingHR, restingSDNN, restingRMSSD, sleep, sleepMinutes
    
    static var activityUnits = [ascentMetres, ascentFeet,cadence, hours, hr, kj, km, miles, minutes, reps, rpeTSS, seconds, tss, watts, brick]
    static var dayUnits = [ fatigue, fatPercent, kg, lbs, motivation, restingHR, restingSDNN, restingRMSSD, sleep, sleepMinutes]
    static var allUnits = [ascentMetres, ascentFeet, cadence, hours, hr, kj, km, miles, minutes, reps, rpeTSS, seconds, tss, watts, atl, ctl, tsb, monotony, strain, fatigue, fatPercent, kg, lbs, motivation, restingHR, restingSDNN, restingRMSSD, sleep, sleepMinutes]
    static var metrics = [atl, ctl, tsb, monotony, strain]
    static var csvExportUnits = [ascentMetres, brick, cadence, hr, kj, km, reps, rpe, tss, watts, seconds ]
    
 /*   var summable: Bool{
        switch self{
        case .cadence, .hr, .watts, .fatigue, .fatPercent, .kg, .lbs, .motivation, .restingHR, .atl, .ctl, .tsb: return false
        default: return true
        }
    }
 */
    var isActivityBased:    Bool{ return Unit.activityUnits.contains(self) || Unit.metrics.contains(self) }
    var isMetric:           Bool{ return Unit.metrics.contains(self) }
    var allKey:             String{ return "all" + self.rawValue}
    
    func defaultAggregator() -> AggregationMethod{
        switch self{
        case .cadence, .hr, .watts, .rpe: return AggregationMethod.WeightedMean
        case .fatigue, .fatPercent, .kg, .lbs, .motivation, .restingHR, .atl, .ctl, .tsb: return AggregationMethod.Mean
        default: return AggregationMethod.Sum
        }
        
    }
    
    func type() -> UnitType{
        if Unit.dayUnits.contains(self){
            return .Day
        }else{
            return .Activity
        }
    }
    
 /*   func workoutPropertyName() -> String?{
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
 */
    /* Responds if a unit is derived from another unit.
     */
    func isDerived() -> Bool{
        switch self{
        case .ascentFeet, .hours, .minutes, .miles, .sleepMinutes: return true
        default: return false
        }
    }
    
    func dataForDerivation() -> (unit: Unit, multiple: Constant)?{
        switch self{
        case .ascentFeet: return (unit: .ascentMetres, multiple: Constant.FeetPerMetre)
        case .minutes: return (unit: .seconds, multiple: Constant.MinutesPerSecond)
        case .hours: return (unit: .seconds, multiple: Constant.HoursPerSecond)
        case .miles: return (unit: .km, multiple: Constant.MilesPerKM)
        case .sleepMinutes: return (unit: .sleep, multiple: Constant.SecondsPerMinute)
        default: return nil
        }
    }

}

//MARK: - Core Data Entities and Properties

enum ENTITY: String{
    case TrainingDiary, Day, Workout, Weight, Physiological, Metric, Equipment
    case EddingtonNumber, EddingtonAnnualContributor, EddingtonAnnualHistory
    case EddingtonContributor, EddingtonHistory, LTDEddingtonNumber
    case Activity, ActivityType
    case Plan, PlanDay, BasicWeekDay
    
    static let ALL = [.TrainingDiary, .Day, .Workout, .Weight, Physiological, .Metric, .Equipment, .EddingtonNumber, .EddingtonAnnualContributor, .EddingtonAnnualHistory, .EddingtonContributor, .EddingtonHistory, .LTDEddingtonNumber, .Activity, .ActivityType, .Plan, .PlanDay, .BasicWeekDay]
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
    case atlDecay, atlImpact, atlDecayFactor, atlImpactFactor
    case ctlDecay, ctlImpact, ctlDecayFactor, ctlImpactFactor
    case targetCTL, ctlHalfLife, atlHalfLife, effectAfterReplacementDays
}

enum ActivityTypeProperty: String{
    case name, activity
}

enum WeightProperty: String{
    
    case fatPercent, kg, lbs, basalCalsPerDay, bmi
    case fromDate, iso8061DateString, fromDateString
    case trainingDiary
    
    static let jsonProperties = [iso8061DateString, kg, fatPercent]
    static let csvProperties = [fromDateString, kg, fatPercent]

}

enum PhysiologicalProperty: String{
    case fromDate, maxHR, iso8061DateString, fromDateString
    case restingHR, restingRMSSD, restingSDNN
    case standingHR, standingRMSSD, standingSDNN
    //relationships
    case trainingDiary
    
    static let jsonProperties = [iso8061DateString, restingHR, restingRMSSD, restingSDNN]
    static let csvProperties = [fromDateString, restingHR, restingRMSSD, restingSDNN]

}

//change all to lower case start so no need to specify teh string
enum TrainingDiaryProperty: String{
    case name
    case athleteHeightCM, athleteName, athleteDOB, athleteDOBString
    case hrvEasyPercentile, hrvHardPercentile, hrvOffPercentile
    case monotonyDays, awakeBasalFactor

    //relationships
    case eddingtonNumbers, ltdEddingtonNumbers
    case days, physiologicals, weights, plans
    case activities
    
//    static let jsonProperties = [name, athleteHeightCM, athleteName, athleteDOB, hrvEasyPercentile, hrvHardPercentile, hrvOffPercentile, monotonyDays, awakeBasalFactor ]
    static let jsonProperties = [name, athleteHeightCM, athleteName, athleteDOBString, hrvEasyPercentile, hrvHardPercentile, hrvOffPercentile, monotonyDays, awakeBasalFactor ]

}

enum WorkoutProperty: String{
    case activity, activityType, equipment, ascentFeet, ascentMetres, equipmentName, brick, cadence, comments, hr
    case isRace, keywords, kj, km, reps, rpe, seconds, rpeTSS, hours, miles
    case tss, tssMethod, watts, wattsEstimated, notBike, estimatedKJ
    case activityString, activityTypeString, equipmentOK, activityTypeOK
    case secondsPerKM, secondsPer100m, kph
    
    static var AllProperties = [activity, activityType, activityString, activityTypeString, ascentFeet, ascentMetres, equipment, equipmentName, brick, cadence, comments, estimatedKJ, hours, hr, isRace, keywords, kj, km, reps, rpe, seconds, rpeTSS, tss, tssMethod, watts, wattsEstimated, equipmentOK, activityTypeOK]
    static var jsonProperties = [activityString, activityTypeString, equipmentName, seconds, km, rpe, tss, tssMethod, watts, wattsEstimated, hr, kj, ascentMetres, brick, cadence, isRace, keywords, reps, comments]
    static var csvProperties = [activityString, activityTypeString, equipmentName, seconds, km, rpe, tss, tssMethod, watts, wattsEstimated, hr, kj, ascentMetres, brick, cadence, isRace, keywords, reps, comments]
    static var DoubleProperties = [ascentFeet, ascentMetres, cadence, estimatedKJ, hr, hours, kj, km, miles, reps, rpe, seconds, secondsPerKM, secondsPer100m, kph, rpeTSS, tss, watts]
    static var StringProperties = [activityString, activityTypeString, equipmentName, comments, keywords, tssMethod]
    static var BooleanProperties = [brick, isRace, wattsEstimated, equipmentOK, activityTypeOK]
    
    func isSummable() -> Bool{
        switch self{
        case .ascentFeet, .ascentMetres, .estimatedKJ, .hours, .kj, .km, .miles, .seconds, .rpeTSS, .tss: return true
        default: return false
        }
    }
    
    func unit() -> Unit?{
        switch self{
        case .ascentMetres:     return Unit.ascentMetres
        case .ascentFeet:       return Unit.ascentFeet
        case .brick:            return Unit.brick
        case .cadence:          return Unit.cadence
        case .hours:            return Unit.hours
        case .hr:               return Unit.hr
        case .kj:               return Unit.kj
        case .km:               return Unit.km
        case .miles:            return Unit.miles
        case .reps:             return Unit.reps
        case .rpeTSS:           return Unit.rpeTSS
        case .seconds:          return Unit.seconds
        case .tss:              return Unit.tss
        case .watts:            return Unit.watts
        case .activity, .activityString, .activityType, .activityTypeOK, .activityTypeString, .equipment, .equipmentName, .equipmentOK, .comments, .estimatedKJ, .isRace, .keywords, .notBike, .rpe, .tssMethod, .wattsEstimated, .secondsPerKM, .secondsPer100m, .kph:
            return nil
        }
    }
 
}


/* These are properties where a calculated property is defined in Day+Extension
 */
enum DayCalculatedProperty: String{
    case allKM, allAscentFeet, allAscentMetres, allHours, allKJ, allMinutes, allSeconds, allTSS, allTSB, allATL, allCTL
    case bikeKM, bikeAscentFeet, bikeAscentMetres, bikeHours, bikeHR, bikeKJ, bikeMinutes, bikeSeconds, bikeTSS, bikeTSB, bikeWatts
    case runKM, runAscentFeet, runAscentMetres, runHours, runHR, runKJ, runMinutes, runSeconds, runTSS, runTSB, runWatts
    case swimKM, swimHours, swimKJ, swimMinutes, swimSeconds, swimTSS, swimTSB, swimWatts
    case totalReps
    case gymTSB, walkTSB, otherTSB
    case gmt
    
    case numberOfWorkouts

    static let ALL = [ allKM, allAscentFeet, allAscentMetres, allHours, allKJ, allMinutes, allSeconds, allTSS, allATL, allCTL, bikeKM, bikeAscentFeet, bikeAscentMetres, bikeHours, bikeHR, bikeKJ, bikeMinutes, bikeSeconds, bikeTSS, bikeWatts, runKM, runAscentFeet, runAscentMetres, runHours, runHR, runKJ, runMinutes, runSeconds, runTSS, runWatts, swimKM, swimHours, swimKJ, swimMinutes, swimSeconds, swimTSS, swimWatts,allTSB, swimTSB, bikeTSB, runTSB, totalReps, gymTSB, walkTSB, otherTSB, numberOfWorkouts]
    
}

enum DayProperty: String{
    case comments, date, iso8061DateString, dateCSVString, fatigue, motivation, sleep, sleepQuality, type
    case workoutChanged
    case swimHours, swimKJ, swimKM, swimMinutes, swimSeconds, swimTSB, swimWatts, swimATL, swimCTL, swimStrain, swimTSS
    case bikeAscentFeet, bikeAscentMetres, bikeHR, bikeHours, bikeKJ, bikeKM, bikeMinutes, bikeSeconds, bikeTSB, bikeWatts, bikeATL, bikeCTL, bikeStrain, bikeTSS
    case runAscentFeet, runAscentMetres, runHR, runHours, runKJ, runKM, runMinutes, runSeconds, runTSB, runWatts, runATL, runCTL, runStrain, runTSS
    case allAscentFeet, allAscentMetres, allHR, allHours, allKJ, allKM, allMinutes, allSeconds, allTSB, allWatts, allATL, allCTL, allStrain
    case gymCTL, walkCTL, otherCTL
    case gymATL, walkATL, otherATL
    case kg, lbs, fatPercent, restingHR, restingSDNN, restingRMSSD
    case numberOfWorkouts, totalReps
    case basalCalsMiffLinStJeor, basalCalKatchMcArdle
    case estimatedCaloriesMifflinStJeor, estimatedCaloriesKatchMcArdle
    
    static let csvProperties = [dateCSVString, fatigue, motivation, sleep, sleepQuality, type, comments]
    static let weightProperties = [kg, fatPercent]
    static let physiologicalProperties = [restingHR, restingSDNN, restingRMSSD]
    static let jsonProperties = [iso8061DateString, fatigue, motivation, sleep, sleepQuality, type, comments]
    static let workoutProperties = [bikeKM, bikeAscentMetres, bikeHR, bikeKJ, bikeSeconds, bikeTSS, bikeWatts, runKM, runAscentMetres, runHR, runKJ, runSeconds, runTSS, runWatts, swimKM, swimKJ, swimSeconds, swimTSS, swimWatts, totalReps, numberOfWorkouts]
    
    
    static let doubleProperties = [fatigue, motivation, sleep, swimHours, swimKJ, swimKM, swimMinutes, swimSeconds, swimTSB, swimWatts, swimATL, swimCTL, swimStrain, bikeAscentFeet, bikeAscentMetres, bikeHR, bikeHours, bikeKJ, bikeKM, bikeMinutes, bikeSeconds, bikeTSB, bikeWatts, bikeATL, bikeCTL, bikeStrain, runAscentFeet, runAscentMetres, runHR, runHours, runKJ, runKM, runMinutes, runSeconds, runTSB, runWatts, runATL, runCTL, runStrain, allAscentFeet, allAscentMetres, allHR, allHours, allKJ, allKM, allMinutes, allSeconds, allTSB, allWatts, allATL, allCTL, allStrain, gymCTL, walkCTL, otherCTL, gymATL, walkATL, otherATL, kg, lbs, fatPercent, restingSDNN, restingRMSSD, totalReps]
    static let stringProperties = [comments, sleepQuality, type, iso8061DateString, dateCSVString]
    static let intProperties = [restingHR, numberOfWorkouts]
    static let dateProperties = [date]
    
    //relationships
    case trainingDiary, workouts, metrics

}



enum EddingtonNumberProperty: String{
    case activity, activityType, lastUpdated, maturity, period, plusOne, unit, value
    case annualContributors, annualHistory, contributors, history, trainingDiary
    //calculated:
    case eddingtonCode
    
    static var jsonProperties = [activity, activityType, maturity, period, plusOne, unit, value, eddingtonCode]
    static var csvProperties = [activity, activityType, maturity, period, plusOne, unit, value, eddingtonCode]
}

enum LTDEddingtonNumberProperty: String{
    case activity, activityType, dayType, equipment, period, unit, code, shortCode
    case lastUpdate, maturity, plusOne, value, isWeekDay, isMonth
    case children, parent
    
    static var StringProperties = [activity, activityType, dayType, equipment, period, unit, code, shortCode]
    static var jsonProperties = [activity, activityType, dayType, equipment, period, unit, code, shortCode, maturity, plusOne, value]
    static var csvProperties = [value, shortCode, plusOne, maturity, dayType, activity, activityType, equipment, period, unit]
}

enum EddingtonHistoryProperty: String{
    case date, max, plusOne, value
    case maturity, iso8061DateString, dateCSVString
    
    static let jsonProperties = [max, plusOne, value, maturity, iso8061DateString]
    static let csvProperties = [max, plusOne, value, maturity, dateCSVString]
    
}

enum EddingtonAnnualHistoryProperty: String{
    case date, plusOne, value
    case iso8061DateString, dateCSVString
    
    static let jsonProperties = [plusOne, value, iso8061DateString]
    static let csvProperties = [plusOne, value, dateCSVString]
    
}

enum EddingtonContributorProperty: String{
    case date, value
    case iso8061DateString, dateCSVString
    
    static let jsonProperties = [value, iso8061DateString]
    static let csvProperties = [value, dateCSVString]
    
}


enum DayOfWeek: String{
    case Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday
    
    static var all = [Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday]
    
}

enum Month: String{
    case January, February, March, April, May, June, July, August, September, October, November, December
    static var all = [ January, February, March, April, May, June, July, August, September, October, November, December ]

}

enum PlanProperty: String, TrainingDiaryPropertyProtocol{
    case from, name, to, planDaysCount, locked
    case bikeStartATL, bikeStartCTL, runStartATL, runStartCTL, swimStartATL, swimStartCTL
    case basicWeek, planDays, trainingDiary
    case iso8061FromString, iso8061ToString
    case csvFromString, csvToString

    static let jsonProperties = [iso8061FromString, iso8061ToString, name, locked, bikeStartATL, bikeStartCTL, runStartATL, runStartCTL, swimStartATL, swimStartCTL]
    static let csvProperties = [csvFromString, csvToString, name, locked, bikeStartATL, bikeStartCTL, runStartATL, runStartCTL, swimStartATL, swimStartCTL]
    
    func propertyName() -> String { return self.rawValue }
    func displayName() -> String{
        switch self{
        case .from, .iso8061FromString, .csvFromString: return "From"
        case .to, .iso8061ToString, .csvToString: return "To"
        default: return self.rawValue
        }
    }

    
}

enum PlanDayProperty: String, TrainingDiaryPropertyProtocol{
    case swimATL, swimCTL, swimTSS, swimTSB
    case bikeATL, bikeCTL, bikeTSS, bikeTSB
    case runATL, runCTL, runTSS, runTSB
    case allATL, allCTL, allTSS, allTSB
    case actualSwimATL, actualSwimCTL, actualSwimTSS, actualSwimTSB
    case actualBikeATL, actualBikeCTL, actualBikeTSS, actualBikeTSB
    case actualRunATL, actualRunCTL, actualRunTSS, actualRunTSB
    case actualAllATL, actualAllCTL, actualAllTSS, actualAllTSB
    case actualThenPlanSwimATL, actualThenPlanSwimCTL, actualThenPlanSwimTSB
    case actualThenPlanBikeATL, actualThenPlanBikeCTL, actualThenPlanBikeTSB
    case actualThenPlanRunATL, actualThenPlanRunCTL, actualThenPlanRunTSB
    case actualThenPlanAllATL, actualThenPlanAllCTL, actualThenPlanAllTSB
    case basicWeekTotalSwimTSS, basicWeekTotalBikeTSS, basicWeekTotalRunTSS, basicWeekTotalAllTSS
    case date, comments, plan
    case iso8061DateString
    case csvDateString, planName
    
    static let jsonProperties = [swimATL, swimCTL, swimTSS, bikeATL, bikeCTL, bikeTSS, runATL, runCTL, runTSS, actualSwimATL, actualSwimCTL, actualSwimTSS, actualBikeATL, actualBikeCTL, actualBikeTSS, actualRunATL, actualRunCTL, actualRunTSS, actualThenPlanSwimATL, actualThenPlanSwimCTL, actualThenPlanBikeATL, actualThenPlanBikeCTL, actualThenPlanRunATL, actualThenPlanRunCTL, iso8061DateString, comments]

    static let csvProperties = [swimATL, swimCTL, swimTSS, bikeATL, bikeCTL, bikeTSS, runATL, runCTL, runTSS, actualSwimATL, actualSwimCTL, actualSwimTSS, actualBikeATL, actualBikeCTL, actualBikeTSS, actualRunATL, actualRunCTL, actualRunTSS, actualThenPlanSwimATL, actualThenPlanSwimCTL, actualThenPlanSwimTSB, actualThenPlanBikeATL, actualThenPlanBikeCTL, actualThenPlanBikeTSB, actualThenPlanRunATL, actualThenPlanRunCTL, actualThenPlanRunTSB, actualThenPlanAllATL, actualThenPlanAllCTL, actualThenPlanAllTSB, csvDateString, comments, planName]
    
    func propertyName() -> String {
        return self.rawValue
    }
    
    func displayName() -> String{
        return self.rawValue
    }
    
}

enum BasicWeekDayProperty: String, TrainingDiaryPropertyProtocol{
    case swimPercentage, swimTSS
    case bikePercentage, bikeTSS
    case runPercentage, runTSS
    case name, order, totalTSS, comments
    case planName
    
    static var observables: [BasicWeekDayProperty] = [.swimTSS, .bikeTSS, .runTSS]
    static let jsonProperties = [swimPercentage, swimTSS, bikePercentage, bikeTSS, runPercentage, runTSS, name, order, comments]
    static var csvProperties = [name, swimTSS, bikeTSS, runTSS, comments, swimPercentage, bikePercentage, runPercentage, planName, order]
    
    func propertyName() -> String {
        return self.rawValue
    }
    
    func displayName() -> String {
        return self.rawValue
    }
}




