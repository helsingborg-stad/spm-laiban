//
//  FoodView.swift
//
//  Created by Tomas Green on 2020-03-20.
//


import Meals
import SwiftUI
import Assistant
import Combine

public struct FoodView: View {
    @Environment(\.fullscreenContainerProperties) var properties
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject var viewState:LBViewState
    @EnvironmentObject var assistant: Assistant
    @ObservedObject var service: FoodService
    @State var title: String = .init("")
    @State var food = [String]()
    @State var statistics:FoodService.Statistics? = nil
    @State var showStatistics = false
    var titleString: String {
        if didEat {
            return "food_title_after"
        }
        return "food_title_before"
    }
    var didEat:Bool {
        LBDevice.isDebug || (food.isEmpty == false && Date() >= relativeDateFrom(time: "12:00"))
    }
    func update() {
        title = titleString
        var strings = [(title,title)]
        for f in food {
            strings.append((f, f))
        }
        if Date() >= relativeDateFrom(time: "12:00") || LBDevice.isDebug {
            let s = assistant.string(forKey: "food_waste_kompostina_title").components(separatedBy: CharacterSet.symbols).joined().replacingOccurrences(of: "  ", with: " ")
            strings.append((s, "food_waste_kompostina_title"))
        }
        assistant.speak(strings)
    }
    
