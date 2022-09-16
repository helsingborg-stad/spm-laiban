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
    public init() {
        self.id = UUID().uuidString
        self.content = ""
        self.icon = nil
        self.date = Date()
    }
    public init(date:Date, content:String,icon:String?) {
        self.id = UUID().uuidString
        self.date = date
        self.content = content
        self.icon = icon
    }
    public init(id:String, date:Date, content:String,icon:String?) {
        self.id = id
        self.date = date
        self.content = content
        self.icon = icon
    }
}
