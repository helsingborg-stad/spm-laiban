//
//  ClockEvent.swift
//
//  Created by Tomas Green on 2019-12-04.
//

import Foundation


public struct ClockEvent : Codable, Identifiable, Equatable,Hashable {
    public let id:String
    public var time:String
    public var emoji:String
    public var title:String
    public var text:String? {
        var arr = [String]()
        arr.append(title)
        arr.append(emoji)
        if arr.isEmpty {
            return nil
        }
        return arr.joined(separator: " ")
    }
    public var date:Date? {
        return relativeDateFrom(time: time)
    }
    public init() {
        self.id = UUID().uuidString
        self.emoji = ""
        self.title = ""
        self.time = timeStringfrom(date: Date())
    }
    public init(date:Date, emoji:String, title:String) {
        self.id = UUID().uuidString
        self.time = timeStringfrom(date: date)
        self.emoji = emoji
        self.title = title
    }
    public init(time:String, emoji:String, title:String) {
        self.id = UUID().uuidString
        self.time = time
        self.emoji = emoji
        self.title = title
    }
    public init(id:String, time:String, emoji:String, title:String) {
        self.id = id
        self.time = time
        self.emoji = emoji
        self.title = title
    }
}
