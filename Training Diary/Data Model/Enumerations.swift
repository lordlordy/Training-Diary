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

enum TSSMethod: String{
    case RPE
    case TRIMPS
    case PacePower
    
    static var AllMethods = [RPE, TRIMPS, PacePower]
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
    
    static var AllTypes = [Normal, Race, Holiday, Rest, Recovery, Travel, Injured, Niggle, Ill]
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
}


//MARK: -  Base Data Support

enum Period: String{
    case Day            = "Day"
    case Week           = "Week"
    case Month          = "Month"
    case Year           = "Year"
    case WeekToDate     = "WTD"
    case MonthToDate    = "MTD"
    case YearToDate     = "YTD"
    case rWeek          = "RWeek"
    case rMonth         = "RMonth"
    case rYear          = "RYear"
    case Lifetime       = "Lifetime"
    case Adhoc          = "Adhoc"
    
    static var eddingtonNumberPeriods = [Day,Week,Month,Year, WeekToDate,MonthToDate, YearToDate,rWeek,rMonth,rYear]
    static var All = [Day,Week,Month,Year, WeekToDate,MonthToDate, YearToDate,rWeek,rMonth,rYear, Lifetime, Adhoc]
    
    
    /* Returns the periods range of dates for a given date. This gives the period this ends with except where this doesn't make sense
     when it gives period this date is within.
     Returns period ending on date for: Day, WeekToDate, MonthToDate, YearToDate, rWeek, rMonth and rYear
     Returns period containing the date for: Week, Month, Year
     Adhoc and Lifetime make no sense just just returns same as Day for now.
     */
    public func periodRange(forDate d: Date) -> (from: Date, to: Date){
        switch self{
        case .Day, .Adhoc, .Lifetime:
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
        }
    }
  
}

/* Need to decide what to do with activity type "ALLActivities" ... it's not quite right. It's not an activity. Perhaps I need
 to allow nil in certain case with activity and that mens all of them.
*/
enum Activity: String{
    case Swim 
    case Bike
    case Run
    case Gym
    case Walk
    case Other
    case All   // special case to indicate this is any and all activities
    
    static var allActivities = [Swim,Bike,Run,Gym,Walk,Other,All]
    
    func keyString(forUnit unit: Unit) -> String{
        return self.rawValue.lowercased() + unit.rawValue
    }
    
    func validTypes() -> [ActivityType]{
        switch self{
        case .Swim:
            return [ .Solo, .Squad, .OpenWater, .All ]
        case .Bike:
            return [ .Road, .OffRoad, .Turbo, .All ]
        case .Run:
            return [ .Road, .OffRoad, .Fell, .Treadmill, .All ]
        case .Gym:
            return [.General, .PressUp, .All ]
        case .Walk:
            return [.All ]
        case .Other:
            return [ .Stepper, .Aquajog, .Kayak, .All ]
        case .All:
            return [ .All ]
        }
    }
    
    func validUnits() -> Set<Unit>{
        switch self{
        case .Swim:
            return [ .Hours, .KJ, .KM, .Miles, .Minutes, .RPETSS, .Seconds, .TSS, .Watts, .ATL, .CTL, .TSB ]
        case .Bike:
            return [ .AscentMetres, .AscentFeet,  .Cadence, .Hours, .HR, .KJ, .KM, .Miles, .Minutes, .RPETSS, .Seconds, .TSS, .Watts, .ATL, .CTL, .TSB ]
        case .Run:
            return [ .AscentMetres, .AscentFeet,  .Cadence, .Hours, .HR, .KJ, .KM, .Miles, .Minutes, .RPETSS, .Seconds, .TSS, .Watts, .ATL, .CTL, .TSB ]
        case .Gym:
            return [ .Hours, .KJ, .Minutes, .Reps, .RPETSS, .Seconds, .TSS, .ATL, .CTL, .TSB ]
        case .Walk:
            return [ .AscentMetres, .AscentFeet, .Hours, .HR, .KJ, .KM, .Miles, .Minutes, .RPETSS, .Seconds, .TSS, .ATL, .CTL, .TSB ]
        case .Other:
            return [ .Hours, .HR, .KJ, .Minutes, .RPETSS, .Seconds, .TSS, .ATL, .CTL, .TSB ]
        case .All:
            return [ .AscentMetres, .AscentFeet,  .Cadence, .Hours, .HR, .KJ, .KM, .Miles, .Minutes, .Reps, .RPETSS, .Seconds, .TSS, .Watts, .ATL, .CTL, .TSB ]
        }
    }
    

}

enum ActivityType: String{
    case Solo
    case Squad
    case OpenWater
    case Road
    case OffRoad
    case Turbo
    case Fell
    case Treadmill
    case General
    case PressUp
    case Stepper
    case Aquajog
    case Kayak
    case All
    
    static var AllActivityTypes = [Solo,Squad,OpenWater,Road,OffRoad,Turbo,Fell, Treadmill, General, PressUp, Stepper, Aquajog, Kayak, All]
    
