//
//  Date+Extension.swift
//  Training Diary
//
//  Created by Steven Lord on 18/10/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Foundation


extension Date{
   
    private var gmtTZ: TimeZone{ return TimeZone(secondsFromGMT: 0)! }
    private var gregorianCalendar: Calendar{
        var cal = Calendar.init(identifier: .gregorian)
        cal = Calendar.init(identifier: .iso8601)
        cal.timeZone = gmtTZ
        return cal
    }
    

    
    private var dayOfWeekNameFormatter: DateFormatter{
        get{
            let df = DateFormatter.init()
            df.dateFormat = "EEEE"
            df.timeZone = gmtTZ
            return df
        }
    }
    
    func iso8601Format() -> String{
        let formatter = ISO8601DateFormatter()
        return formatter.string(from: self)
    }
 
    public func year() -> Int{
        let dc = gregorianCalendar.dateComponents([.year], from: self)
        if let year = dc.year{
            return year
        }else{
            return 0
        }
    }
    
    public func dayOfMonth() -> Int{
        let dc = gregorianCalendar.dateComponents([.day], from: self)
        if let day = dc.day{
            return day
        }else{
            return 0
        }
    }
    
    func dayOfMonthAndDayName() -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "ccc-dd"
        formatter.timeZone = gmtTZ
        return formatter.string(from: self)
    }
    
    public func monthAsString() -> String{
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        formatter.timeZone = gmtTZ
        return formatter.string(from: self)
    }
    
    public func addDays(numberOfDays i: Int) -> Date{
        
        let dc = DateComponents.init(calendar: Calendar.current, day: i)
        return Calendar.current.date(byAdding: dc, to: self)!
        
    }
    

    
    public func dateOnlyString() -> String{
        let dateFormatter = DateFormatter.init()
        dateFormatter.timeZone = gmtTZ
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }
    
    // added for display in charts
    public func dateOnlyShorterString() ->String{
        let dateFormatter = DateFormatter.init()
        dateFormatter.timeZone = gmtTZ
        dateFormatter.dateFormat = "dd-MMM-yy"
        return dateFormatter.string(from: self)
    }
    
    //compares just date components
    public func isSameDate(asDate: Date)-> Bool{
        let dc1 = gregorianCalendar.dateComponents([.day, .month, .year], from: asDate)
        let dc2 = gregorianCalendar.dateComponents([.day, .month, .year], from: self)
        return (dc1.day == dc2.day && dc1.month == dc2.month && dc1.year == dc2.year)
    }
    
    // compares just date components not time
    public func isYesterday(day: Date) -> Bool{
        return self.yesterday().isSameDate(asDate: day)
    }
    
    // compares just date components not time
    public func isTomorrow(day: Date) -> Bool{
        return self.tomorrow().isSameDate(asDate: day)
    }
 
    func isSunday() -> Bool{
        return gregorianCalendar.dateComponents([.weekday], from: self).weekday! == WeekDay.gregorianSunday.rawValue
    }
    func isMonday() -> Bool{
        return gregorianCalendar.dateComponents([.weekday], from: self).weekday! == WeekDay.gregorianMonday.rawValue
    }
    func isTuesday() -> Bool{
        return gregorianCalendar.dateComponents([.weekday], from: self).weekday! == WeekDay.gregorianTuesday.rawValue
    }
    func isWednesday() -> Bool{
        return gregorianCalendar.dateComponents([.weekday], from: self).weekday! == WeekDay.gregorianWednesday.rawValue
    }
    func isThursday() -> Bool{
        return gregorianCalendar.dateComponents([.weekday], from: self).weekday! == WeekDay.gregorianThursday.rawValue
    }
    func isFriday() -> Bool{
        return gregorianCalendar.dateComponents([.weekday], from: self).weekday! == WeekDay.gregorianFriday.rawValue
    }
    func isSaturday() -> Bool{
        return gregorianCalendar.dateComponents([.weekday], from: self).weekday! == WeekDay.gregorianSaturday.rawValue
    }

    public func isEndOfWeek() -> Bool{
        return gregorianCalendar.dateComponents([.weekday], from: self).weekday == 1
    }

    public func isStartOfWeek() -> Bool{
        return gregorianCalendar.dateComponents([.weekday], from: self).weekday == 2
    }
    
    public func isEndOfMonth() -> Bool{
        return !(gregorianCalendar.dateComponents([.month], from: self) == gregorianCalendar.dateComponents([.month], from: tomorrow()))
    }

    public func isStartOfMonth() -> Bool{
        return gregorianCalendar.dateComponents([.day], from: self).day! == 1
    }
    
    public func isEndOfYear() -> Bool{
        return gregorianCalendar.dateComponents([.day], from: self).day! == 31 && gregorianCalendar.dateComponents([.month], from: self).month == 12
    }

    public func isStartdOfYear() -> Bool{
        return gregorianCalendar.dateComponents([.day], from: self).day! == 1 && gregorianCalendar.dateComponents([.month], from: self).month == 1
    }

    //refactor - should be a better way ... is there always 86,400 seconds in a day ! probably never impact me !
    public func tomorrow() -> Date{
        return self.addingTimeInterval(TimeInterval.init(Constant.SecondsPerDay.rawValue))
    }
    
    //refactor - should be a better way ... is there always 86,400 seconds in a day ! probably never impact me !
    public func yesterday() -> Date{
        return self.addingTimeInterval(TimeInterval.init(-Constant.SecondsPerDay.rawValue))
    }
    
    public func dayOfWeekName() -> String{
        return dayOfWeekNameFormatter.string(from: self)
    }
    
    //return start of day - ie time component 00:00:00
    public func startOfDay() -> Date{
        var dc = gregorianCalendar.dateComponents([.day, .month,.year], from: self)
        dc.hour = 0
        dc.minute = 0
        dc.second = 0
        return gregorianCalendar.date(from: dc)!
    }
    
    public func endOfDay() -> Date{
        //var dc = gregorianCalendar().dateComponents([.day, .month,.year], from: self)
        var dc = gregorianCalendar.dateComponents([.day, .month,.year], from: self)
        dc.hour = 23
        dc.minute = 59
        dc.second = 59
//        return gregorianCalendar().date(from: dc)!
        return gregorianCalendar.date(from: dc)!
    }

    
    public func startOfYear() -> Date{
        var dc = gregorianCalendar.dateComponents([.day, .month,.year], from: self)
        dc.day = 1
        dc.month = 1
        dc.hour = 0
        dc.minute = 0
        dc.second = 0
        return gregorianCalendar.date(from: dc)!
    }
    
    public func endOfYear() -> Date{
        var dc = gregorianCalendar.dateComponents([.day, .month,.year], from: self)
        dc.day = 31
        dc.month = 12
        dc.hour = 23
        dc.minute = 59
        dc.second = 59
        return gregorianCalendar.date(from: dc)!
    }
   
    public func startOfMonth() -> Date{
        var dc = gregorianCalendar.dateComponents([.day, .month,.year], from: self)
        dc.day = 1
        dc.hour = 0
        dc.minute = 0
        dc.second = 0
        return gregorianCalendar.date(from: dc)!
    }
    
    public func endOfMonth() -> Date{
        let components = DateComponents(day:1)
        let startOfNextMonth = gregorianCalendar.nextDate(after:self, matching: components, matchingPolicy: .nextTime)!
        let d = gregorianCalendar.date(byAdding:.day, value: -1, to: startOfNextMonth)!
        return d.endOfDay()
    }
    
    public func startOfWeek() -> Date{
        var cal = gregorianCalendar
        cal.firstWeekday = WeekDay.gregorianMonday.rawValue
        cal.firstWeekday = WeekDay.gregorianMonday.rawValue
        var components = cal.dateComponents([.weekOfYear, .year], from: self)
        components.weekday = WeekDay.gregorianMonday.rawValue
        return cal.date(from: components)!

    }
    
    func startOfWeek(firstDayOfWeek: WeekDay) -> Date{
        var cal = gregorianCalendar
        cal.firstWeekday = firstDayOfWeek.rawValue
        var components = cal.dateComponents([.weekOfYear, .year], from: self)
        components.weekday = firstDayOfWeek.rawValue
        return cal.date(from: components)!
    }

    
    public func endOfWeek() -> Date{
        var cal = gregorianCalendar
        cal.firstWeekday = WeekDay.gregorianMonday.rawValue
        var components = cal.dateComponents([.weekOfYear, .year], from: self)
        components.weekday = WeekDay.gregorianSunday.rawValue
        return cal.date(from: components)!
    }
    
    func endOfWeek(firstDayOfWeek: WeekDay) -> Date{
        var cal = gregorianCalendar
        cal.firstWeekday = firstDayOfWeek.rawValue
        var components = cal.dateComponents([.weekOfYear, .year], from: self)
        components.weekday = firstDayOfWeek.previousWeekDay().rawValue
        return cal.date(from: components)!
    }
    
    public func startOfRWeek() -> Date{
        //note minus 6 as RWeek is inclusive - ie 7 days includes first and last day
        let dc  = DateComponents.init(day: -6 )
        return gregorianCalendar.date(byAdding: dc, to: self)!
    }

    
    //note just uses 30 days
    public func startOfRMonth() -> Date{
        // note minus 29 as this is inclusive ... so period will be 30
        let dc  = DateComponents.init(day: -29 )
        return gregorianCalendar.date(byAdding: dc, to: self)!
    }
    
    //note just uses 365 days
    public func startOfRYear() -> Date{
        //note minute 364 as this is inclusive... so period will be 365
        let dc  = DateComponents.init(day: -364 )
        return gregorianCalendar.date(byAdding: dc, to: self)!
    }
    
}
