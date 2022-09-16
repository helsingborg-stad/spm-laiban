//
//  CalendarAdminView.swift
//  LaibanApp
//
//  Created by Ehsan Zilaei on 2022-05-12.
//

import SwiftUI

struct CalendarAdminView: View {
    @ObservedObject var service: CalendarService
    
    var body: some View {
        NavigationLink(destination: CalendarAdminEventsView(service: service)) {
            HStack {
                Text("Kalender")
                Spacer()
                Text("\((service.data).count)")
            }
        }
    }
}

struct CalendarAdminView_Previews: PreviewProvider {
    static let service = CalendarService()
    
    static var previews: some View {
        NavigationView {
            Form {
                Section {
                    CalendarAdminView(service: service)
                }
            }
        }.navigationViewStyle(.stack)
    }
}
