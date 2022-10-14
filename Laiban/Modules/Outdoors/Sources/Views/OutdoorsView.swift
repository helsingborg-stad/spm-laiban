//
//  OutdoorsView.swift
//
//  Created by Tomas Green on 2020-05-25.
//

import SwiftUI
import Assistant
import Analytics

public struct OutdoorsView: View {
    func columns(items: Int) -> Int {
        if properties.layout == .landscape {
            if verticalSizeClass == .compact {
                return 7
            }
            return 4
        }
        return 3
    }
    
    func padding(_ proxy: GeometryProxy) -> CGFloat {
        return proxy.size.width * 0.04
    }
    
    func itemSize(_ proxy: GeometryProxy, columns: Int) -> CGFloat {
        return (proxy.size.width - padding(proxy) * CGFloat(columns + 1)) / CGFloat(columns)
    }
    
    @Environment(\.fullscreenContainerProperties) var properties
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @EnvironmentObject var assistant: Assistant
    @EnvironmentObject var viewState:LBViewState
    @ObservedObject var service: OutdoorsService
    
    @State private var viewModel: OutdoorsViewModel
    
    public init(service: OutdoorsService) {
        self.service = service
        _viewModel = .init(wrappedValue: OutdoorsViewModel(service))
    }
    
    @State var isPressingUpdateIcon: Bool = false
    var regularContainer: some View {
        GeometryReader { proxy in
            let columns = columns(items: viewModel.garments.count)
            LBGridView(items: viewModel.garments.count, columns: columns, horizontalSpacing: self.padding(proxy), verticalAlignment: .top) { index in
                GarmentView(garment: self.viewModel.garments[index]) { garment in
                    AnalyticsService.shared.log(AnalyticsService.CustomEventType.ButtonPressed.rawValue, properties: ["Button":"RepeatGarment","Garment":self.viewModel.garments[index].rawValue])
                    assistant.speak([(self.viewModel.garments[index].localizationKey, self.viewModel.garments[index].localizationKey)])
                }
                .frame(width:itemSize(proxy, columns: columns),height:itemSize(proxy, columns: columns) * 1.1)
                .scaleEffect(self.viewModel.zoomedGarment == self.viewModel.garments[index] ? 1.2 : 1)
                .animation(Animation.easeInOut(duration: 0.2))
            }
            .font(.system(size: itemSize(proxy, columns: columns) * 0.10, weight: .semibold, design: .rounded))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding([.leading, .trailing, .top, .bottom], 20)
    }
    
    var updateBox: some View {
        return HStack(spacing: properties.spacing[.m]) {
            Text(LocalizedStringKey("outdoors_feedback_change_description"), bundle: LBBundle)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("🧑‍💼")
                .font(.system(size: properties.windowSize.height * 0.026))
                .padding(10)
                .background(Circle().fill(Color.black).opacity(0.1))
                .background(Circle().stroke(Color.black, lineWidth: 2).opacity(0.7))
                .onLongPressGesture(minimumDuration: 1.5, pressing: { p in
                    withAnimation {
                        isPressingUpdateIcon = p
                    }
                }, perform: {
                    viewModel.didPressUserAction(button: .changeClothes)
                })
                .opacity(isPressingUpdateIcon ? 0.5 : 1)
        }
        .font(properties.font, ofSize: .s)
        .frame(maxWidth: .infinity)
        .padding(properties.spacing[.m])
        .primaryContainerBackground()
        .scaleEffect(assistant.currentlySpeaking?.tag == "outdoors_feedback_change_description" ? 1.05 : 1)
        .id("updateBox")
        .animation(Animation.easeInOut(duration: 0.2))
    }
    
    func questionBox() -> some View {
        let feedbackDescription = viewModel.feedbackState.text
        return HStack(spacing: properties.spacing[.m]) {
            Text(LocalizedStringKey(feedbackDescription), bundle: LBBundle).frame(maxWidth: .infinity, alignment: .leading)
            if viewModel.feedbackState == .provideFeedback {
                Button(action: {
                    if viewModel.feedbackState == .provideFeedback {
                        viewModel.didPressUserAction(button: .rateBad)
                    }
                }) {
                    LBEmojiBadgeView(emoji: viewModel.feedbackState == .provideFeedback ? "🙁" : "👎", rimColor: viewModel.feedbackState == .provideFeedback ? LBFeedbackReaction.sad.color : .white).frame(maxHeight: .infinity)
                }
                .frame(width: properties.contentSize.height * 0.055, height: properties.contentSize.height * 0.055)
                Button(action: {
                    print(viewModel.feedbackState)
                    if viewModel.feedbackState == .provideFeedback {
                        viewModel.didPressUserAction(button: .rateGood)
                    }
                }) {
                    LBEmojiBadgeView(emoji: viewModel.feedbackState == .provideFeedback ? "😃" : "👍", rimColor: viewModel.feedbackState == .provideFeedback ? LBFeedbackReaction.veryHappy.color : .white).frame(maxHeight: .infinity)
                }
                .frame(width: properties.contentSize.height * 0.055, height: properties.contentSize.height * 0.055)
            }
        }
        .font(properties.font, ofSize: .s)
        .frame(maxWidth: .infinity)
        .padding(properties.spacing[.m])
        .primaryContainerBackground()
        .scaleEffect(assistant.currentlySpeaking?.tag == feedbackDescription ? 1.05 : 1)
        .id("questionbox")
        .animation(Animation.easeInOut(duration: 0.2))
    }
    
    var textBox: some View {
        VStack {
            Text(viewModel.temperatureString)
                .font(properties.font, ofSize: .n, weight: .heavy)
            Text(LocalizedStringKey("outdoors_go_out"),bundle: LBBundle)
                .font(properties.font, ofSize: .s)
                .padding(.top, 10)
        }
        .padding(EdgeInsets(top: 15, leading: 15, bottom: 15, trailing: 15))
        .multilineTextAlignment(.center)
    }
    
    var regularBody: some View {
        let spacing = properties.spacing[.m]
        return HStack(spacing: spacing) {
            VStack(spacing: spacing) {
                LBEmojiBadgeView(emoji: viewModel.currentWeatherEmoji, rimColor: Color("RimColorWeather",bundle:LBBundle)).onTapGesture {
                    self.viewModel.update()
                }
                ThermometerView(temperature: round(service.weather?.airTemperatureFeelsLike ?? 0))
            }
            .frame(width: properties.contentSize.width * 0.15)
            .padding(spacing)
            .primaryContainerBackground()
            VStack(spacing: spacing) {
                VStack {
                    textBox
                    regularContainer
                }
                .padding(spacing)
                .primaryContainerBackground()
                questionBox()
                updateBox
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onAppear {
            AnalyticsService.shared.logPageView(self)
        }
    }
    
    var compactBody: some View {
        VStack {
            let columns = columns(items: viewModel.garments.count)
            textBox
            GeometryReader { proxy in
                LBGridView(items: viewModel.garments.count, columns: columns, horizontalSpacing: self.padding(proxy), verticalAlignment: .top) { index in
                    GarmentView(garment: self.viewModel.garments[index]) { garment in
                        AnalyticsService.shared.log(AnalyticsService.CustomEventType.ButtonPressed.rawValue, properties: ["Button":"RepeatGarment","Garment":self.viewModel.garments[index].rawValue])
                        assistant.speak([(self.viewModel.garments[index].localizationKey, self.viewModel.garments[index].localizationKey)])
                    }
                    .frame(width:itemSize(proxy, columns: columns),height:itemSize(proxy, columns: columns) * 1.1)
                    .scaleEffect(self.viewModel.zoomedGarment == self.viewModel.garments[index] ? 1.2 : 1)
                    .animation(Animation.easeInOut(duration: 0.2))
                }
                .font(.system(size: itemSize(proxy, columns: columns) * 0.10, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        .wrap(overlay: .emoji(viewModel.currentWeatherEmoji, Color("RimColorWeather",bundle:.module)))
    }
    
    public var body: some View {
        Group {
            if viewModel.viewSection == .clothes {
                if horizontalSizeClass == .regular && verticalSizeClass == .regular {
                    regularBody
                } else {
                    compactBody
                }
            } else if viewModel.viewSection == .changeClothes {
                OutdoorClothesSelectorView(viewModel: viewModel, selection: viewModel.garments) { selection in
                    viewModel.reportGarments(selection)
                    viewModel.didChange = true
                    viewModel.didPressUserAction(button: .done)
                    viewModel.viewSection = .clothes
                    viewState.actionButtons([.languages,.home], for: .outdoors)
                }
            }
        }.onAppear {
            viewModel.initiate(using: assistant,viewState:viewState)
            viewState.characterHidden(true, for: .outdoors)
            // AnalyticsService.shared.logPageView(self)
        }.onDisappear {
            if viewModel.didChange == false && viewModel.didRateBad == false {
                viewModel.rate(.good, tag: .system)
            }
        }
        .onReceive(properties.actionBarNotifier) { action in
            if action == .back {
                viewState.actionButtons([.languages,.home], for: .outdoors)
                viewModel.viewSection = .clothes
            }
        }
    }
}

struct OutdoorsView_PreviewPad: PreviewProvider {
    static var service = OutdoorsService()
    static var previews: some View {
        LBFullscreenContainer { _ in
            OutdoorsView(service: service)
        }
        .attachPreviewEnvironmentObjects()
    }
}
