//
//  TimeViewManager.swift
//
//  Created by Tomas Green on 2020-03-20.
//

import Foundation
import Combine
import SwiftUI
import PublicCalendar
import Assistant
import Analytics

class TimeViewModel : ObservableObject {
    weak var service:TimeService? = nil
    weak var assistant:Assistant? = nil
    var clockViewModel = ClockViewModel()
    @Published var todayTexts = [LBVoiceString]()
    @Published var tempusTexts = [LBVoiceString]()
    @Published var showChildInfo:Bool = false
    @Published var selectedChild:TimeViewChildInfo?
    @Published var children = [TimeViewChildInfo]()
    @Published var arrivesClockViewModel:ClockViewModel? = nil
    @Published var leavesClockViewModel:ClockViewModel? = nil
    @Published var arrivesTitle:String? = nil
    @Published var leavesTitle:String? = nil
    @Published var otherClockItems = [ClockItem]()
    func setChildInfoVisible(_ visible:Bool) {
        guard showChildInfo != visible else {
            return
        }
        guard let assistant = assistant else {
            return
        }
        withAnimation(Animation.spring()) {
            showChildInfo = visible
            if showChildInfo {
                self.tempusTexts = [.init(assistant.string(forKey: "clock_select_person"), id: "clock_select_person")]
                assistant.speak(tempusTexts.compactMap({ $0.voice }))
            } else {
                self.arrivesClockViewModel = nil
                self.leavesClockViewModel = nil
                self.selectedChild = nil
                self.updateTodayTexts()
            }
        }
    }
    func createClockModel() -> ClockViewModel {
        let model = ClockViewModel()
        model.timeSpanBackgroundColor = Color("WatchColorHoursDimmed", bundle: .module)
        model.timeSpanColor = Color("WatchColorHours", bundle: .module)
        model.itemBorderColor = Color("WatchColorRimAlternate", bundle: .module)
        model.hoursHandColor = Color("WatchColorHours", bundle: .module)
        model.minutesHandColor = Color("WatchColorMinutes", bundle: .module)
        model.items = self.clockViewModel.items
        model.showShadow = true
        return model
    }
    func currentRelativeTime(for date: Date) -> String {
        let f = RelativeDateTimeFormatter()
        f.dateTimeStyle = .named
        f.locale = assistant?.locale ?? .current
        return f.localizedString(for: date, relativeTo: Date())
    }
    func currentTime() -> LBVoiceString {
        guard let assistant = assistant else {
            return LBVoiceString(display: "ERROR", voice: "ERROR")
        }
        let date = Date()
        let f = DateFormatter()
        f.timeStyle = .short
        f.dateStyle = .none
        f.locale = assistant.locale
        let voice = assistant.formattedString(forKey: "clock_current_time", date.textTime(using: assistant).description.lowercased())
        let display = assistant.formattedString(forKey: "clock_current_time", f.string(from: date))
        return LBVoiceString(display: display, voice: voice, object: date, id: "current_time")
    }
    func shouldRepeat() {
        if showChildInfo {
            let strings = self.tempusTexts.compactMap { (s) -> String in s.voice }
            assistant?.speak(strings)
        } else {
            let strings = self.todayTexts.compactMap { (s) -> String in s.voice }
            assistant?.speak(strings)
        }
    }
    func localizedString(for item:ClockItem) -> String {
        guard let assistant = assistant else {
            return "ERROR"
        }
        return assistant.string(forKey: item.text) + " " + currentRelativeTime(for: item.date)
    }
    func localizedString(for event:PublicCalendar.Event) -> String {
        guard let assistant = assistant else {
            return "ERROR"
        }
        let e = assistant.string(forKey: event.title)
        return assistant.formattedString(forKey: "public_calendar_event", e)
    }
    func initiate(using assistant:Assistant, service:TimeService, bundle:Bundle = .module) {
        self.assistant = assistant
        self.service = service
        clockViewModel.timeSpanBackgroundColor = Color("WatchColorHoursDimmed", bundle: bundle)
        clockViewModel.timeSpanColor = Color("WatchColorHours", bundle: bundle)
        clockViewModel.itemBorderColor = Color("WatchColorRimAlternate", bundle: bundle)
        clockViewModel.hoursHandColor = Color("WatchColorHours", bundle: bundle)
        clockViewModel.minutesHandColor = Color("WatchColorMinutes", bundle: bundle)
        clockViewModel.showShadow = true
     
        update()
    }
    func update() {
        self.updateTodayTexts()
        if showChildInfo, let c = self.selectedChild {
            self.select(c)
        }
        if assistant?.isSpeaking == false {
            shouldRepeat()
        }
    }
    
