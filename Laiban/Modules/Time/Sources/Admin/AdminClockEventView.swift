//
//  AdminClockEventView.swift
//
//  Created by Tomas Green on 2020-03-31.
//

import SwiftUI
import Analytics

struct AdminClockEventView: View {
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }
    @ObservedObject var service:TimeService
    var item:ClockEvent = ClockEvent()
    @State var date:Date = Date()
    @State var title:String = ""
    @State var emoji:String = ""
    func contains(_ item:ClockEvent) -> Bool {
        return service.data.events.contains { $0.id == item.id }
    }
    func remove(_ item:ClockEvent) {
        service.data.events.removeAll { $0.id == item.id }
        service.save()
    }
    func add(_ item:ClockEvent) {
        if contains(item) {
            return
        }
        service.data.events.append(item)
        sortEvents()
        service.save()
    }
    func update(_ item:ClockEvent) {
        guard let index = service.data.events.firstIndex(where: { e in e.id == item.id }) else {
            self.add(item)
            return
        }
        service.data.events[index] = item
        service.save()
    }
    func sortEvents() {
        service.data.events.sort { (a1, a2) in a1.time < a2.time }
        service.save()
    }
    func save() {
        var item = self.item
        if self.title == "" && self.emoji == "" {
            AnalyticsService.shared.log(AnalyticsService.CustomEventType.AdminAction.rawValue,properties: ["Action":"Remove","ObjectType":"ClockEvent"])
            remove(item)
            self.service.save()
        } else if item.title != self.title || timeStringfrom(date: self.date) != item.time || self.emoji != item.emoji {
            item.title = self.title
            item.time = timeStringfrom(date: self.date)
            item.emoji = self.emoji
            if contains(item)  {
                update(item)
                AnalyticsService.shared.log(AnalyticsService.CustomEventType.AdminAction.rawValue, properties: ["Action":"Update","ObjectType":"ClockEvent"])
            } else {
                add(item)
                AnalyticsService.shared.log(AnalyticsService.CustomEventType.AdminAction.rawValue, properties: ["Action":"Add","ObjectType":"ClockEvent"])
            }
            self.service.save()
        }
    }
    var body: some View {
        Form() {
            TextField("Emoji", text: $emoji)
            LBTextView("Titel", text: $title)
            DatePicker(selection: $date, displayedComponents: .hourAndMinute) {
                Text("Tid")
            }
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle("Händelser")
        .onDisappear {
            self.save()
        }
        .onAppear {
            AnalyticsService.shared.logPageView(self)
        }
    }
}

struct AdminClockEventView_Previews: PreviewProvider {
    static var service = TimeService()
    static var previews: some View {
        NavigationView {
            Form {
                Section {
                    AdminClockEventView(service: service)
                }
            }
        }.navigationViewStyle(.stack)
    }
}
