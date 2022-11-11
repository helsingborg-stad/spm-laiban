//
//  CalendarViewManager.swift
//
//  Created by Tomas Green on 2020-04-21.
//

import Foundation
import Combine
import SwiftUI
import PublicCalendar

import Assistant

class CalendarViewModel : ObservableObject {
    weak var service:CalendarService? = nil
    weak var assistant:Assistant? = nil
    weak var contentProvider:CalendarContentProvider? = nil
    var cancellables = Set<AnyCancellable>()
    
    @Published var title:String = ""
    @Published var voiceStrings = [String]()
    @Published var eventString:String? = nil
    @Published var eventIcon:String = "🎉"
    @Published var selectedDay = DayView.Day.current {
        didSet{
            self.todaysEvents = service?.calendarEvents(on: selectedDay.day) ?? []
            voiceStrings = []
            title = todayString
            eventString = nil
            update()
        }
    }
    @Published var todaysEvents:[CalendarEvent] = [CalendarEvent]()
    
    var formattedDate:String {
        guard let assistant = assistant else {
            return "ERROR"
        }
        let d = DateFormatter()
        d.dateFormat = assistant.string(forKey: "schedule_date_format")
        d.locale = assistant.locale
        return d.string(from: selectedDay.day)
    }
    var todayString:String {
        guard let assistant = assistant else {
            return "ERROR"
        }
        if selectedDay.isToday {
            return assistant.formattedString(forKey: "current_date", self.formattedDate)
        }
        return assistant.formattedString(forKey: "calendar_title_date", self.formattedDate)
    }
    func localizedString(for event:CalendarEvent) -> String {
        guard let assistant = assistant else {
            return "ERROR"
        }
        return assistant.string(forKey: event.content)
    }

    func localizedString(for event:PublicCalendar.Event) -> String {
        guard let assistant = assistant else {
            return "ERROR"
        }
        let e = assistant.string(forKey: event.title)
        if event.date.today {
            return assistant.formattedString(forKey: "public_calendar_celebration_today", e)
        }
        return assistant.formattedString(forKey: "public_calendar_celebration", e)
    }
    
    var otherEvents = [OtherCalendarEvent]()
    
    func update() {
        guard let assistant = assistant, let service = service else {
            return
        }
        
        var strings = [title]
        strings.append(assistant.string(forKey: selectedDay.descriptionKey))
        if let event = service.calendarEvents(on: selectedDay.day).first {
            eventString = localizedString(for: event)
            eventIcon = event.icon ?? "🗓"
        } else if let event = otherEvents.first(where: { $0.date.isSameDay(as: selectedDay.day) }) {
            eventString = assistant.string(forKey: event.title)
            eventIcon = event.emoji ?? "🗓"
        }
        if let h = eventString {
            strings.append(h)
            //strings.append(assistant.string(forKey: "calendar_free_day"))
        }
        assistant.speak(strings)
    }
    func initiate(with service:CalendarService, and assistant:Assistant, contentProvider:CalendarContentProvider?) {
        self.service = service
        self.assistant = assistant
        self.contentProvider = contentProvider
        self.todaysEvents = service.todaysCalendarEvents
        self.selectedDay = DayView.Day.current
        contentProvider?.otherCalendarEventsPublisher().sink { events in
            self.otherEvents = events ?? []
            self.update()
        }.store(in: &cancellables)
    }
    func didTap(day:DayView.Day) {
        self.selectedDay = day
    }
}
