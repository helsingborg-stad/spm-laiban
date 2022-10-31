//
//  AdminClockEventView.swift
//
//  Created by Tomas Green on 2020-03-31.
//

import SwiftUI
import Combine
import Analytics

struct AdminClockEventsView: View {
    @ObservedObject var service:TimeService
    var body: some View {
        Form() {
            Section() {
                NavigationLink(destination: AdminClockEventView(service: service)){
                    Text("Lägg till händelse").foregroundColor(.blue)
                }.id("Add new clockEvent")
            }
            Section(header: Text("Alla händelser")) {
                if self.service.data.events.count == 0 {
                    Text("Inga händelser").foregroundColor(.gray)
                }
                ForEach(self.service.data.events) { item in
                    NavigationLink(destination: AdminClockEventView(service: service, item: item, date: relativeDateFrom(time: item.time),title: item.title, emoji: item.emoji)) {
                        HStack() {
                            Text(item.emoji)
                            Text(item.title)
                            Spacer()
                            Text(item.time)
                        }
                    }.id(item.id)
                }.onDelete { (indexSet) in
                    self.service.data.events.remove(atOffsets: indexSet)
                    self.service.save()
                    AnalyticsService.shared.log(AnalyticsService.CustomEventType.AdminAction.rawValue,properties: ["Action":"Delete","ObjectType":"ClockEvent"])
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle("Händelse")
        .onAppear {
            AnalyticsService.shared.logPageView(self)
        }
    }
}

struct AdminClockEventsView_Previews: PreviewProvider {
    static var service = TimeService()
    static var previews: some View {
        NavigationView {
            Form {
                Section {
                    AdminClockEventsView(service: service)
                }
            }
        }.navigationViewStyle(.stack)
    }
}
