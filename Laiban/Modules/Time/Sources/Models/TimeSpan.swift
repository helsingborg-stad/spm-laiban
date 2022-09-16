//
//  TimeSpan.swift
//
//  Created by Tomas Green on 2020-03-18.
//

import Foundation


struct TimeSpan : Hashable {
    var from:Date
    var to:Date
    var localizedKey:String
    init(date:Date = Date(),from:String,to:String) {
        self.from = relativeDateFrom(time: from, date: date)
        self.to = relativeDateFrom(time: to, date: date)
        let f = from.replacingOccurrences(of: ":", with: "")
        let t = to.replacingOccurrences(of: ":", with: "")
        self.localizedKey = "clock_time_description_\(f)_to_\(t)"
    }
    static func createSpans(with date:Date) -> [TimeSpan] {
        return [
            TimeSpan(date:date, from:"06:00", to:"07:30"),
            TimeSpan(date:date, from:"07:30", to:"08:30"),
            TimeSpan(date:date, from:"08:30", to:"09:00"),
            TimeSpan(date:date, from:"09:00", to:"10:45"),
            TimeSpan(date:date, from:"10:45", to:"12:30"),
            TimeSpan(date:date, from:"12:30", to:"14:00"),
            TimeSpan(date:date, from:"14:00", to:"15:00"),
            TimeSpan(date:date, from:"15:00", to:"16:30"),
            TimeSpan(date:date, from:"16:30", to:"18:00"),
            TimeSpan(date:date, from:"18:00", to:"20:00"),
            TimeSpan(date:date, from:"20:00", to:"06:00")
        ]
    }
    
    static func currentTimeLabel(date:Date = Date()) -> TimeSpan? {
        for s in createSpans(with: date) {
            if s.from <= date && s.to >= date {
                return s
            }
        }
        return nil
    }
}
