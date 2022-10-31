//
//  RegisterFoodWasteView.swift
//  Laiban
//
//  Created by Tomas Green on 2021-11-19.
//

import SwiftUI
import Assistant
import Analytics

struct RegisterFoodWasteView: View {
    @EnvironmentObject var viewState:LBViewState
    @EnvironmentObject var assistant:Assistant
    @Environment(\.fullscreenContainerProperties) var properties
    @Environment(\.locale) var locale
    @ObservedObject var manager:FoodWasteViewModel
    @ObservedObject var service:FoodWasteService
    @State var numEating:Int = 0
    @State var numpadString:String = ""
    func evalWeight() {
        if numpadString.count > 0, let weight = Double(numpadString) {
            AnalyticsService.shared.log(AnalyticsService.CustomEventType.ButtonPressed.rawValue, properties: ["Button":"RegisterFoodWaste"])
            service.wasteManager.add(value: weight,numEating: numEating, for:manager.selectedDate)
            manager.setCurrentView(.balanceScale)
            numpadString = ""
            numEating = 0
        }
    }
    func evalNumEating() {
        if numpadString.count > 0, let eating = Int(numpadString) {
            AnalyticsService.shared.log(AnalyticsService.CustomEventType.ButtonPressed.rawValue, properties: ["Button":"NumberOfPeopleEating"])
            numEating = eating
            numpadString = ""
            manager.setCurrentView(.enterFoodWaste)
        }
    }
    var maxFoodWaste:Int {
        service.data.maxFoodWastePerPerson
    }
    var maxEating:Int {
        service.data.maxNumberOfPeoapleEating
    }
    var enterDailyPlateWaste: some View {
        VStack() {
            Text("🍽🗑").padding(.bottom, 10)
                .font(properties.font, ofSize: .xxl)
            Text("Ange dagens tallriskssvinn i gram.")
                .font(properties.font, ofSize: .l)
            Spacer()
            HStack(alignment:.bottom) {
                Text(numpadString.count > 0 ? numpadString : "0")
                Text("g").foregroundColor(.gray)
            }
            .font(properties.font, ofSize: .n)
            Rectangle()
                .frame(width: properties.windowRatio * 100 * 4 + properties.windowRatio * 20 * 2, height:1)
                .padding(.bottom, properties.windowRatio * 20)
            LBNumpadView(maxNum: maxFoodWaste * maxEating,string: $numpadString).padding(30)
            Spacer()
            Button(action: evalWeight, label: {
                Text("Registera")
                    .padding()
                    .frame(width: properties.windowRatio * 100 * 5)
                    .font(properties.font, ofSize: .l,color:.white)
                    .background(Color("DefaultTextColor", bundle:.module))
                    .cornerRadius(properties.windowRatio * 100/2)
                    .shadow(enabled: true)
            }).foregroundColor(Color.white).disabled(numpadString.count < 1).opacity(numpadString.count < 1 ? 0.5 : 1)
            Spacer()
        }
        .frame(maxWidth:.infinity,maxHeight:.infinity)
        .padding(properties.spacing[.m])
        .primaryContainerBackground()
        .onAppear {
            AnalyticsService.shared.logPageView("FoodWasteView/EnterDailyPlateWaste")
            numpadString = ""
        }
    }
    var enterNumberOfPeople: some View {
        VStack() {
            Text("👩‍👧‍👦👨‍👧‍👦").padding(.bottom, 10)
                .font(properties.font, ofSize: .xxl)
            Text("Hur många var det som åt idag?")
                .font(properties.font, ofSize: .l)
            Spacer()
            HStack(alignment:.bottom) {
                Text(numpadString.count > 0 ? numpadString : "0")
                Text("st").foregroundColor(.gray)
            }
            .font(properties.font, ofSize: .n)
            Rectangle()
                .frame(width: properties.windowRatio * 100 * 4 + properties.windowRatio * 20 * 2, height:1)
                .padding(.bottom, properties.windowRatio * 20)
            LBNumpadView(maxNum: maxEating, string: $numpadString).padding(30)
            Spacer()
            Button(action: evalNumEating, label: {
                Text("Nästa")
                    .padding()
                    .frame(width: properties.windowRatio * 100 * 5)
                    .font(properties.font, ofSize: .l,color:.white)
                    .background(Color("DefaultTextColor", bundle:.module))
                    .cornerRadius(properties.windowRatio * 100/2)
                    .shadow(enabled: true)
            }).foregroundColor(Color.white).disabled(numpadString.count < 1).opacity(numpadString.count < 1 ? 0.5 : 1)
            Spacer()
        }
        .frame(maxWidth:.infinity,maxHeight:.infinity)
        .padding(properties.spacing[.m])
        .primaryContainerBackground()
        .onAppear {
            AnalyticsService.shared.logPageView("FoodWasteView/EnterDailyPlateWaste")
            numpadString = ""
        }
    }
    var body: some View {
        if manager.currentView == .enterFoodWaste {
            enterDailyPlateWaste
        } else if manager.currentView == .enterNumEating {
            enterNumberOfPeople
        } else {
            EmptyView()
        }
    }
}
//
//struct RegisterFoodWasteView_Previews: PreviewProvider {
//    static var statistics:[HouseholdScaleTableView.ViewModel] {
//        var arr = [HouseholdScaleTableView.ViewModel]()
//        var date = Date().startOfWeek!
//        arr.append(HouseholdScaleTableView.ViewModel(date: date, model: HouseholdScaleView.ViewModel(wasteWeight: 200, baseLine: 1250,emojis: "🍏🍏🍓")))
//        date = date.tomorrow!
//        arr.append(HouseholdScaleTableView.ViewModel(date: date, model: HouseholdScaleView.ViewModel(wasteWeight: 300, baseLine: 1250,emojis: "🍏🍗🍌🍏🍈🍈")))
//        date = date.tomorrow!
//        arr.append(HouseholdScaleTableView.ViewModel(date: date, model: HouseholdScaleView.ViewModel(wasteWeight: 1800, baseLine: 1250,emojis: "🍓🥩🥕🥝🥩🥕🥝🍏🍏🍈🍈🍓🥩🥕🥝🥩🥕🥝🍏🍏🍈🍈")))
//        date = date.tomorrow!
//        arr.append(HouseholdScaleTableView.ViewModel(date: date, model: HouseholdScaleView.ViewModel(wasteWeight: 0, baseLine: 1250)))
//        date = date.tomorrow!
//        arr.append(HouseholdScaleTableView.ViewModel(date: date, model: HouseholdScaleView.ViewModel(wasteWeight: 0, baseLine: 1250)))
//        return arr
//    }
//    static var manager:FoodWasteViewManager {
//        let m = FoodWasteViewManager(nil)
//        m.title = LaibanString(LocalizedString("Test", key: "test", language: .swedish))
//        FoodWasteManager.delete()
//        m.weeklyStatistics = statistics
//        m.currentView = .enterNumEating
//        return m
//    }
//    static var previews: some View {
//        RegisterFoodWasteView(manager: manager)
//
//            .environmentObject(Localization())
//            .modifier(PreviewDeviceCategory(category: .phone))
//    }
//}
