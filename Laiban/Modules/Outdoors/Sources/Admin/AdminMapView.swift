//
//  AdminMapView.swift
//
//  Created by Tomas Green on 2020-04-01.
//

import CoreLocation
import SwiftUI
import Analytics

struct AdminMapView: View {
    @ObservedObject var service: OutdoorsService
    @Binding var visible: Bool
    @State var locationManager = CLLocationManager()

    var body: some View {
        VStack(spacing: 10) {
            MapView(locationManager: locationManager, coordinates: service.data.coordinates?.location).frame(height: 200, alignment: .center).border(Color.black.opacity(0.2), width: 1)
            Button(action: {
                guard let loc = self.locationManager.location?.coordinate else {
                    return
                }
                service.data.coordinates = Coordinates(address: nil, latitude: loc.latitude, longitude: loc.longitude)
                service.save()
                self.visible = false
                AnalyticsService.shared.log(AnalyticsService.CustomEventType.AdminAction.rawValue, properties: ["Action": "Update", "ObjectType": "Coordinates"])
            }) {
                Text("Använd nuvarande position").foregroundColor(.white)
            }.frame(maxWidth: .infinity).padding().background(Color.blue).cornerRadius(10).padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            if service.data.coordinates != nil {
                Button(action: {
                    service.data.coordinates = nil
                    service.save()
                    self.visible = false
                    AnalyticsService.shared.log(AnalyticsService.CustomEventType.AdminAction.rawValue, properties: ["Action": "Delete", "ObjectType": "Coordinates"])
                }) {
                    Text("Radera position").foregroundColor(.white)
                }.frame(maxWidth: .infinity).padding().background(Color.red).cornerRadius(10).padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            }
            Spacer()
        }
        .background(Color(UIColor.systemGroupedBackground)
            .edgesIgnoringSafeArea(.all))
        .navigationBarTitle("Koordinater för väder")
        .onAppear {
            AnalyticsService.shared.logPageView(self)
        }
    }
}

struct AdminMapView_Previews: PreviewProvider {
    static var service = OutdoorsService()
    static var previews: some View {
        NavigationView {
            Form {
                Section {
                    AdminMapView(service: service, visible: .constant(true))
                }
            }
        }.navigationViewStyle(.stack)
    }
}
