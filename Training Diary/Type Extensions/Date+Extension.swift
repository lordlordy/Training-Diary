//
//  Date+Extension.swift
//  Training Diary
//
//  Created by Steven Lord on 18/10/2017.
//  Copyright © 2017 Steven Lord. All rights reserved.
//

import Foundation

extension Date{
   
    
    private var dayOfWeekNameFormatter: DateFormatter{
        get{
            let df = DateFormatter.init()
            df.dateFormat = "EEEE"
            df.timeZone = TimeZone.init(secondsFromGMT: 0)
            return df
        }
    }
 
    private var calendar: Calendar{
        get{
            var cal = Calendar.init(identifier: .gregorian)
            //should we use this instead so start of week is Monday?
            cal = Calendar.init(identifier: .iso8601)
            cal.timeZone = TimeZone.init(secondsFromGMT: 0)!
            return cal
        }
    }
    
    public func year() -> Int{
        let dc = calendar.dateComponents([.year], from: self)
        if let year = dc.year{
            return year
        }else{
            return 0
        }
    }
    
    public func addDays(numberOfDays i: Int) -> Date{
        
        let dc = DateComponents.init(calendar: Calendar.current, day: i)
        return Calendar.current.date(byAdding: dc, to: self)!
        
    }
    

    
    public func dateOnlyString() -> String{
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }
    
    // added for display in charts
    public func dateOnlyShorterString() ->String{
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "dd-MMM-yy"
        return dateFormatter.string(from: self)
    }
    
    //compares just date components
    public func isSameDate(asDate: Date)-> Bool{
        let dc1 = calendar.dateComponents([.day, .month, .year], from: asDate)
        let dc2 = calendar.dateComponents([.day, .month, .year], from: self)
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
 

    public func isEndOfWeek() -> Bool{
        let dayOfWeek = calendar.dateComponents([.weekday], from: self)
        return dayOfWeek.weekday == 1
    }

    public func isStartOfWeek() -> Bool{
        let dayOfWeek = calendar.dateComponents([.weekday], from: self)
        return dayOfWeek.weekday == 2
    }
    
    public func isEndOfMonth() -> Bool{
        let monthNow = calendar.dateComponents([.month], from: self)
        let monthTomorrow = calendar.dateComponents([.month], from: tomorrow())
        return !(monthNow == monthTomorrow)
    }

    public func isStartOfMonth() -> Bool{
        return calendar.dateComponents([.day], from: self).day! == 1
    }
    
    public func isEndOfYear() -> Bool{
        let dayOfMonth = calendar.dateComponents([.day], from: self)
        let month = calendar.dateComponents([.month], from: self)
        return dayOfMonth.day! == 31 && month.month == 12
    }

    public func isStartdOfYear() -> Bool{
        let dayOfMonth = calendar.dateComponents([.day], from: self)
        let month = calendar.dateComponents([.month], from: self)
        return dayOfMonth.day! == 1 && month.month == 1
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
        var dc = calendar.dateComponents([.day, .month,.year], from: self)
        dc.hour = 0
        dc.minute = 0
        dc.second = 0
        return calendar.date(from: dc)!
    }
    
    public func endOfDay() -> Date{
        var dc = calendar.dateComponents([.day, .month,.year], from: self)
        dc.hour = 23
        dc.minute = 59
        dc.second = 59
        return calendar.date(from: dc)!
    }

    
    public func startOfYear() -> Date{
        var dc = calendar.dateComponents([.day, .month,.year], from: self)
        dc.day = 1
        dc.month = 1
        dc.hour = 0
        dc.minute = 0
        dc.second = 0
        return calendar.date(from: dc)!
    }
    
    public func endOfYear() -> Date{
        var dc = calendar.dateComponents([.day, .month,.year], from: self)
        dc.day = 31
        dc.month = 12
        dc.hour = 23
        dc.minute = 59
        dc.second = 59
        return calendar.date(from: dc)!
    }
   
    public func startOfMonth() -> Date{
        var dc = calendar.dateComponents([.day, .month,.year], from: self)
        dc.day = 1
        dc.hour = 0
        dc.minute = 0
        dc.second = 0
        return calendar.date(from: dc)!
    }
    
    public func endOfMonth() -> Date{
        let components = DateComponents(day:1)
        let startOfNextMonth = calendar.nextDate(after:self, matching: components, matchingPolicy: .nextTime)!
        return calendar.date(byAdding:.day, value: -1, to: startOfNextMonth)!
    }
    
    public func startOfWeek() -> Date{
        var components = calendar.dateComponents([.weekOfYear, .year], from: self)
        components.weekday = 2
        return calendar.date(from: components)!
    }
    
    public func endOfWeek() -> Date{
        var components = calendar.dateComponents([.weekOfYear, .year], from: self)
        components.weekday = 1
        return calendar.date(from: components)!
    }
    
    public func startOfRWeek() -> Date{
        //note minus 6 as RWeek is inclusive - ie 7 days includes first and last day
        let dc  = DateComponents.init(day: -6 )
        return calendar.date(byAdding: dc, to: self)!
    }
    
    //note just uses 30 days
    public func startOfRMonth() -> Date{
        // note minus 29 as this is inclusive ... so period will be 30
        let dc  = DateComponents.init(day: 29 )
        return calendar.date(byAdding: dc, to: self)!
    }
    
    //note just uses 365 days
    public func startOfRYear() -> Date{
        //note minute 364 as this is inclusive... so period will be 365
        let dc  = DateComponents.init(day: -364 )
        return calendar.date(byAdding: dc, to: self)!
    }
    
}
