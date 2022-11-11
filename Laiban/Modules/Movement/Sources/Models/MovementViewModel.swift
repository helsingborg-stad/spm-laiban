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
        case activityChooser
        case dailyMovemnent
    }
    var activityViewModel:MovementBarView.ViewModel = MovementBarView.ViewModel.init(movementMeters: 0, settings: MovementSettings())
    var listeners = [AnyCancellable]()
    weak var assistant:Assistant? = nil
    weak var service:MovementService? = nil
    weak var viewState:LBViewState? = nil
    @Published var parentalGateStatus:LBParentalGateStatus? = .undetermined
    @Published private(set) var infoTitle:String? = nil
    @Published private(set) var infoDescription:String? = nil
    @Published private(set) var infoEmoji:String? = nil
    @Published var title:LBVoiceString? = nil
    @Published var dailyStatisticItems: [Movement] = []
    @Published var weeklyStatistics:[MovementTableView.ViewModel] = []
    @Published private(set) var currentView:MovementViews = .statistics
    public var maxMinutesOfActivity: Int = 500
    public var maxNumberOfPeople: Int = 50
    
    var selectedDate:Date = Date() {
        didSet {
            updateDailyStatistics()
        }
    }
    func setCurrentView(_ view:MovementViews) {
        if view == currentView {
            return
        }

        viewState?.inactivityTimerDisabled(view == .enterNumMoving, for: .movement)
        switch view {
        case .statistics: viewState?.actionButtons([.home,.languages], for: .movement)
        case .enterMovementTime: viewState?.actionButtons([.back,.languages], for: .movement)
        case .enterNumMoving: viewState?.actionButtons([.back,.languages], for: .movement)
        case .activityChooser: viewState?.actionButtons([.back,.languages], for: .movement)
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
            dailyStatisticItems = w
        }
    }
    func updateWeeklyStatistics() {
        guard let service = service else {
            return
        }
        let movementManager = service.movementManager
        
        var date = Date().startOfWeek!
        var arr = [MovementTableView.ViewModel]()

        date = Date().startOfWeek!
        for _ in 0..<5 {
            if let w = movementManager.movement(for: date) {
                arr.append(MovementTableView.ViewModel(date: date, model: MovementBarView.ViewModel(movementMeters: service.movementManager.meters(from: w.compactMap({ $0.minutes * $0.numMoving }).reduce(0, +)), settings: service.data.settings)))
            } else {
                arr.append(MovementTableView.ViewModel(date: date, model: MovementBarView.ViewModel(movementMeters: 0, settings: service.data.settings)))
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
        self.activityViewModel = MovementBarView.ViewModel.init(movementMeters: MovementBarView.ViewModel.round(0), settings: service.data.settings)
        
        $parentalGateStatus.sink { value in
            self.updateTitle(speakAfter: true)
        }.store(in: &cancellables)
        
        service.movementManager.objectWillChange.sink { [weak self] _ in
            guard let this = self else {
                return
            }
            this.updateWeeklyStatistics()
            this.objectWillChange.send()
        }.store(in: &listeners)
        activityViewModel.objectWillChange.sink { [weak self,activityViewModel] _ in
            guard let this = self else {
                return
            }
            if activityViewModel.calculatedBalance {
                this.updateTitle()
            }
            this.updateWeeklyStatistics()
        }.store(in: &listeners)
        activityViewModel.$objects.sink { [weak self,activityViewModel,service] objects in
            guard let this = self else {
                return
            }
            guard activityViewModel.movementMeters == activityViewModel.meters(from: objects) else {
                return
            }
            if let w = service.movementManager.movement(for: this.selectedDate) {
                service.movementManager.update(movement: w)
            }
        }.store(in: &listeners)

        updateTitle()
        updateWeeklyStatistics()
        self.objectWillChange.send()
    }
    func getTitleAndVoice() -> LBVoiceString? {
        guard let assistant = assistant else {
            return nil
        }
        guard let movementManager = service?.movementManager else {
            return nil
        }

        if currentView == .activityChooser {
            if parentalGateStatus == .passed {
                let translated = assistant.string(forKey: "movement_choose_activity")
                return LBVoiceString(translated)
            }
            return LBVoiceString("")
        } else if currentView == .dailyMovemnent {
            let str:String
            let a = Int(Date().timeIntervalSince(selectedDate) / 60 / 60 / 24)
            if a == 0 {
                str = "movement_statistics_title_today"
            } else if a == 1 {
                str = "movement_statistics_title_yesterday"
            } else {
                str = "movement_statistics_title_weekday_\(selectedDate.actualWeekDay)"
            }
            let t = assistant.formattedString(forKey: str, String(Int(movementManager.movementSteps(for: selectedDate))), String(movementManager.movementMeters(for: selectedDate)))
            if let s = dailyMovementStrings {
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
        if let s = getTitleAndVoice() {
            self.title = s
            speak()
        }
    }
    func speak() {
        guard let assistant = assistant else {
            return
        }
        guard let s = title else {
            return
        }

        assistant.speak(s.voice)
    }
    var dailyMovementStrings:String? {
        guard let assistant = assistant else {
            return nil
        }
        guard let movementManager = service?.movementManager else {
            return nil
        }
        let str:String
        let a = Int(Date().timeIntervalSince(selectedDate) / 60 / 60 / 24)
        if a == 0 {
            str = "movement_statistics_title_today"
        } else if a == 1 {
            str = "movement_statistics_title_yesterday"
        } else {
            str = "movement_statistics_title_weekday_\(selectedDate.actualWeekDay)"
        }
        return assistant.formattedString(forKey: str, String(Int(movementManager.movementSteps(for: selectedDate))), String(movementManager.movementMeters(for: selectedDate)))
    }
}
