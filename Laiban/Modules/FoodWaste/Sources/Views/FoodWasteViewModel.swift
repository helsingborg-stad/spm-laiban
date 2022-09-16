//
//  FoodWasteViewManager.swift
//
//  Created by Tomas Green on 2021-03-04.
//

import Foundation
import Combine
import SwiftUI

import Assistant

class FoodWasteViewModel: ObservableObject {
    enum FoodWasteViews {
        case statistics
        case enterFoodWaste
        case enterNumEating
        case balanceScale
        case dailyWaste
    }
    var balanceViwModel:BalanceScaleView.ViewModel = BalanceScaleView.ViewModel.init(wasteWeight: 0)
    var listeners = [AnyCancellable]()
    weak var assistant:Assistant? = nil
    weak var service:FoodWasteService? = nil
    weak var viewState:LBViewState? = nil
    @Published var parentalGateStatus:LBParentalGateStatus? = .undetermined
    @Published private(set) var infoTitle:String? = nil
    @Published private(set) var infoDescription:String? = nil
    @Published private(set) var infoEmoji:String? = nil
    @Published var title:LBVoiceString? = nil
    @Published var dailyStatisticItems: [FoodWasteDailyStatisticsView.Item] = []
    @Published var weeklyStatistics:[HouseholdScaleTableView.ViewModel] = []
    @Published private(set) var currentView:FoodWasteViews = .statistics
    var selectedDate:Date = Date() {
        didSet {
            updateDailyStatistics()
        }
    }
    func setCurrentView(_ view:FoodWasteViews) {
        guard let wasteManager = service?.wasteManager else {
            return
        }

        if view == currentView {
            return
        }
        if view == .enterNumEating {
            self.parentalGateStatus = .undetermined
        } else {
            self.parentalGateStatus = .passed
        }
        if view == .balanceScale {
            balanceViwModel.reset(to: BalanceScaleView.ViewModel.round(wasteManager.waste(for: self.selectedDate)?.waste ?? 0))
        }
        viewState?.inactivityTimerDisabled(view == .enterNumEating, for: .foodwaste)
        switch view {
        case .statistics: viewState?.actionButtons([.home,.languages], for: .foodwaste)
        case .enterFoodWaste: viewState?.actionButtons([.back,.languages], for: .foodwaste)
        case .enterNumEating: viewState?.actionButtons([.back,.languages], for: .foodwaste)
        case .balanceScale: viewState?.actionButtons([.back,.languages], for: .foodwaste)
        case .dailyWaste: viewState?.actionButtons([.back,.languages], for: .foodwaste)
        }
        self.currentView = view
        self.updateTitle()
    }
    func updateDailyStatistics() {
        guard let wasteManager = service?.wasteManager else {
            return
        }
        
        if let w = wasteManager.waste(for: selectedDate) {
            dailyStatisticItems = FoodWasteDailyStatisticsView.Item.convert(emojis: w.emojis)
        }
    }
    func updateWeeklyStatistics() {
        guard let wasteManager = service?.wasteManager else {
            return
        }
        
        var date = Date().startOfWeek!
        var arr = [HouseholdScaleTableView.ViewModel]()
        var baseLine:Double = 0
        let average = wasteManager.getWeeklyAverage(for: date.dateOffsetBy(days: -1)!)
        if average == 0 {
            baseLine = wasteManager.getWeeklyHigh(for: date)
        } else {
            baseLine = average
        }
        date = Date().startOfWeek!
        for _ in 0..<5 {
            if let w = wasteManager.waste(for: date) {
                arr.append(HouseholdScaleTableView.ViewModel(date: date, model: HouseholdScaleView.ViewModel(wasteWeight: w.waste, baseLine: baseLine, emojis: w.emojis)))
            } else {
                arr.append(HouseholdScaleTableView.ViewModel(date: date, model: HouseholdScaleView.ViewModel(wasteWeight: 0, baseLine: baseLine, emojis: "")))
            }
            date = date.tomorrow!
        }
        self.objectWillChange.send()
        self.weeklyStatistics = arr
    }
    func initiate(with assistant:Assistant, service:FoodWasteService, viewState:LBViewState) {
        self.assistant = assistant
        self.service = service
        self.viewState = viewState
        self.balanceViwModel = BalanceScaleView.ViewModel.init(wasteWeight: BalanceScaleView.ViewModel.round(service.wasteManager.waste(for: self.selectedDate)?.waste ?? 0))
        service.wasteManager.objectWillChange.sink { [weak self] _ in
            guard let this = self else {
                return
            }
            this.updateDailyStatistics()
            this.updateWeeklyStatistics()
            this.objectWillChange.send()
        }.store(in: &listeners)
        balanceViwModel.objectWillChange.sink { [weak self,balanceViwModel] _ in
            guard let this = self else {
                return
            }
            if balanceViwModel.calculatedBalance {
                this.updateTitle()
            }
            //this.clearReturnToHomeScreenTimer()
            this.updateDailyStatistics()
            this.updateWeeklyStatistics()
        }.store(in: &listeners)
        balanceViwModel.$objects.sink { [weak self,balanceViwModel,service] objects in
            guard let this = self else {
                return
            }
            guard balanceViwModel.wasteWeight == balanceViwModel.weight(from: objects) else {
                return
            }
            if var w = service.wasteManager.waste(for: this.selectedDate) {
                w.emojis = objects.map({ i in i.emoji }).joined()
                service.wasteManager.update(waste: w)
            }
        }.store(in: &listeners)

        updateTitle()
        updateWeeklyStatistics()
        updateDailyStatistics()
        self.objectWillChange.send()
    }
    func getTitleAndVoice() -> LBVoiceString? {
        guard let assistant = assistant else {
            return nil
        }
        guard let wasteManager = service?.wasteManager else {
            return nil
        }

        if currentView == .balanceScale {
            if balanceViwModel.calculatedBalance {
                return LBVoiceString("food_waste_balance_title")
            } else {
                return LBVoiceString("food_waste_title")
            }
        } else if currentView == .dailyWaste {
            let str:String
            let a = Int(Date().timeIntervalSince(selectedDate) / 60 / 60 / 24)
            if a == 0 {
                str = "food_waste_statistics_title_today"
            } else if a == 1 {
                str = "food_waste_statistics_title_yesterday"
            } else {
                str = "food_waste_statistics_title_weekday_\(selectedDate.actualWeekDay)"
            }
            let t = assistant.formattedString(forKey: str, String(Int(wasteManager.waste(for: selectedDate)?.waste ?? 0)))
            if let s = dailyWasteStrings {
                return LBVoiceString(display: t, voice: s)
            }
            return LBVoiceString(t)
        } else if currentView == .statistics {
            let lastWeeksWaste = wasteManager.getWeeklyWaste(for: Date().startOfWeek!.dateOffsetBy(days: -1)!)
            let thisWeeksWaste = wasteManager.getWeeklyWaste(for: Date())
            if lastWeeksWaste > 0 {
                let s = assistant.formattedString(forKey: "food_waste_last_week","\(Int(lastWeeksWaste))","\(Int(thisWeeksWaste))")
                return LBVoiceString(s)
            } else {
                if thisWeeksWaste > 0 {
                    let s = assistant.formattedString(forKey: "food_waste_weekly_stats","\(Int(thisWeeksWaste))")
                    return LBVoiceString(s)
                } else {
                    let s = assistant.string(forKey: "food_waste_nothing")
                    return LBVoiceString(s)
                }
            }
        }
        return nil
    }
    func updateTitle(speakAfter:Bool = false) {
        guard let assistant = assistant else {
            return
        }

        if let s = getTitleAndVoice() {
            if s.display == title?.display {
                return
            }
            self.title = s
            speak()
        }
        if selectedDate.isSameDay(as: Date()), let w = service?.wasteManager.wasteCompared(to: selectedDate) {
            switch w {
            case .orderedAscending:
                infoTitle = assistant.string(forKey: "food_waste_info_more")
                infoDescription = assistant.string(forKey: "food_waste_tip_3")
                infoEmoji = "👅"
            case .orderedSame:
                infoTitle = assistant.string(forKey: "food_waste_info_equal")
                infoDescription = assistant.string(forKey: "food_waste_tip_3")
                infoEmoji = "👅"
            case .orderedDescending:
                infoTitle = assistant.string(forKey: "food_waste_info_less")
                infoDescription = assistant.string(forKey: "food_waste_tip_3")
                infoEmoji = "👅"
            }
        } else {
            infoTitle = nil
            infoDescription = nil
            infoEmoji = nil
        }
    }
    func speak() {
        guard let assistant = assistant else {
            return
        }
        guard let s = title else {
            return
        }
        if "food_waste_balance_title" == s.voice && currentView == .balanceScale  {
            assistant.speak(s.voice).last?.statusPublisher.sink { [weak self] status in
                if status == .finished || status == .cancelled || status == .failed {
                    self?.setCurrentView(.dailyWaste)
                }
            }.store(in: &listeners)
        } else {
            assistant.speak(s.voice)
        }
    }
    var dailyWasteStrings:String? {
        guard let assistant = assistant else {
            return nil
        }
        guard let wasteManager = service?.wasteManager else {
            return nil
        }
        let str:String
        let a = Int(Date().timeIntervalSince(selectedDate) / 60 / 60 / 24)
        if a == 0 {
            str = "food_waste_statistics_title_today"
        } else if a == 1 {
            str = "food_waste_statistics_title_yesterday"
        } else {
            str = "food_waste_statistics_title_weekday_\(selectedDate.actualWeekDay)"
        }
        let t = assistant.formattedString(forKey: str, String(Int(wasteManager.waste(for: selectedDate)?.waste ?? 0)))
        let and = assistant.string(forKey: "word_and")
        if dailyStatisticItems.count == 1 {
            var strings = [t]
            strings.append(dailyStatisticItems.first!.title(using: assistant))
            return strings.map { l in l.description }.joined(separator: " ")
        } else if dailyStatisticItems.count == 2 {
            var strings = [t]
            strings.append(dailyStatisticItems.first!.title(using: assistant))
            strings.append(and)
            strings.append(dailyStatisticItems.last!.title(using: assistant))
            return strings.map { l in l.description }.joined(separator: " ")
        } else if dailyStatisticItems.count > 2 {
            var strings = [String]()
            dailyStatisticItems.prefix(upTo: dailyStatisticItems.count - 1).forEach { i in
                strings.append(i.title(using: assistant))
            }
            let str = strings.map { l in l.description }.joined(separator: ", ")
            let str2 = "\(t.description) \(str) \(and.description) \(dailyStatisticItems.last!.title(using: assistant))"
            return str2
        }
        return nil
    }
}
