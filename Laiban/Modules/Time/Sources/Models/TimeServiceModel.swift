//
//  TimeService.swift
//  LaibanApp
//
//  Created by Tomas Green on 2022-05-17.
//

import Foundation

public struct TimeServiceModel : Codable, Equatable, Hashable {
    public var dayStarts = "06:00"
    public var dayEnds = "18:00"
    public var events:[ClockEvent] = []
    /// move to service
    public static var defaultValues:[ClockEvent] {
        var arr = [ClockEvent]()
        arr.append(ClockEvent(time: "07:00", emoji: "🥣", title: "Frukost"))
        arr.append(ClockEvent(time: "09:00", emoji: "🍎", title: "Fruktstund"))
        arr.append(ClockEvent(time: "11:30", emoji: "🍽", title: "Lunch"))
        arr.append(ClockEvent(time: "14:30", emoji: "🥪", title: "Mellanmål"))
        return arr
    }
}
