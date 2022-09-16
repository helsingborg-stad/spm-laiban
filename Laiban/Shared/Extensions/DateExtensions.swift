//
//  DateExtensions.swift
//
//  Created by Tomas Green on 2019-12-05.
//

import Foundation
import Assistant

public extension Date {
    private static var _defaultCalendar:Calendar?
    
    static var defaultCalendar:Calendar {
        if _defaultCalendar == nil {
            var c = Calendar(identifier: Calendar.Identifier.gregorian)
            c.firstWeekday = 2
            self._defaultCalendar = c
        }
        return _defaultCalendar!
    }
    var year:Int {
        Self.defaultCalendar.component(.year, from: self)
    }
    var month:Int {
        Self.defaultCalendar.component(.month, from: self)
    }
    var day:Int {
        Self.defaultCalendar.component(.day, from: self)
    }
    var hour:Int {
        Self.defaultCalendar.component(.hour, from: self)
    }
    var minute:Int {
        Self.defaultCalendar.component(.minute, from: self)
    }
    var second:Int {
        Self.defaultCalendar.component(.second, from: self)
    }
    var actualWeekDay:Int {
        let d = Self.defaultCalendar.component(.weekday, from: self)
        return d == 1 ? 7 : d - 1
    }
    var today:Bool {
        self.isSameDay(as: Date())
    }
    static func date(year:Int,month:Int,day:Int = 1,time:String = "00:00:00") -> Date? {
        let d = DateFormatter()
        d.dateFormat = "y-M-d'T'HH:mm:ss"
        return d.date(from: "\(year)-\(month)-\(day)T\(time)")
    }
    var startOfDay:Date? {
        Self.date(year: self.year, month: self.month, day: self.day)
    }
    var endOfDay:Date? {
        Self.date(year: self.year, month: self.month, day: self.day,time: "23:59:59")
    }
    var yesterDay:Date? {
        Self.defaultCalendar.date(byAdding: .day, value: -1, to: self)
    }
    var tomorrow:Date? {
        Self.defaultCalendar.date(byAdding: .day, value: 1, to: self)
    }
    var startOfWeek:Date? {
        Self.defaultCalendar.date(from: Self.defaultCalendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))
    }
    func isSameDay(as date:Date) -> Bool {
        Self.defaultCalendar.isDate(date, inSameDayAs: self)
    }
    func dateOffsetBy(months:Int) -> Date? {
        Self.defaultCalendar.date(byAdding: .month, value: months, to: self)
    }
    func dateOffsetBy(days:Int) -> Date? {
        Self.defaultCalendar.date(byAdding: .day, value: days, to: self)
    }
    static func numberOfDaysBetween(from: Date?, to:Date?) -> Int? {
        guard let from = from, let to = to else {
            return nil
        }
        let fromDate = Self.defaultCalendar.startOfDay(for: from)
        let toDate = Self.defaultCalendar.startOfDay(for: to)
        let numberOfDays = Self.defaultCalendar.dateComponents([.day], from: fromDate, to: toDate)
        return numberOfDays.day!
    }
}
public func timeStringfrom(date:Date) -> String {
    let f = DateFormatter()
    f.dateFormat = "HH:mm"
    return f.string(from: date)
}

public func relativeDateFrom(time:String,date:Date = Date()) -> Date {
    let month = Date.defaultCalendar.component(.month, from: date)
    let year = Date.defaultCalendar.component(.year, from: date)
    let day = Date.defaultCalendar.component(.day, from: date)
    let str = "\(year)-\(month)-\(day)T\(time)"
    let f = DateFormatter()
    f.dateFormat = "Y-M-d'T'HH:mm"
    
    return f.date(from: str)!
}
extension Date {
    func textHour(using assistant:Assistant) -> String {
        var h = self.hour
        if h > 12 {
            h = h - 12
        }
        let m = Int((Double(self.minute)/5).rounded())
        if m >= 5 {
            h += 1
        }
        if h > 12 {
            h = h - 12
        }
        return assistant.string(forKey: "clock_time_\(h)")
    }
    func textMinute(using assistant:Assistant) -> String? {
        let m = Int((Double(self.minute)/5).rounded())
        if m == 0 || m == 12 {
            return nil
        }
        return assistant.string(forKey: "clock_time_minute_\(m)")
    }
    func textTime(using assistant:Assistant) -> String {
        let h = textHour(using: assistant)
        if let m = textMinute(using: assistant) {
            return "\(m) \(h)"
        }
        return h
    }
    func digitalTime(using assistant:Assistant) -> String {
        let h = self.hour
        var m = Int((Double(self.minute)/5).rounded())
        let hs = h < 10 ? "0\(h)" : "\(h)"
        if m == 0 || m == 12 {
            return "\(hs):00"
        }
        m *= 5
        if m < 10 {
            return "\(hs):0\(m)"
        }
        return "\(hs):\(m)"
    }
    func string(format: String) -> String {
        let df = DateFormatter()
        df.dateFormat = format
        return df.string(from: self)
    }
}
