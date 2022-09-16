//
//  NoticeBoardView.swift
//  Laiban
//
//  Created by Tomas Green on 2021-06-15.
//

import SwiftUI

import Assistant

public struct NoticeboardView: View {
    @EnvironmentObject var viewState:LBViewState
    @EnvironmentObject var assistant:Assistant
    @Environment(\.fullscreenContainerProperties) var properties
    @Environment(\.locale) var locale
    @State private var weather = Set<NoticeboardWeatherCondition>()
    @State private var allMessages = [Message]()
    @State private var diseases = [Message]()
    @State private var messages = [Message]()
    @State private var reminders = [Message]()
    var contentProvider:NoticeboardContentProvider
    public init(contentProvider:NoticeboardContentProvider) {
        self.contentProvider = contentProvider
    }
    @ViewBuilder var overlay: some View {
        if diseases.isEmpty && reminders.isEmpty && messages.isEmpty {
            Text(LocalizedStringKey("message_no_messages"), bundle: LBBundle).font(properties.font, ofSize: .n,weight: .bold)
        }
    }

    func update() {
        var diseases = [Message]()
        var messages = [Message]()
        var reminders = [Message]()
        if weather.contains(.precipitation) == true {
            if let r = allMessages.first(where: { m in
                m.active && m.automated && m.tag == "weather_rain"
            }) {
                reminders.append(r)
            }
        }
        if weather.contains(.sunny) {
            if let r = allMessages.first(where: { m in
                m.active && m.automated && m.tag == "weather_sun"
            }) {
                reminders.append(r)
            }
        }
        if weather.contains(.conditionAppropriateClothes) {
            if let r = allMessages.first(where: { m in
                m.active && m.automated && m.tag == "outdoor_clothes"
            }) {
                reminders.append(r)
            }
        }
        allMessages.forEach({ m in
            if m.active && !m.automated {
                switch m.category {
                case .disease: diseases.append(m)
                case .info: messages.append(m)
                case .reminder: reminders.append(m)
                }
            }
        })
        self.diseases = diseases
        self.messages = messages
        self.reminders = reminders
    }
    func from() -> Date {
        let rel = Date().dateOffsetBy(days: Date().actualWeekDay == 5 ? 3 : 1)!
        return relativeDateFrom(time: "08:00", date: rel)
    }
    func to() -> Date {
        let rel = Date().dateOffsetBy(days: Date().actualWeekDay == 5 ? 3 : 1)!
        return relativeDateFrom(time: "18:00", date: rel)
    }
    public var body: some View {
        VStack {
            let padd = properties.spacing[.m]
            if !diseases.isEmpty {
                Text(LocalizedStringKey(MessageCategory.disease.localizedKey), bundle:LBBundle)
                    .font(properties.font, ofSize: .n,weight: .bold)
                    .frame(maxWidth:.infinity,maxHeight:.infinity,alignment:.leading)
                    .padding([.top,.leading], padd)
                MessagesListView(messages: diseases, category:.disease, detailed:true)
            }
            if !reminders.isEmpty {
                Text(LocalizedStringKey(MessageCategory.reminder.localizedKey), bundle:LBBundle)
                    .font(properties.font, ofSize: .n,weight: .bold)
                    .frame(maxWidth:.infinity,maxHeight:.infinity,alignment:.leading)
                    .padding([.top,.leading], padd)
                MessagesListView(messages: reminders, category:.info, detailed:true)
            }
            if !messages.isEmpty {
                Text(LocalizedStringKey(MessageCategory.info.localizedKey), bundle:LBBundle)
                    .font(properties.font, ofSize: .n,weight: .bold)
                    .frame(maxWidth:.infinity,maxHeight:.infinity,alignment:.leading)
                    .padding([.top,.leading], padd)
                MessagesListView(messages: messages, category:.info, detailed:true)
            }
        }
        .overlay(overlay)
        .padding([.leading,.trailing,.bottom], properties.spacing[.m])
        .frame(maxWidth:.infinity,maxHeight: .infinity)
        .wrap(scrollable: true, overlay: .emoji("💁",Color("RimColorNoticeboard",bundle:LBBundle)))
        .onAppear {
            LBAnalyticsProxy.shared.logPageView(self)
            update()
        }
        .transition(.opacity.combined(with: .scale))
        .onReceive(contentProvider.messagesPublisher()) { content in
            self.allMessages = content
            update()
        }
        .onReceive(contentProvider.noticeboardWeatherConditionsPublisher(from: from(), to: to())) { weather in
            self.weather = weather
            update()
        }
    }
}

struct NoticeBoardView_Previews: PreviewProvider {
    static var contentProvider = PreviewNoticeboardContentProvider()
    static var previews: some View {
        LBFullscreenContainer { _ in
            NoticeboardView(contentProvider: contentProvider)
        }.attachPreviewEnvironmentObjects()
    }
}
