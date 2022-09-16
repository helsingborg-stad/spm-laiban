//
//  FoodWasteAdminView.swift
//  LaibanApp
//
//  Created by Tomas Green on 2022-05-19.
//

import SwiftUI

struct FoodWasteAdminView: View {
    @ObservedObject var service:FoodWasteService
    var body: some View {
        NavigationLink(destination: AdminFoodWasteView(service: service)){
            Text("Matsvinn")
        }.id("FoodWasteStatistics")
    }
}

struct FoodWasteAdminView_Previews: PreviewProvider {
    static var service = FoodWasteService()
    static var previews: some View {
        FoodWasteAdminView(service: service)
    }
}