    func updateTodayTexts(endingWith text:LBVoiceString? = nil) {
        guard let assistant = assistant else {
            return
        }
        
        var newEmojis = [ClockItem]()
        service?.data.events.forEach({ (event) in
            if let date = event.date {
                if let text = event.text {
                    newEmojis.append(
                        .init(
                            emoji: event.emoji,
                            date: date,
                            text: assistant.string(forKey: text),
                            tag: "clockevent"
                        )
                    )
                }
            }
        })
        newEmojis.append(contentsOf: otherClockItems)
        self.clockViewModel.items = newEmojis
        if let dayEnds = service?.data.dayEnds {
            self.clockViewModel.dayEnds = dayEnds
        }
        if let dayStarts = service?.data.dayStarts {
            self.clockViewModel.dayStarts = dayStarts
        }
        todayTexts = []
        todayTexts.append(currentTime())
        if let text = text {
            todayTexts.append(text)
        } else if let ts = TimeSpan.currentTimeLabel() {
            todayTexts.append(.init(assistant.string(forKey: ts.localizedKey), id: "now?"))
        }
    }
    func showText(text:LBVoiceString, speakAfter:Bool) {
        self.updateTodayTexts(endingWith: text)
        if speakAfter {
            assistant?.speak(text.voice)
        }
    }
    var referenceDate:Date {
        //        if Device.isPreview || Device.isSimulator {
        //            let timeFormatter = DateFormatter()
        //            timeFormatter.dateFormat = "HH:mm"
        //            let dateFormatter = DateFormatter()
        //            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        //            let now = timeFormatter.string(from: Date())
        //            return dateFormatter.date(from: "2021-10-12T"+now)!
        //        }
        return Date()
    }
    func select(_ child:TimeViewChildInfo) {
        selectedChild = child
        let refDate = referenceDate
        self.tempusTexts = [getPresenceLabel(for: child, at: refDate)]
        self.arrivesClockViewModel = getArrivesViewModel(for: child, at: refDate)
        self.leavesClockViewModel = getLeavesViewModel(for: child, at: refDate)
        self.arrivesTitle = getArrivesTitle(for: child, at: refDate)
        self.leavesTitle = getLeavesTitle(for: child, at: refDate)
        assistant?.speak(tempusTexts.compactMap({ $0.voice }))
    }
    func showLeavesLabel() {
        guard let child = selectedChild else {
            return
        }
        let refDate = referenceDate
        self.tempusTexts = [getLeavesLabel(for: child, at: refDate)]
        assistant?.speak(tempusTexts.compactMap({ $0.voice }))
    }
    func showArrivesLabel() {
        guard let child = selectedChild else {
            return
        }
        let refDate = referenceDate
        self.tempusTexts = [getArrivesLabel(for: child, at: refDate)]
        assistant?.speak(tempusTexts.compactMap({ $0.voice }))
    }
    func getArrivesTitle(for child:TimeViewChildInfo, at refDate:Date = Date()) -> String? {
        guard let assistant = assistant else {
            return nil
        }
        guard let arrives = child.arrivesTime, let arrivesDate = child.arrivesDate else {
            return nil
        }
        return assistant.formattedString(forKey: refDate < arrivesDate ? "tempus_arrives_short" : "tempus_arrives_short_past", child.name,arrives)
    }
    func getLeavesTitle(for child:TimeViewChildInfo, at refDate:Date = Date()) -> String? {
        guard let assistant = assistant else {
            return nil
        }
        guard let leaves = child.leavesTime, let leavesDate = child.leavesDate else {
            return nil
        }
        return assistant.formattedString(forKey: refDate < leavesDate ? "tempus_leaves_short" : "tempus_leaves_short_past", child.name,leaves)
    }
    func getArrivesViewModel(for child:TimeViewChildInfo, at refDate:Date = Date()) -> ClockViewModel? {
        guard let arrives = child.arrivesTime, let leaves = child.leavesTime, let arrivesDate = child.arrivesDate, let leavesDate = child.leavesDate else {
            return nil
        }
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let now = timeFormatter.string(from: refDate)
        
        let clockModel = createClockModel()
        if refDate > leavesDate {
            clockModel.dayStarts = arrives
            clockModel.dayEnds = leaves
        } else if refDate < arrivesDate {
            clockModel.dayStarts = now
            clockModel.dayEnds = arrives
        } else {
            clockModel.dayStarts = arrives
            clockModel.dayEnds = now
        }
        clockModel.showTimeSpan = true
        clockModel.timeLock = arrivesDate
        clockModel.showClockSeconds = false
        clockModel.items = self.clockViewModel.items
        clockModel.timeSpanColor = Color("WatchColorArrives",bundle:LBBundle)
        clockModel.timeSpanBackgroundColor = Color("WatchColorArrives",bundle:LBBundle)
        
        return clockModel
    }
    func getLeavesViewModel(for child:TimeViewChildInfo, at refDate:Date = Date()) -> ClockViewModel? {
        guard let leaves = child.leavesTime, let leavesDate = child.leavesDate else {
            return nil
        }
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let now = timeFormatter.string(from: refDate)
        
        let clockModel = createClockModel()
        if refDate > leavesDate {
            clockModel.dayStarts = leaves
            clockModel.dayEnds = now
        } else {
            clockModel.dayStarts = now
            clockModel.dayEnds = leaves
        }
        clockModel.showTimeSpan = true
        clockModel.timeLock = leavesDate
        clockModel.showClockSeconds = false
        clockModel.timeSpanColor = Color("WatchColorLeaves",bundle:LBBundle)
        clockModel.timeSpanBackgroundColor = Color("WatchColorLeaves",bundle:LBBundle)
        
        return clockModel
    }
    
