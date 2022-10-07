//
//  FoodWasteView.swift
//
//  Created by Tomas Green on 2021-03-04.
//

import SwiftUI

import Assistant

public struct FoodWasteView : View {
    @EnvironmentObject var viewState:LBViewState
    @EnvironmentObject var assistant:Assistant
    @Environment(\.fullscreenContainerProperties) var properties
    @Environment(\.locale) var locale
    @ObservedObject var service:FoodWasteService
    @StateObject var manager = FoodWasteViewModel()
    public init(service:FoodWasteService) {
        self.service = service
    }
    func cancelParentalGate() {
        manager.setCurrentView(.statistics)
    }
    var statistics: some View {
        VStack {
            if manager.title != nil {
                Text(manager.title!.display)
                    .font(properties.font, ofSize: .n)
                    .multilineTextAlignment(.center)
            }
            Spacer()
            HouseholdScaleTableView(wasteManager: service.wasteManager, statistics: manager.weeklyStatistics) { scale,action in
                if scale.date > Date() {
                    return
                }
                manager.selectedDate = scale.date
                if action == .didPressIcon && service.wasteManager.waste(for: scale.date) != nil {
                    manager.setCurrentView(.balanceScale)
                } else {
                    if service.wasteManager.waste(for: scale.date) != nil {
                        manager.setCurrentView(.dailyWaste)
                    } else {
                        manager.setCurrentView(.enterNumEating)
                    }
                }
            }
        }
        .padding(.top, 10)
        .frame(maxWidth:.infinity,maxHeight: .infinity)
        .padding(properties.spacing[.m])
        .primaryContainerBackground()
        .transition(.opacity.combined(with: .scale))
        .onAppear {
            LBAnalyticsProxy.shared.logPageView("FoodWasteView/WeeklyPlateWasteStatistics")
        }
    }
    var balanceScaleView: some View {
        BalanceScaleTableView(model: manager.balanceViwModel, foodWasteManager:service.wasteManager)
            .frame(maxWidth:.infinity,maxHeight: .infinity)
            .padding(properties.spacing[.m])
            .primaryContainerBackground()
            .transition(.opacity.combined(with: .scale))
            .onAppear {
                LBAnalyticsProxy.shared.logPageView("FoodWasteView/BalanceWaste")
            }
    }
    var dailyStatistics: some View {
        let w = service.wasteManager.waste(for: manager.selectedDate) ?? .init(waste: 0, numEating: 0)
        return FoodWasteDailyStatisticsView(
            foodWaste: w.waste,
            items: FoodWasteDailyStatisticsView.Item.convert(emojis: w.emojis),
            date: manager.selectedDate,
            infoTitle: manager.infoTitle,
            infoDescription: manager.infoDescription,
            infoEmoji: manager.infoEmoji
        )
        .frame(maxWidth:.infinity,maxHeight: .infinity)
        .padding(properties.spacing[.m])
        .primaryContainerBackground()
        .transition(.opacity.combined(with: .scale))
        .onAppear {
            LBAnalyticsProxy.shared.logPageView("FoodWasteView/DailyPlateWasteStatistics")
        }
    }
    var register: some View {
        RegisterFoodWasteView(manager: manager,service:service)
            .parentalGate(properties: properties)
            .transition(.opacity.combined(with: .scale))
    }
    @ViewBuilder var root: some View {
        if manager.currentView == .statistics {
            statistics
        } else if manager.currentView == .enterFoodWaste || manager.currentView == .enterNumEating  {
            register
        } else if manager.currentView == .balanceScale {
            balanceScaleView
        } else if manager.currentView == .dailyWaste {
            dailyStatistics
        }
    }
    public var body:some View {
        Group {
            root
        }
        .animation(.spring(),value:manager.currentView)
        .onAppear {
            viewState.characterImage(Monster(name:"Kompostina").image, for: .foodwaste)
            manager.initiate(with: assistant,service:service, viewState: viewState)
        }
        .onReceive(properties.actionBarNotifier) { action in
            if action == .back {
                manager.setCurrentView(.statistics)
            }
        }
        
    }
}

struct FoodWasteView_Previews: PreviewProvider {
    static var service = FoodWasteService()
    static var previews: some View {
        LBFullscreenContainer { _ in
            FoodWasteView(service: service)
        }
        .attachPreviewEnvironmentObjects()
    }
}
