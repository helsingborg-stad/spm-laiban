//
//  AdminFoodWasteView.swift
//
//  Created by Tomas Green on 2021-03-04.
//

import SwiftUI
import CoreHaptics
import Combine
import Analytics

struct AdminFoodWasteView: View {
    @ObservedObject var service:FoodWasteService
    var maxFoodWastePerPersonProxy: Binding<Double> {
        Binding<Double>(get: {
            return Double(service.data.maxFoodWastePerPerson)
        }, set: {
            service.data.maxFoodWastePerPerson = Int($0)
            service.save()
        })
    }
    var maxNumberOfPeoapleEatingProxy: Binding<Double> {
        Binding<Double>(get: {
            return Double(service.data.maxNumberOfPeoapleEating)
        }, set: {
            service.data.maxNumberOfPeoapleEating = Int($0)
            service.save()
        })
    }
    var footer: some View {
        Group {
            Text("UNITCODE TEXT")
            if service.backendStorageEnabled {
                Text("Tallrikssvinnet exporteras automatiskt från eheten till en central plats. Svinnet rensas från appen efter 2 veckor, fram till dess är det fritt fram att ändra eventuella felaktigheter.")
            } else {
                Text("Tallrikssvinnet exporteras inte automatiskt från enheten och återfinns endast i Laiban.")
                    .foregroundColor(.red).fontWeight(.bold)
            }
        }
    }
    var body: some View {
        Form() {
            Section(header: Text("Inställningar"), footer:Text("Dessa inställningar reglerar vilka värden man kan lägga ange vid registrering av tallrikssvinn.")) {
                VStack {
                    HStack(alignment:.firstTextBaseline) {
                        Text("Maximalt tallrikssvinn per person").padding(.top, 10)
                        Spacer()
                        Text("\(service.data.maxFoodWastePerPerson) g")
                    }
                    Slider(value: maxFoodWastePerPersonProxy, in: 50...2000, step:50)
                }
                VStack {
                    HStack(alignment:.firstTextBaseline) {
                        Text("Maximalt antal ätande").padding(.top, 10)
                        Spacer()
                        Text("\(service.data.maxNumberOfPeoapleEating) st")
                    }
                    Slider(value: maxNumberOfPeoapleEatingProxy, in: 5...100, step:5)
                }
            }
            Section(header: Text("Registrerat tallrikssvinn"),footer:footer) {
                if service.wasteManager.array.isEmpty {
                    Text("Inget svinn registrerat").foregroundColor(.gray)
                }
                ForEach(service.wasteManager.array) { value in
                    NavigationLink.init(destination: AdminEditFoodWaste(service:service, date: value.date, waste: String(Int(value.waste)), numEating: String(value.numEating))) {
                        HStack {
                            Text(value.date)
                            Spacer()
                            Spacer()
                            if value.numEating > 0 {
                                Text("\(value.numEating) st")
                            }
                            Text("\(Int(value.waste)) g")
                                .frame(width: 100,alignment:.trailing)
                        }
                    }
                }
            }

        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle("Hantera tallrikssvinn")
        .onAppear {
            AnalyticsService.shared.logPageView(self)
        }
    }
}


struct AdminEditFoodWaste: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var service:FoodWasteService
    @State var date:String
    @State var waste:String = "0"
    @State var numEating:String = "0"
    @State var didCancel = false
    var body:some View {
        Form {
            Section(header: Text("Tallrikssvinn för \(date)")) {
                VStack(alignment:.leading) {
                    Text("Antal ätande").font(.caption).foregroundColor(.gray)
                    TextField("Ange antal", text: $numEating)
                        .keyboardType(.numberPad)
                        .onReceive(Just(numEating)) { newValue in
                            let filtered = newValue.filter { "0123456789".contains($0) }
                            if filtered != newValue {
                                self.numEating = filtered
                            }
                        }
                }
                VStack(alignment:.leading) {
                    Text("Ange dagens totala tallrikssvinn i gram").font(.caption).foregroundColor(.gray)
                    TextField("Ange tallrikssvinn", text: $waste)
                        
                        .keyboardType(.numberPad)
                        .onReceive(Just(waste)) { newValue in
                            let filtered = newValue.filter { "0123456789".contains($0) }
                            if filtered != newValue {
                                self.waste = filtered
                            }
                        }
                }
            }
        }.onDisappear {
            if didCancel {
                return
            }
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            guard let date = formatter.date(from: date), let waste = Double(waste), let numEating = Int(numEating) else {
                return
            }
            service.wasteManager.add(value: waste, numEating: numEating, for: date)
        }
        .onAppear {
            didCancel = false
        }
        .navigationBarItems(trailing: Button(action: {
            didCancel = true
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("Avbryt").foregroundColor(.red)
        }))
        .navigationBarTitle("Ändra tallrikssvinn")
    }
}

//struct AdminFoodWasteView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            AdminFoodWasteView(model: AdminViewModel(), service.wasteManager: Foodservice.WasteManager())
//        }.navigationViewStyle(StackNavigationViewStyle())
//    }
//}