    func shouldRepeat() {
        if assistant.isSpeaking {
            return
        }
        assistant.speak(food)
    }
    public init(service:FoodService) {
        self.service = service
    }
    var foodListView: some View {
        VStack(alignment: .center) {
            Text(LocalizedStringKey(title), bundle: LBBundle)
                .font(properties.font, ofSize: .l)
            ForEach(food, id: \.self) { text in
                let s = assistant.string(forKey: text)
                Text(s)
                    .frame(maxWidth: .infinity)
                    .padding(properties.spacing[.m])
                    .secondaryContainerBackground()
                    .scaleEffect(assistant.currentlySpeaking?.speechString == s ? 1.05 : 1)
                    .animation(.easeInOut,value:assistant.currentlySpeaking)
                    .frame(maxWidth: .infinity, alignment: .top)
                    .font(properties.font, ofSize: .l)
                
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .multilineTextAlignment(.center)
        .padding(properties.spacing[.m])
        .wrap(scrollable:true, overlay: .emoji("🍽", Color("RimColorFood",bundle:.module)), onTapOverlayAction: {
            shouldRepeat()
        })
        .transition(.opacity.combined(with: .scale))
    }
    public var body: some View {
        VStack(spacing:properties.spacing[.m]) {
            if showStatistics && statistics != nil {
                FoodStatisticsBarChartView(title: food.joined(separator: "\n"), data:statistics!)
                    .transition(.opacity.combined(with: .scale))
                    .onReceive(properties.actionBarNotifier) { action in
                        if action == .back {
                            showStatistics = false
                            viewState.actionButtons([.languages,.home], for: .food)
                        }
                    }
            } else {
                foodListView
                if didEat {
                    FoodFeedbackForm() { reaction in
                        service.register(reaction)
                    }
                    if statistics != nil {
                        FoodFeedbackStatisticsBox(data:statistics!) {
                            withAnimation {
                                showStatistics = true
                                viewState.actionButtons([.languages,.back], for: .food)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            LBAnalyticsProxy.shared.logPageView(self)
            viewState.actionButtons([.home,.languages], for: .food)
            viewState.characterHidden(true, for: .food)
        }
        .onReceive(service.statisticsSubject) { value in
            statistics = value
        }
        .onReceive(service.$foodStrings) { value in
            self.food = value ?? []
            self.update()
        }
        .animation(.spring(),value:showStatistics)
        .animation(.spring(),value:statistics)
        .transition(.opacity.combined(with: .scale))
    }
}
struct FoodStatisticsBarChartView: View {
    @EnvironmentObject var viewState:LBViewState
    @EnvironmentObject var assistant:Assistant
    @Environment(\.fullscreenContainerProperties) var properties
    @Environment(\.locale) var locale
    var items:[LBGraphItem]
    var title:String
    init(title:String, data:FoodService.Statistics) {
        self.title = title
        var arr = [LBGraphItem]()
        if data.rating1 > 0 {
            arr.append(LBGraphItem(color: LBFeedbackReaction.sad.color, emoji: LBFeedbackReaction.sad.emoji, percentage: data.rating1Proc))
        }
        if data.rating2 > 0 {
            arr.append(LBGraphItem(color: LBFeedbackReaction.neutral.color, emoji: LBFeedbackReaction.neutral.emoji, percentage: data.rating2Proc))
        }
        if data.rating3 > 0 {
            arr.append(LBGraphItem(color: LBFeedbackReaction.happy.color, emoji: LBFeedbackReaction.happy.emoji, percentage: data.rating3Proc))
        }
        if data.rating4 > 0 {
            arr.append(LBGraphItem(color: LBFeedbackReaction.veryHappy.color, emoji: LBFeedbackReaction.veryHappy.emoji, percentage: data.rating4Proc))
        }
        self.items = arr
    }
    var body: some View {
        VStack {
            Text(LocalizedStringKey("feedback_lunch_statistics_title"),bundle: .module)
                .font(properties.font, ofSize: .l)
            VStack {
                Text(title)
                LBBarGraphView(data: items)
            }
            .padding(properties.spacing[.m])
            .secondaryContainerBackground()
        }
        .padding(properties.spacing[.m])
        .font(properties.font, ofSize: .n)
        .wrap(scrollable: true, overlay: .emoji("🍽", Color("RimColorFood",bundle:.module)))
        .transition(.opacity.combined(with: .scale))
    }
}
struct FoodFeedbackForm: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.fullscreenContainerProperties) var properties
    @Environment(\.locale) var locale
    @EnvironmentObject var assistant:Assistant
    @State var didRate:Bool = false
    @State var utteranceSubscriber:AnyCancellable? = nil
    var callback: (LBFeedbackReaction) -> Void
    func rate(reaction:LBFeedbackReaction) {
        utteranceSubscriber = assistant.speak(("feedback_lunch_thanks", "feedback_lunch_thanks")).first?.statusPublisher.sink { status in
            if status == .finished || status == .failed || status == .cancelled {
                didRate = false
            }
        }
        didRate = true
        callback(reaction)
    }
    var body: some View {
        HStack(spacing: properties.spacing[.m]) {
            Text(LocalizedStringKey(didRate ? "feedback_lunch_thanks" : "feedback_lunch_question"),bundle:.module).font(properties.font, ofSize: .n)
            Spacer()
            LBFeedbackReactionsListView { reaction in
                rate(reaction: reaction)
            }.opacity(didRate ? 0 : 1)
        }
        .frame(maxWidth:.infinity)
        .padding(properties.spacing[.m])
        .primaryContainerBackground()
        .scaleEffect(assistant.currentlySpeaking?.tag == "feedback_lunch_thanks" ? 1.05 : 1)
        .animation(.spring(), value: assistant.currentlySpeaking)
        .transition(.opacity.combined(with: .scale))
    }
}
struct FoodFeedbackStatisticsBox : View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.fullscreenContainerProperties) var properties
    @Environment(\.locale) var locale
    var items:[LBGraphItem]
    var onShowStatistics: () -> Void
    init(data:FoodService.Statistics, _ onShowStatistics:@escaping () -> Void) {
        self.onShowStatistics = onShowStatistics
        var arr = [LBGraphItem]()
        if data.rating1 > 0 {
            arr.append(LBGraphItem(color: LBFeedbackReaction.sad.color, emoji: LBFeedbackReaction.sad.emoji, percentage: data.rating1Proc))
        }
        if data.rating2 > 0 {
            arr.append(LBGraphItem(color: LBFeedbackReaction.neutral.color, emoji: LBFeedbackReaction.neutral.emoji, percentage: data.rating2Proc))
        }
        if data.rating3 > 0 {
            arr.append(LBGraphItem(color: LBFeedbackReaction.happy.color, emoji: LBFeedbackReaction.happy.emoji, percentage: data.rating3Proc))
        }
        if data.rating4 > 0 {
            arr.append(LBGraphItem(color: LBFeedbackReaction.veryHappy.color, emoji: LBFeedbackReaction.veryHappy.emoji, percentage: data.rating4Proc))
        }
        self.items = arr
    }
    var body: some View {
        HStack(spacing:properties.spacing[.m]) {
            Text(LocalizedStringKey("feedback_lunch_statistics"),bundle:.module).font(properties.font, ofSize: .n)
            Spacer()
            Button {
                onShowStatistics()
            } label: {
                LBPieChart(lineWidth: 1, items: items).frame(width: properties.contentSize.height * 0.055, height: properties.contentSize.height * 0.055)
                    .shadow(enabled: true)
            }
        }
        .frame(maxWidth:.infinity)
        .padding(properties.spacing[.m])
        .primaryContainerBackground()
        .transition(.opacity.combined(with: .scale))
    }
}

struct FoodView_Previews: PreviewProvider {
    static var service:FoodService =  {
        let s = FoodService()
        s.setStaistics(FoodService.Statistics(rating1: 10, rating2: 10, rating3: 20, rating4: 10, food: "Makaroner och korv"))
        return s
    }()
    static var previews: some View {
        LBPreviewContainer(identity:.food) {
            FoodView(service: service)
        }
    }
}
