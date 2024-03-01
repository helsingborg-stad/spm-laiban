//
//  File.swift
//  
//
//  Created by Kenth Ljung on 2024-02-29.
//

import Foundation
import SwiftUI
import Combine

@available(iOS 15.0, *)
struct DashboardItemVisibilityServiceAdminView: View {
    @ObservedObject var service: DashboardItemVisibilityService
    
    var body: some View {
        NavigationLink(destination: DashboardItemVisibilityServiceAdminInnerView(service: service)) {
            Text("Välj vilka moduler som ska synas på hemskärmen")
        }.id("DashboardItemVisibilityServiceAdminInner")
    }
}

@available(iOS 15.0, *)
struct DashboardItemVisibilityServiceAdminInnerView: View {
    struct ServiceToggle: View {
        @ObservedObject var service: DashboardItemVisibilityService
        var forItem: ManagedDashboardItem
        @State var isOn: Bool = false
        @State private var cancellables = Set<AnyCancellable>()
        
        var body: some View {
            Toggle(isOn: $isOn) {
                if((service.dashboardItemView) != nil) {
                    AnyView(service.dashboardItemView!(forItem))
                } else {
                    Text(forItem.viewIdentity.id)
                }
            }
            .onChange(of: isOn) { newValue in
                service.setVisibility(id: forItem.viewIdentity, visible: newValue)
                isOn = newValue
            }
            .onAppear {
                isOn = service.isVisible(id: forItem.viewIdentity)
                
                service.onVisibilityChanged.sink { _ in
                    isOn = service.isVisible(id: forItem.viewIdentity)
                }.store(in: &cancellables)
            }
        }
    }
    
    @ObservedObject var service: DashboardItemVisibilityService
    @State private var toggles: [Bool] = Array(repeating: true, count: 50)
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Button("Stäng av alla") {
                        service.managedServices.forEach { item in
                            service.setVisibility(id: item.viewIdentity, visible: false)
                        }
                    }
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 5))
                    .buttonStyle(.borderedProminent)
                    
                    Button("Slå på alla") {
                        service.managedServices.forEach { item in
                            service.setVisibility(id: item.viewIdentity, visible: true)
                        }
                    }
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 5))
                    .buttonStyle(.borderedProminent)
                }
            }
            
            Section("Utgråade moduler är inte tillgängliga") {
                ForEach(0 ..< service.managedServices.count, id: \.self) { value in
                    ServiceToggle(service: service, forItem: service.managedServices[value])
                        .disabled(!service.managedServices[value].isAvailable)
                }
            }
        }
    }
}

@available(iOS 15.0, *)
struct DashboardItemVisibilityServiceAdminView_Previews: PreviewProvider {
    static var service = DashboardItemVisibilityService()
    
    static var previews: some View {
        NavigationView {
            Form {
                Section {
                    service.adminView()
                }
            }
        }
        .navigationViewStyle(.stack)
        .onAppear {
            service.dashboardItemView = { data in
                HStack {
                    TimeHomeViewIcon()
                    .frame(width: 50, height: 50, alignment: .center)
                    if data is LBAdminService {
                        Text((data as! any LBAdminService).id)
                    } else {
                        Text(data.viewIdentity.id)
                    }
                }
            }
            service.managedServices = [
                FoodService(),
                CalendarService(),
                TimeService(),
                MemoryGameService()
            ]
        }
    }
}
