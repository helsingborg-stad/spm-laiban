//
//  CalendarAdminEventView.swift
//  LaibanApp
//
//  Created by Ehsan Zilaei on 2022-05-12.
//

import SwiftUI
import Analytics

struct CalendarAdminEventView: View {
    @ObservedObject var service: CalendarService
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }
    var item = CalendarEvent()
    @State var date: Date = Date()
    @State var content: String = ""
    @State var icon: String = ""
    @State var height: CGFloat = 100
    @State var textViewIsFirstResponder = false
    func save() {
        var item = self.item
        if self.content == "" {
            AnalyticsService.shared.log(AnalyticsService.CustomEventType.AdminAction.rawValue,properties: ["Action":"Remove","ObjectType":"CalendarEvent"])
            service.remove(item)
            service.save()
        } else if item.content != self.content || self.date != item.date || self.icon != item.icon {
            item.content = self.content
            item.date = self.date
            item.icon = self.icon
            if service.contains(item)  {
                service.update(item)
                AnalyticsService.shared.log(AnalyticsService.CustomEventType.AdminAction.rawValue,properties: ["Action":"Update","ObjectType":"CalendarEvent"])
            } else {
                service.add(item)
                AnalyticsService.shared.log(AnalyticsService.CustomEventType.AdminAction.rawValue,properties: ["Action":"Add","ObjectType":"CalendarEvent"])
            }
            service.save()
        }
    }
    
    var body: some View {
        Form {
            DatePicker(selection: $date, in: Date()..., displayedComponents: .date) {
                Text("Datum")
            }
            LBTextView("Beskrivning", text: $content)
            TextField("Emoji", text: $icon)
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle("Kalenderhändelse")
        .onDisappear {
            save()
        }
        .onAppear {
            AnalyticsService.shared.logPageView(self)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("AdminWillDismiss"))) { (pub) in
            save()
        }
    }
}

struct CalendarAdminEventView_Previews: PreviewProvider {
    static var service = CalendarService()
    
    static var previews: some View {
        CalendarAdminEventView(service: service)
    }
}
