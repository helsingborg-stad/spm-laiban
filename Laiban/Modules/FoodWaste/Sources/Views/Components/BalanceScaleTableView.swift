//
//  FoodWasteMeasurementsView.swift
//
//  Created by Tomas Green on 2021-03-04.
//

import SwiftUI

import Assistant

struct BalanceScaleTableView : View {
    @ObservedObject var model:BalanceScaleView.ViewModel
    @ObservedObject var foodWasteManager:FoodWasteManager
    @EnvironmentObject var viewState:LBViewState
    @EnvironmentObject var assistant:Assistant
    @Environment(\.fullscreenContainerProperties) var properties
    @Environment(\.locale) var locale
    
    @State var title:String = "food_waste_title"
    @State var inBalance = false
    func updateTitle() {
        if inBalance {
            title = "food_waste_balance_title"
        } else {
            title = "food_waste_title"
        }
    }
    var body: some View {
        VStack(spacing:0) {
            Group {
                Text(LocalizedStringKey(title), bundle: LBBundle)
            }
            .font(properties.font, ofSize: .n)
            .padding(.top, 10).animation(.none)

            Spacer()
            BalanceScaleView(model: model)
            RoundedRectangle(cornerRadius: 2)
                .fill(Color("ScaleTabelColor",bundle: .module))
                .overlay(RoundedRectangle(cornerRadius: 2).stroke(Color("ScaleTabelBorderColor",bundle:.module), lineWidth: 1))
                .frame(height:10).frame(maxWidth:.infinity)
            HStack(alignment:.bottom,spacing:10) {
                let size:CGFloat = properties.windowRatio * properties.windowSize.width / CGFloat(model.selection.count < 10 ? 10 : model.selection.count)
                ForEach(model.selection, id: \.id) { obj in
                    VStack(spacing:10) {
                        Text(obj.emoji)
                            .font(.system(size: size * obj.scaleFactor))
                            .shadow(color: Color.black.opacity(0.3),radius: 5)
                        Text("\(Int(obj.weight))")
                            .font(properties.font, ofSize: .xs)
                    }
                    .onTapGesture {
                        if model.totalWeight < model.wasteWeight * 2 {
                            model.objects.append(.init(object: obj))
                        }
                    }
                }
                .opacity(inBalance ? 0 : 1)
                .disabled(inBalance)
            }.padding(.top, 20)
        }
        .frame(maxWidth:.infinity,maxHeight:.infinity)
        .onReceive(model.$inBalance) { val in
            if val == inBalance {
                return
            }
            inBalance = val
            updateTitle()
        }
        .onAppear(perform: {
            self.updateTitle()
        })
    }
}
