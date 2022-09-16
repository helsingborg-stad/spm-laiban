//
//  FoodAdminView.swift
//  LaibanApp
//
//  Created by Jonatan Hanson on 2022-05-06.
//

import SwiftUI

struct FoodAdminView: View {
    @ObservedObject var service: FoodService
    @State var showFoodProcessingMethod = false
    @State var showSchoolsView = false

    var body: some View {
        Group {
            NavigationLink(
                destination: AdminSkolmatenCountyListView(rootVisible: $showSchoolsView) { school in
                    service.data.foodLink = school
                    showSchoolsView = false
                },
                isActive: $showSchoolsView,
                label: {
                    Text(service.data.foodLink?.title ?? "Välj matsedel").foregroundColor(service.data.foodLink != nil ? .blue : .gray)
                }
            )
            .id("Meals")

            NavigationLink(destination: AdminFoodProcessingMethodView(service: service), isActive: $showFoodProcessingMethod) {
                Text("Förenkling av matsedel")
                Spacer()
                Text("\(FoodProcessingMethod(rawValue: service.data.foodProcessingMethod.rawValue)?.title ?? "Ej vald")")
            }
            .id("FoodProcessingMethod")
            .disabled(service.data.foodLink == nil)

            //            NavigationLink(destination: AdminFoodWasteView(model: model, wasteManager: appState.foodWasteManager)) {
            //                Text("Matsvinn")
            //            }.id("FoodWasteStatistics")
        }
        .onReceive(service.$data) { _ in
            service.save()
        }
    }
}

struct FoodAdminView_Previews: PreviewProvider {
    static var service = FoodService()
    static var previews: some View {
        NavigationView {
            Form {
                Section {
                    FoodAdminView(service: service)
                }
            }
        }.navigationViewStyle(.stack)
    }
}
