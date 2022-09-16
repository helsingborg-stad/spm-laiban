//
//  WeatherAdminView.swift
//  LaibanApp
//
//  Created by Jonatan Hanson on 2022-05-12.
//

import SwiftUI


struct WeatherAdminView: View {
    @State var showMapView = false
    @ObservedObject var service: OutdoorsService

    var body: some View {
        Group {
            NavigationLink(destination: AdminMapView(service: service, visible: $showMapView), isActive: $showMapView)
                {
                    Text("Koordinater för väder")
                    if service.data.coordinates != nil {
                        Spacer()
                        Image(systemName: "mappin.and.ellipse").imageScale(.small).foregroundColor(.blue)
                    }
                }
                .id("Coordinates")

            NavigationLink(destination: AdminGarmentReportsView(garmentStore: service.garmentStore)) {
                Text("Justeringar av kläder efter väder")
            }
            .id("AdminGarmentReportsViewLink")
            HStack {
                Text("Använd AI-baserade förslag för kläder")
                Spacer()
                LBToggleView(isOn: service.data.mlPoweredClothes) { on in
                    service.data.mlPoweredClothes = on
                    service.save()
                }
            }
        }
    }
}

struct WeatherAdminView_Previews: PreviewProvider {
    static var service = OutdoorsService()
    static var previews: some View {
        NavigationView {
            Form {
                Section {
                    WeatherAdminView(service: service)
                }
            }
        }.navigationViewStyle(.stack)
    }
}