    func validUnits() -> Set<Unit>{
        switch self{
        case .Solo:
            return [ .Hours, .KJ, .KM, .Miles, .Minutes, .RPETSS, .Seconds, .TSS, .Watts]
        case .Squad:
            return [ .Hours, .KJ, .KM, .Miles, .Minutes, .RPETSS, .Seconds, .TSS, .Watts]
        case .OpenWater:
            return [ .Hours, .KJ, .KM, .Miles, .Minutes, .RPETSS, .Seconds, .TSS, .Watts]
        case .Road:
            return [ .AscentMetres, .AscentFeet, .Cadence, .Hours, .HR, .KJ, .KM, .Miles, .Minutes, .RPETSS, .Seconds, .TSS, .Watts]
        case .OffRoad:
            return [ .AscentMetres, .AscentFeet, .Cadence, .Hours, .HR, .KJ, .KM, .Miles, .Minutes, .RPETSS, .Seconds, .TSS, .Watts]
        case .Turbo:
            return [ .Cadence, .Hours, .HR, .KJ, .KM, .Miles, .Minutes, .RPETSS, .Seconds, .TSS, .Watts]
        case .Fell:
            return [ .AscentMetres, .AscentFeet, .Cadence, .Hours, .HR, .KJ, .KM, .Miles, .Minutes, .RPETSS, .Seconds, .TSS, .Watts]
        case .Treadmill:
            return [ .Cadence, .Hours, .HR, .KJ, .KM, .Miles, .Minutes, .RPETSS, .Seconds, .TSS, .Watts]
        case .General:
            return [ .Hours, .Minutes, .RPETSS, .Seconds, .TSS]
        case .PressUp:
            return [ .Hours, .KJ, .Minutes, .Reps, .RPETSS, .Seconds, .TSS]
        case .Stepper:
            return [ .AscentMetres, .AscentFeet, .Hours, .HR, .KJ, .Minutes, .RPETSS, .Seconds, .TSS]
        case .Aquajog:
            return [ .Hours, .HR, .KJ, .Minutes, .RPETSS, .Seconds, .TSS]
        case .Kayak:
            return [ .Hours, .HR, .KJ, .KM, .Miles, .Minutes, .RPETSS, .Seconds, .TSS]
        case .All:
            return [ .AscentMetres, .AscentFeet, .Cadence, .Hours, .HR, .KJ, .KM, .Miles, .Minutes, .Reps, .RPETSS, .Seconds, .TSS, .Watts, .ATL, .CTL, .TSB]
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
    case TSS, Watts, ATL, CTL, TSB
    //do we want these here. They're day based units - not activity based units
    case fatigue, fatPercent, kg, lbs, motivation, restingHR, sleep
    
    static var activityUnits = [AscentMetres,AscentFeet, Cadence, Hours, HR, KJ, KM, Miles, Minutes, Reps, RPETSS, Seconds, TSS, Watts, ATL, CTL, TSB]
    static var dayUnits = [ fatigue, fatPercent, kg, lbs, motivation, restingHR, sleep]
    static var allUnits = [AscentMetres,AscentFeet, Cadence, Hours, HR, KJ, KM, Miles, Minutes, Reps, RPETSS, Seconds, TSS, Watts, ATL, CTL, TSB, fatigue, fatPercent, kg, lbs, motivation, restingHR, sleep]
    static var metrics = [ATL, CTL, TSB]
    
    var summable: Bool{
        switch self{
        case .Cadence, .HR, .Watts, .fatigue, .fatPercent, .kg, .lbs, .motivation, .restingHR, .sleep, .ATL, .CTL, .TSB: return false
        default: return true
        }
    }
    
    var isActivityBased:    Bool{ return Unit.activityUnits.contains(self) }
    var isMetric:           Bool{ return Unit.metrics.contains(self) }

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
        //Day units
        case .fatigue:       return nil
        case .fatPercent:    return nil
        case .kg:            return nil
        case .lbs:           return nil
        case .motivation:    return nil
        case .restingHR:     return nil
        case .sleep:         return nil
        }
 
    }
    
    /* Responds if a unit is derived from another unit.
     */
    func isDerived() -> Bool{
        switch self{
        case .AscentFeet, .Hours, .Minutes, .Miles: return true
        default: return false
        }
    }
    
