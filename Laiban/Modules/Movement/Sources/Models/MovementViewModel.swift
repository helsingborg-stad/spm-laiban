//
//  MovementViewModel.swift
//  
//
//  Created by Fredrik Häggbom on 2022-10-27.
//

import Foundation
import Combine
import SwiftUI

import Assistant

class MovementViewModel: ObservableObject {
    enum MovementViews {
        case statistics
        case enterMovementTime
        case enterNumMoving
        case balanceScale
        case dailyMovemnent
    }
    var balanceViwModel:MovementBarView.ViewModel = MovementBarView.ViewModel.init(movementTime: 0)
    var listeners = [AnyCancellable]()
    weak var assistant:Assistant? = nil
    weak var service:MovementService? = nil
    weak var viewState:LBViewState? = nil
    @Published var parentalGateStatus:LBParentalGateStatus? = .undetermined
    @Published private(set) var infoTitle:String? = nil
    @Published private(set) var infoDescription:String? = nil
    @Published private(set) var infoEmoji:String? = nil
    @Published var title:LBVoiceString? = nil
    // @Published var dailyStatisticItems: [MovementDailyStatisticsView.Item] = []
    @Published var weeklyStatistics:[MovementTableView.ViewModel] = []
    @Published private(set) var currentView:MovementViews = .statistics
    var selectedDate:Date = Date() {
        didSet {
            updateDailyStatistics()
        }
    }
    func setCurrentView(_ view:MovementViews) {
        guard let movementManager = service?.movementManager else {
            return
        }

        if view == currentView {
            return
        }
        if view == .enterNumMoving {
            self.parentalGateStatus = .undetermined
        } else {
            self.parentalGateStatus = .passed
        }
        if view == .balanceScale {
            balanceViwModel.reset(to: MovementBarView.ViewModel.round(movementManager.movement(for: self.selectedDate)?.first?.minutes ?? 0))
        }
        viewState?.inactivityTimerDisabled(view == .enterNumMoving, for: .movement)
        switch view {
        case .statistics: viewState?.actionButtons([.home,.languages], for: .movement)
        case .enterMovementTime: viewState?.actionButtons([.back,.languages], for: .movement)
        case .enterNumMoving: viewState?.actionButtons([.back,.languages], for: .movement)
        case .balanceScale: viewState?.actionButtons([.back,.languages], for: .movement)
        case .dailyMovemnent: viewState?.actionButtons([.back,.languages], for: .movement)
        }
        self.currentView = view
        self.updateTitle()
    }
    func updateDailyStatistics() {
        guard let movementManager = service?.movementManager else {
            return
        }
        
        if let w = movementManager.movement(for: selectedDate) {
            // dailyStatisticItems = MovementDailyStatisticsView.Item.convert(emojis: w.emojis)
        }
    }
    func updateWeeklyStatistics() {
        guard let movementManager = service?.movementManager else {
            return
        }
        
        var date = Date().startOfWeek!
        var arr = [MovementTableView.ViewModel]()
        var baseLine:Int = 0
        let average = Int(movementManager.getWeeklyAverage(for: date.dateOffsetBy(days: -1)!))
        if average == 0 {
            baseLine = movementManager.getWeeklyHigh(for: date)
        } else {
            baseLine = average
        }
        date = Date().startOfWeek!
        for _ in 0..<5 {
            if let w = movementManager.movement(for: date) {
                arr.append(MovementTableView.ViewModel(date: date, model: MovementBarView.ViewModel(movementTime: w.compactMap({ $0.minutes }).reduce(0, +))))
            } else {
                arr.append(MovementTableView.ViewModel(date: date, model: MovementBarView.ViewModel(movementTime: 0)))
            }
            date = date.tomorrow!
        }
        self.objectWillChange.send()
        self.weeklyStatistics = arr
    }
    func initiate(with assistant:Assistant, service:MovementService, viewState:LBViewState) {
        self.assistant = assistant
        self.service = service
        self.viewState = viewState
        self.balanceViwModel = MovementBarView.ViewModel.init(movementTime: MovementBarView.ViewModel.round(0))
        service.movementManager.objectWillChange.sink { [weak self] _ in
            guard let this = self else {
                return
            }
            // this.updateDailyStatistics()
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
            // this.updateDailyStatistics()
             this.updateWeeklyStatistics()
        }.store(in: &listeners)
        balanceViwModel.$objects.sink { [weak self,balanceViwModel,service] objects in
            guard let this = self else {
                return
            }
            guard balanceViwModel.movementTime == balanceViwModel.minutes(from: objects) else {
                return
            }
            if var w = service.movementManager.movement(for: this.selectedDate) {
                // w.emojis = objects.map({ i in i.emoji }).joined()
                service.movementManager.update(movement: w)
            }
        }.store(in: &listeners)

        updateTitle()
        updateWeeklyStatistics()
        // updateDailyStatistics()
        self.objectWillChange.send()
    }
    func getTitleAndVoice() -> LBVoiceString? {
        guard let assistant = assistant else {
            return nil
        }
        guard let movementManager = service?.movementManager else {
            return nil
        }

        if currentView == .balanceScale {
            if balanceViwModel.calculatedBalance {
                return LBVoiceString("food_waste_balance_title")
            } else {
                return LBVoiceString("food_waste_title")
            }
        } else if currentView == .dailyMovemnent {
            let str:String
            let a = Int(Date().timeIntervalSince(selectedDate) / 60 / 60 / 24)
            if a == 0 {
                str = "food_waste_statistics_title_today"
            } else if a == 1 {
                str = "food_waste_statistics_title_yesterday"
            } else {
                str = "food_waste_statistics_title_weekday_\(selectedDate.actualWeekDay)"
            }
            let t = assistant.formattedString(forKey: str, String(Int(movementManager.movement(for: selectedDate)?.compactMap({ $0.minutes }).reduce(0, +) ?? 0)))
            if let s = dailyWasteStrings {
                return LBVoiceString(display: t, voice: s)
            }
            return LBVoiceString(t)
        } else if currentView == .statistics {
            let lastWeeksMovement = movementManager.getWeeklyMovement(for: Date().startOfWeek!.dateOffsetBy(days: -1)!)
            let thisWeeksMovement = movementManager.getWeeklyMovement(for: Date())
            if lastWeeksMovement > 0 {
                let s = assistant.formattedString(forKey: "movement_last_week","\(Int(lastWeeksMovement))","\(Int(thisWeeksMovement))")
                return LBVoiceString(s)
            } else {
                if thisWeeksMovement > 0 {
                    let s = assistant.formattedString(forKey: "movement_weekly_stats","\(Int(thisWeeksMovement))")
                    return LBVoiceString(s)
                } else {
                    let s = assistant.string(forKey: "movement_nothing")
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
        /*if selectedDate.isSameDay(as: Date()), let w = service?.movementManager.movementCompared(to: selectedDate) {
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
        }*/
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
                    self?.setCurrentView(.dailyMovemnent)
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
        guard let movementManager = service?.movementManager else {
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
        let t = assistant.formattedString(forKey: str, String(Int(movementManager.movement(for: selectedDate)?.compactMap({ $0.minutes }).reduce(0, +) ?? 0)))
        let and = assistant.string(forKey: "word_and")
        /*if dailyStatisticItems.count == 1 {
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
         */
        return  "hello there"
    }
}
