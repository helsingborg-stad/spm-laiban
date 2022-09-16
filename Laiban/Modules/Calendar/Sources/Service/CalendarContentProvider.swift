//
//  CalendarContentProvider.swift
//  LaibanApp
//
//  Created by Tomas Green on 2022-05-18.
//

import Foundation
import Combine

public struct OtherCalendarEvent {
    public let date:Date
    public let title:String
    public let emoji:String?
    public init(date:Date, title:String, emoji:String?) {
        self.date = date
        self.title = title
        self.emoji = emoji
    }
}

public protocol CalendarContentProvider : AnyObject {
    func otherCalendarEventsPublisher() -> AnyPublisher<[OtherCalendarEvent]?,Never>
}
