//
//  FoodActionBarView.swift
//  LaibanApp
//
//  Created by Tomas Green on 2022-04-24.
//

import SwiftUI

import Assistant

public struct FoodActionBarView : View {
    @EnvironmentObject var assistant:Assistant
    var properties:LBAactionBarProperties
    public init(properties:LBAactionBarProperties) {
        self.properties = properties
    }
    public var body: some View {
        HStack(alignment:.bottom) {
            Text(LocalizedStringKey("food_waste_kompostina_title"), bundle: LBBundle)
                .frame(maxWidth:.infinity,alignment: .leading)
                .padding(properties.spacing[.s])
                .primaryContainerBackground(cornerRadius: 16)
            Button {
                properties.trigger(.custom(LBViewIdentity.foodwaste.id))
            } label: {
                Monster(name: "Kompostina").avatar
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
        .frame(maxWidth:.infinity,maxHeight: .infinity)
        .id(LBViewIdentity.foodwaste.id + "-ActionBarView")
        .transition(.scale)
        .font(properties.font, ofSize: .n)
        .scaleEffect(assistant.currentlySpeaking?.tag == "food_waste_kompostina_title" ? 1.05 : 1)
        .animation(.easeInOut)
    }
}
