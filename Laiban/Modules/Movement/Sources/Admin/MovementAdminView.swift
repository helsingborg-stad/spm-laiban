//
//  ActivityAdminView.swift
//  
//
//  Created by Fredrik Häggbom on 2022-10-25.
//

import SwiftUI

struct MovementAdminView: View {
    @ObservedObject var service: MovementService
    @State var showAdminView = false
    
    var stepsPerMinuteIntProxy: Binding<Double>{
        Binding<Double>(get: {
            return Double(service.data.settings.stepsPerMinute)
        }, set: {
            service.data.settings.stepsPerMinute = Int($0)
        })
    }
    
    var maxMetersIntProxy: Binding<Double>{
        Binding<Double>(get: {
            return Double(service.data.settings.maxMetersPerDay)
        }, set: {
            service.data.settings.maxMetersPerDay = Int($0)
        })
    }
    
    var body: some View {
        Group {
            NavigationLink(
                destination:MovementAdminViews(service: service),
                label: {
                    Text("Aktiviteter")
                }
            )
            VStack(alignment:.leading,spacing:0) {
                HStack(alignment:.firstTextBaseline) {
                    Text("Antal steg per minut").padding(.top, 10)
                    Spacer()
                    Text("\(Int(service.data.settings.stepsPerMinute)) steg/minut")
                }
                Slider(value: stepsPerMinuteIntProxy, in: 1...500, step: 1)
            }
            VStack(alignment:.leading,spacing:0) {
                HStack(alignment:.firstTextBaseline) {
                    Text("Max antal meter per dag").padding(.top, 10)
                    Spacer()
                    Text("\(Int(service.data.settings.maxMetersPerDay)) meter")
                }
                Slider(value: maxMetersIntProxy, in: 100000...300000, step: 1000)
            }
            VStack(alignment:.leading,spacing:0) {
                HStack(alignment:.firstTextBaseline) {
                    Text("Steglängd").padding(.top, 10)
                    Spacer()
                    Text("\(Int(service.data.settings.stepLength * 100)) cm")
                }
                Slider(value: $service.data.settings.stepLength, in: 0.1...1, step: 0.01)
            }
        }
    }

}

struct MovementAdminView_Previews: PreviewProvider {
    static var service = MovementService()
    
    static var previews: some View {
        NavigationView {
            Form {
                Section {
                    MovementAdminView(service: service)
                }
            }
        }.navigationViewStyle(.stack)
    }
}
