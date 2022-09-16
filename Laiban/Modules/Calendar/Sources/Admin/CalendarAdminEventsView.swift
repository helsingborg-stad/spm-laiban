//
//  CalendarAdminEventsView.swift
//  LaibanApp
//
//  Created by Ehsan Zilaei on 2022-05-12.
//

import SwiftUI

struct CalendarAdminEventsView: View {
    @ObservedObject var service: CalendarService
    
    func string(from date: Date) -> String {
        let df = DateFormatter()
        df.timeStyle = .none
        df.dateStyle = .medium
        df.doesRelativeDateFormatting = true
        return df.string(from: date)
    }
    
    var body: some View {
        Form {
            Section() {
                NavigationLink(destination: CalendarAdminEventView(service: service)){
                    Text("Lägg till kalenderhändelse").foregroundColor(.blue)
                }.id("create new calendar event")
            }
            
            Section(header: Text("Alla kalenderhändelser")) {
                if service.data.count == 0 {
                    Text("Inga kalenderhändelser").foregroundColor(.gray)
                }
                ForEach(service.data) { item in
                    NavigationLink(destination: CalendarAdminEventView(service: service, item: item, date: item.date, content: item.content, icon: item.icon ?? "")) {
                        HStack() {
                            Text(item.icon ?? "").lineLimit(1)
                            Text(item.content).lineLimit(1)
                            Spacer()
                            Text(self.string(from: item.date)).foregroundColor(.blue)
                        }
                    }.id(item.id)
                }.onDelete { (indexSet) in
                    service.data.remove(atOffsets: indexSet)
                    service.save()
                    LBAnalyticsProxy.shared.log("AdminAction",properties: ["Action":"Delete","ObjectType":"CalendarEvent"])
                }
            }
        }
    }
}

struct CalendarAdminEventsView_Previews: PreviewProvider {
    static var service = CalendarService()
    
    static var previews: some View {
        CalendarAdminEventsView(service: service)
    }
}