    /// - todo: we need labels to describe past tense of tempus_child_not_here_today. use day starts and ends from content model
    func getNotHereLabel(for child:TimeViewChildInfo,at refDate:Date = Date(), wasHere:Bool = false) -> LBVoiceString {
        guard let assistant = assistant else {
            return LBVoiceString(display: "ERROR", voice: "ERROR")
        }
        if let days = Date.numberOfDaysBetween(from: refDate, to: child.nextAttendance), days > 0 {
            if days == 1 {
                let s = assistant.formattedString(forKey: wasHere ? "tempus_child_has_left_returns_tomorrow" : "tempus_child_not_here_returns_tomorrow", child.name)
                return LBVoiceString(display: s, voice: s)
            } else {
                let s = assistant.formattedString(forKey: wasHere ? "tempus_child_has_left_returns_in_days" : "tempus_child_not_here_returns_in_days", child.name, "\(days)")
                return LBVoiceString(display: s, voice: s)
            }
        }
        let s = assistant.formattedString(forKey: child.isHereToday == true ? "tempus_child_has_left" : "tempus_child_not_here_today", child.name)
        return LBVoiceString(display: s, voice: s)
    }
    func getArrivesLabel(for child:TimeViewChildInfo,at refDate:Date = Date()) -> LBVoiceString {
        guard let assistant = assistant else {
            return LBVoiceString(display: "ERROR", voice: "ERROR")
        }
        guard let arrives = child.arrivesTime, let arrivesDate = child.arrivesDate,child.isHereToday else {
            return getNotHereLabel(for:child,at:refDate)
        }
        let pastTense = refDate > arrivesDate ? "_past" : ""
        for i in self.clockViewModel.items.sorted(by: { abs($0.date.timeIntervalSince(arrivesDate)) < abs($1.date.timeIntervalSince(arrivesDate)) }) {
            let clockRelativeDate = relativeDateFrom(time: timeStringfrom(date: i.date), date: arrivesDate)
            let timeElapsed = clockRelativeDate.timeIntervalSince(arrivesDate)
            if timeElapsed < 0 && timeElapsed > 60 * -60 {
                let display = assistant.formattedString(forKey: "tempus_child_arrives_after\(pastTense)", child.name, arrives, "\"\(i.text)\"")
                let voice = assistant.formattedString(forKey: "tempus_child_arrives_after\(pastTense)", child.name, arrivesDate.textTime(using: assistant), "\"\(i.text)\"")
                
                return LBVoiceString(display: display, voice: voice)
            } else if timeElapsed > 0 && timeElapsed < 60 * 60 {
                let display = assistant.formattedString(forKey: "tempus_child_arrives_before\(pastTense)", child.name, arrives, "\"\(i.text)\"")
                let voice = assistant.formattedString(forKey: "tempus_child_arrives_before\(pastTense)", child.name, arrivesDate.textTime(using: assistant), "\"\(i.text)\"")
                
                return LBVoiceString(display: display, voice: voice)
            } else if timeElapsed == 0 {
                let display = assistant.formattedString(forKey: "tempus_child_arrives_during\(pastTense)", child.name, arrives, "\"\(i.text)\"")
                let voice = assistant.formattedString(forKey: "tempus_child_arrives_during\(pastTense)", child.name, arrivesDate.textTime(using: assistant), "\"\(i.text)\"")
                
                return LBVoiceString(display: display, voice: voice)
            }
        }
        let display = assistant.formattedString(forKey: "tempus_child_arrives\(pastTense)", child.name, arrives)
        let voice = assistant.formattedString(forKey: "tempus_child_arrives\(pastTense)", child.name, arrivesDate.textTime(using: assistant))
        
        return LBVoiceString(display: display, voice: voice)
    }
    func getLeavesLabel(for child:TimeViewChildInfo,at refDate:Date = Date()) -> LBVoiceString {
        guard let assistant = assistant else {
            return LBVoiceString(display: "ERROR", voice: "ERROR")
        }
        guard let leaves = child.leavesTime, let leavesDate = child.leavesDate,child.isHereToday else {
            return getNotHereLabel(for:child,at:refDate)
        }
        let pastTense = refDate > leavesDate ? "_past" : ""
        for i in self.clockViewModel.items.sorted(by: { abs($0.date.timeIntervalSince(leavesDate)) < abs($1.date.timeIntervalSince(leavesDate)) }) {
            let clockRelativeDate = relativeDateFrom(time: timeStringfrom(date: i.date), date: leavesDate)
            let timeElapsed = clockRelativeDate.timeIntervalSince(leavesDate)
            if timeElapsed < 0 && timeElapsed > 60 * -60 {
                let display = assistant.formattedString(forKey: "tempus_child_leaves_after\(pastTense)", child.name, leaves, "\"\(i.text)\"")
                let voice = assistant.formattedString(forKey: "tempus_child_leaves_after\(pastTense)", child.name, leavesDate.textTime(using: assistant), "\"\(i.text)\"")
                return LBVoiceString(display: display, voice: voice)
            } else if timeElapsed > 0 && timeElapsed < 60 * 60 {
                let display = assistant.formattedString(forKey: "tempus_child_leaves_before\(pastTense)", child.name, leaves, "\"\(i.text)\"")
                let voice = assistant.formattedString(forKey: "tempus_child_leaves_before\(pastTense)", child.name, leavesDate.textTime(using: assistant), "\"\(i.text)\"")
                return LBVoiceString(display: display, voice: voice)
            } else if timeElapsed == 0 {
                let display = assistant.formattedString(forKey: "tempus_child_leaves_during\(pastTense)", child.name, leaves, "\"\(i.text)\"")
                let voice = assistant.formattedString(forKey: "tempus_child_leaves_during\(pastTense)", child.name, leavesDate.textTime(using: assistant), "\"\(i.text)\"")
                return LBVoiceString(display: display, voice: voice)
            }
        }
        
        let display = assistant.formattedString(forKey: "tempus_child_leaves\(pastTense)", child.name, leaves)
        let voice = assistant.formattedString(forKey: "tempus_child_leaves\(pastTense)", child.name, leavesDate.textTime(using: assistant))
        return LBVoiceString(display: display, voice: voice)
    }
    func getPresenceLabel(for child:TimeViewChildInfo,at refDate:Date = Date()) -> LBVoiceString {
        guard let leavesDate = child.leavesDate, let arrivesDate = child.arrivesDate, child.isHereToday && leavesDate > refDate else {
            return getNotHereLabel(for: child, at: refDate, wasHere: child.isHereToday)
        }
        /// if child has not yet arrived
        if arrivesDate > refDate {
            return getArrivesLabel(for: child, at: refDate)
        }
        return getLeavesLabel(for: child, at: refDate)
    }
}


