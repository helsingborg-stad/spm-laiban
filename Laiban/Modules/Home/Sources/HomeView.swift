//
//  SwiftUIView.swift
//
//
//  Created by Tomas Green on 2022-06-07.
//

import SwiftUI
import PublicCalendar
import TTS
import Combine
import Assistant

public struct HomeView: View {
    @EnvironmentObject var viewState:LBViewState
    @EnvironmentObject var assistant:Assistant
    @Environment(\.fullscreenContainerProperties) var properties

    @State private var cancellables = Set<AnyCancellable>()
    @State private var title:String = "home_take_action"
    @State private var didSpeak = Date()
    @State private var didGreet = Date().addingTimeInterval(60 * -5)
    @State private var calendarEvents:[PublicCalendar.Event]? = []
    @State private var activities:[Activity]? = nil
    @State private var activitiesToReview:[Activity] = []
    private let timer = Timer.publish(every: 60, on: .current, in: .common).autoconnect()
    @ObservedObject private var publicCalendar:PublicCalendar
    @ObservedObject private var activityService:ActivityService
    public init(publicCalendar:PublicCalendar,activityService:ActivityService) {
        self.publicCalendar = publicCalendar
        self.activityService = activityService
    }
    func generateTitle() -> String {
        if activitiesToReview.isEmpty == false {
            return "home_feedback_acitivity_title"
        }
        if !LBDevice.isDebug && Date() >= relativeDateFrom(time: "12:00") || didGreet.timeIntervalSinceNow * -1 < 60 * 5 {
            return "home_take_action"
        }
        didGreet = Date()
        let tomorrow = Date().tomorrow!
        if let event = calendarEvents?.first(where: { $0.date.isSameDay(as: tomorrow) })  {
            if event.title.lowercased().contains("långfredag") {
                return "home_holiday_easter"
            } else if event.title.lowercased().contains("julafton") {
                return "home_holiday_christmans"
            }
        }
        if tomorrow.actualWeekDay >= 6 {
            return "home_weekend"
        }
        return "home_take_action"
    }
    var greetingView: some View {
        Text(LocalizedStringKey(title),bundle:LBBundle)
            .lineLimit(nil)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity,alignment:.leading)
            .padding(properties.spacing[.m])
            .primaryContainerBackground()
            .font(properties.font, ofSize: .n)
    }
    func update() {
        activitiesToReview = activityService.todaysActivities.filter { $0.canReview }
        let t = generateTitle()
        title = t
        if didSpeak.timeIntervalSinceNow * -1 < 5 {
            assistant.speak(title)
        }
    }
    func speakAboutLaiban() {
        if assistant.isSpeaking {
            return
        }
        title = "about_laiban_\(Int.random(in: 1...6))"
        assistant.speak(title).first?.statusPublisher.sink { status in
            if status == TTSUtteranceStatus.finished {
                title = generateTitle()
            }
        }.store(in: &cancellables)
    }
    @ViewBuilder var content: some View {
        if self.activitiesToReview.isEmpty == false {
            ActivitiesFeedbackHomeView()
        } else {
            self.greetingView
        }
    }
    public var body: some View {
        content
            .transition(.opacity.combined(with: .scale))
            .onReceive(properties.actionBarNotifier) { action in
                guard action == .character else {
                    return
                }
                if activitiesToReview.isEmpty == false {
                    update()
                    return
                }
                speakAboutLaiban()
            }
            .onReceive(timer) { _ in
                update()
            }
            .onReceive(publicCalendar.latest) { events in
                guard let events = events else {
                    return
                }
                self.calendarEvents = events.events(in: [.holidays,.nights])
            }
            .onReceive(activityService.$data) { activities in
                self.activities = activities
            }
            .onAppear {
                viewState.actionButtons([.languages, .admin], for: .home)
                viewState.characterPosition(.right, for: .home)
                update()
            }
    }
}
