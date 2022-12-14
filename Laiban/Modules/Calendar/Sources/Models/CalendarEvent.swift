//
//  CalendarEvent.swift
//
//  Created by Tomas Green on 2019-12-04.
//

import Foundation

public struct CalendarEvent : Codable,Identifiable,Hashable {
    public let id:String
    public var date:Date
    public var content:String
    public var icon:String?
    public var type:EventType?
    public init() {
        self.id = UUID().uuidString
        self.content = ""
        self.icon = nil
        self.date = Date()
        self.type = .userEvent
    }
    public init(date:Date, content:String,icon:String?,type:EventType) {
        self.id = UUID().uuidString
        self.date = date
        self.content = content
        self.icon = icon
        self.type = type
    }
    public init(id:String, date:Date, content:String,icon:String?,type:EventType) {
        self.id = id
        self.date = date
        self.content = content
        self.icon = icon
        self.type = type
    }
    public enum EventType: Codable {
        case userEvent
        case fetchedEvent
    }
}
