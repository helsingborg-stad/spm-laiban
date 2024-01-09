//
//  MemoryGameServiceAdminView.swift
//  LaibanApp
//
//  Created by Tomas Green on 2022-04-29.
//

import SwiftUI

struct MemoryGameServiceAdminView: View {
    @ObservedObject var service:MemoryGameService
    var group: some View {
        Group {
            NavigationLink(destination: MemoryGameServiceGamesAdminView(service: service)){
                Text("Aktiva memoryspel")
                Spacer()
                Text("\(service.data.defaultMemoryGames.count)")
            }
            Toggle("Slumpa bland aktiva spel", isOn: $service.data.memoryGamesAtRandomEnabled)
                .disabled(service.data.defaultMemoryGames.count < 2)
            Toggle("Visa på startskärmen", isOn: $service.data.showOnDashboard)
                .disabled(service.data.defaultMemoryGames.count < 1)
        }
    }
    var body: some View {
        if #available(iOS 14.0, *) {
            group.onChange(of: service.data) { newValue in
                service.save()
            }
        } else {
            group.onDisappear {
                service.save()
            }
        }
    }
}
struct MemoryGameServiceAdminView_Previews: PreviewProvider {
    static var service = MemoryGameService()
    static var previews: some View {
        NavigationView {
            Form {
                Section {
                    service.adminView()
                }
            }
        }.navigationViewStyle(.stack)
    }
}