    func dataForDerivation() -> (unit: Unit, multiple: Constant)?{
        switch self{
        case .AscentFeet: return (unit: .AscentMetres, multiple: Constant.FeetPerMetre)
        case .Minutes: return (unit: .Seconds, multiple: Constant.MinutesPerSecond)
        case .Hours: return (unit: .Seconds, multiple: Constant.HoursPerSecond)
        case .Miles: return (unit: .KM, multiple: Constant.MilesPerKM)
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
    case TrainingDiary, Day, Workout, Weight, Physiological, Metric, Bike
    case EddingtonNumber, EddingtonAnnualContributor, EddingtonAnnualHistory
    case EddingtonContributor, EddingtonHistory, LTDEdNum
}

enum BikeProperty: String{
    case name
    case km,miles,ascentFeet,ascentMetres, seconds, tss, kj, hours, rides, preDiaryKMs
    //relationships
    case workouts

}

enum MetricProperty: String{
    case activity, name, value, uniqueKey
}

enum WeightProperty: String, FileMakerProJSONString{
    
    case fatPercent, kg, lbs
    case fromDate, toDate
    case trainingDiary
    
    func fmpString() -> String {
        switch self{
        case .fatPercent:    return "Body Fat"
        case .fromDate:         return "From"
        case .kg:               return "KG"
        case .lbs:              return ""
        case .toDate:           return "To"
        case .trainingDiary:    return ""
        }
    }
}

enum PhysiologicalProperty: String, FileMakerProJSONString{
    case fromDate, toDate, maxHR
    case restingHR, restingRMSSD, restingSDNN
    case standingHR, standingRMSSD, standingSDNN
    //relationships
    case trainingDiary
    
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
        case .trainingDiary:    return ""
        }
    }
}

//change all to lower case start so no need to specify teh string
enum TrainingDiaryProperty: String, FileMakerProJSONString{
    case name
    case baseDataLastUpdate, eddingtonNumberLastUpdate
    case swimATLDays, swimCTLDays, bikeATLDays, bikeCTLDays, runATLDays, runCTLDays, atlDays, ctlDays

    //relationships
    case eddingtonNumbers, lTDEdNumbers
    case days, physiologicals, weights
    
    func fmpString() -> String {
        switch self{
        case .days: return "Days"
        default: return ""
        }
    }
}

enum WorkoutProperty: String, FileMakerProJSONString{
    case activity, activityType, ascentFeet, ascentMetres, bike, brick, cadence, comments, hr
    case isRace, keywords, kj, km, reps, rpe, seconds, rpeTSS, hours, miles
    case tss, tssMethod, watts, wattsEstimated, notBike
    
    static var AllProperties = [activity, activityType, ascentFeet, ascentMetres, bike, brick, cadence, comments, hours, hr, isRace, keywords, kj, km, reps, rpe, seconds, rpeTSS, tss, tssMethod, watts, wattsEstimated, notBike]
    static var DoubleProperties = [ascentFeet, ascentMetres, cadence, hr, hours, kj, km, miles, rpe, seconds, rpeTSS, tss, watts]
    
    func isSummable() -> Bool{
        switch self{
        case .ascentFeet, .ascentMetres, .hours, .kj, .km, .miles, .seconds, .rpeTSS, .tss: return true
        default: return false
        }
    }
    
    //this is the string used by Filemaker Pro DB as the marker in it's JSON
    func fmpString() -> String{
        switch self{
        case .activity:         return "Sport"
        case .activityType:     return "Type"
        case .ascentMetres:     return "Ascent"
        case .ascentFeet:       return ""
        case .bike:             return "Bike"
        case .brick:            return "Brick"
        case .cadence:          return "Cadence"
        case .comments:         return "Comments"
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
        case .activity:         return nil
        case .activityType:     return nil
        case .ascentMetres:     return Unit.AscentMetres
        case .ascentFeet:       return Unit.AscentFeet
        case .bike:             return nil
        case .brick:            return Unit.Brick
        case .cadence:          return Unit.Cadence
        case .comments:         return nil
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
    case gymTSB, walkTSB, otherTSB
    
    case numberOfWorkouts

    static let ALL = [ allKM, allAscentFeet, allAscentMetres, allHours, allKJ, allMinutes, allSeconds, allTSS, allATL, allCTL, bikeKM, bikeAscentFeet, bikeAscentMetres, bikeHours, BikeHR, bikeKJ, bikeMinutes, bikeSeconds, bikeTSS, bikeWatts, runKM, runAscentFeet, runAscentMetres, runHours, runHR, runKJ, runMinutes, runSeconds, runTSS, runWatts, swimKM, swimHours, swimKJ, swimMinutes, swimSeconds, swimTSS, swimWatts,allTSB, swimTSB, bikeTSB, runTSB, gymTSB, walkTSB, otherTSB, numberOfWorkouts]
    
    static let ExportProperties = [ allKM, allSeconds, bikeKM, bikeSeconds, runKM,  runSeconds,  swimKM,  swimSeconds]
}

enum DayProperty: String, FileMakerProJSONString{
    case comments, date, fatigue, motivation, sleep, sleepQuality, type
    case workoutChanged
    case swimCTL, bikeCTL, runCTL, gymCTL, walkCTL, otherCTL, allCTL
    case swimATL, bikeATL, runATL, gymATL, walkATL, otherATL, allATL
    
    static let ExportProperties = [date, fatigue, motivation, sleep, sleepQuality, type, comments]
    
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


