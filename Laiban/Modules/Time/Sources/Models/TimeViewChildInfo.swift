//
//  TempusChildInfo.swift
//  Laiban
//
//  Created by Tomas Green on 2021-12-09.
//

import Foundation

public struct TimeViewChildInfo : Identifiable {
    public var id:String
    public var name:String
    public var avatar:URL?
    public var arrivesTime:String? = nil
    public var leavesTime:String? = nil
    public var arrivesDate:Date? = nil
    public var leavesDate:Date? = nil
    public var isHereToday:Bool = false
    public var nextAttendance:Date? = nil
    public init(
        id:String = UUID().uuidString,
        name:String,
        avatar:URL?,
        arrivesTime:String? = nil,
        leavesTime:String? = nil,
        arrivesDate:Date? = nil,
        leavesDate:Date? = nil,
        isHereToday:Bool = false,
        nextAttendance:Date? = nil
    ) {
        self.id = id
        self.name = name
        self.avatar = avatar
        self.arrivesTime = arrivesTime
        self.leavesTime = leavesTime
        self.arrivesDate = arrivesDate
        self.leavesDate = leavesDate
        self.isHereToday = isHereToday
        self.nextAttendance = nextAttendance
    }
}
