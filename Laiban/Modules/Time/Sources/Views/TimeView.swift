//
//  TimeView.swift
//
//  Created by Tomas Green on 2020-03-16.
//

import SwiftUI
import Compression
import SDWebImageSwiftUI
import Combine
import Analytics
import Assistant

struct PersonView :View {
    @State var loading:Bool = false
    var name:String
    var avatar:URL?
    var body: some View {
        GeometryReader { proxy in
            VStack {
                WebImage(url: avatar)
                    .resizable()
                    .placeholder {
                        if avatar != nil {
                            LBActivityIndicator(isAnimating: $loading, style: .large).foregroundColor(.gray)
                        } else {
                            Image(systemName: "photo.circle.fill").renderingMode(.original).resizable().aspectRatio(1, contentMode: .fit).foregroundColor(.white).opacity(0.7)
                        }
                    }
                    .aspectRatio(1,contentMode: .fill)
                    .background(Color.black.opacity(0.7))
                    .clipShape(Circle())
                    .frame(width: proxy.size.height * 0.65, height: proxy.size.height * 0.65)
                Text(name)
            }.frame(maxWidth:.infinity,maxHeight:.infinity)
        }.frame(maxWidth:.infinity,maxHeight:.infinity)
    }
}
public struct TimeView: View {
    @Environment(\.fullscreenContainerProperties) var properties
    @EnvironmentObject var assistant:Assistant
    @EnvironmentObject var viewState:LBViewState
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @StateObject var viewModel = TimeViewModel()
    @State var showChildInfo = false
    @State var cancellables = Set<AnyCancellable>()
    @ObservedObject var service:TimeService
    static let showChildInfoId = "TimeView.showChildInfo"
    var contentProvider:TimeViewContentProvider? = nil
    var selectedChildIsHere:Bool {
        viewModel.arrivesClockViewModel != nil && viewModel.leavesClockViewModel != nil && viewModel.selectedChild?.isHereToday == true
    }
    public init(service:TimeService,contentProvider:TimeViewContentProvider?) {
        self.service = service
        self.contentProvider = contentProvider
    }
    var childGrid: some View {
        GeometryReader { p in
            let cols:CGFloat = 8
            let w = (p.size.width - properties.spacing[.m] * 2 - 10 * (cols - 1))/cols
            ScrollView {
                LBGridView(items: viewModel.children.count, columns: Int(cols), verticalSpacing: 10, horizontalSpacing: 10, verticalAlignment: .bottom, horizontalAlignment: .center) { index in
                    Button(action: {
                        withAnimation(.spring()) {
                            self.viewModel.select(viewModel.children[index])
                        }
                    }) {
                        PersonView(name: viewModel.children[index].name, avatar: viewModel.children[index].avatar)
                            .frame(width: w, height:w)
                    }
                }
                .padding(properties.spacing[.m])
            }
            .frame(maxWidth:.infinity,maxHeight:.infinity,alignment: .center)
            .font(properties.font, ofSize: .xxxs)
            .primaryContainerBackground()
        }
    }
    var personClockView: some View {
        HStack(spacing:properties.spacing[.m]) {
            Button(action: viewModel.showArrivesLabel) {
                VStack {
                    if viewModel.arrivesTitle != nil {
                        Text(viewModel.arrivesTitle!)
                            .frame(maxWidth:.infinity)
                            .font(properties.font, ofSize: .xs)
                            .padding(properties.spacing[.s])
                            .primaryContainerBackground()
                    }
                    ClockView(viewModel.arrivesClockViewModel!) { item in
                        if assistant.isSpeaking {
                            return
                        }
                        AnalyticsService.shared.log(AnalyticsService.CustomEventType.ButtonPressed.rawValue, properties: ["Button":"ClockEmoji", "Emoji":item.emoji, "EmojiText":item.text])
                        self.viewModel.showText(text: LBVoiceString(viewModel.localizedString(for: item)), speakAfter: true)
                    }
                    .frame(maxWidth:.infinity,maxHeight:.infinity)
                    .disabled(true)
                    
                }
            }
            Button(action: viewModel.showLeavesLabel) {
                VStack {
                    if viewModel.leavesTitle != nil {
                        Text(viewModel.leavesTitle!)
                            .frame(maxWidth:.infinity)
                            .font(properties.font, ofSize: .xs)
                            .padding(properties.spacing[.s])
                            .primaryContainerBackground()
                    }
                    ClockView(viewModel.leavesClockViewModel!) { item in
                        if assistant.isSpeaking {
                            return
                        }
                        AnalyticsService.shared.log(AnalyticsService.CustomEventType.ButtonPressed.rawValue, properties: ["Button":"ClockEmoji", "Emoji":item.emoji, "EmojiText":item.text])
                        self.viewModel.showText(text: LBVoiceString(viewModel.localizedString(for: item)), speakAfter: true)
                    }
                    .frame(maxWidth:.infinity,maxHeight:.infinity)
                    .disabled(true)
                }
            }
        }
    }
    var clockView: some View {
        ClockView(self.viewModel.clockViewModel) { item in
            if assistant.isSpeaking {
                return
            }
            AnalyticsService.shared.log(AnalyticsService.CustomEventType.ButtonPressed.rawValue, properties: ["Button":"ClockEmoji", "Emoji":item.emoji, "EmojiText":item.text])
            self.viewModel.showText(text: LBVoiceString(viewModel.localizedString(for: item)), speakAfter: true)
        }
        .onTapGesture {
            if assistant.isSpeaking {
                return
            }
            if let ts = TimeSpan.currentTimeLabel() {
                self.viewModel.showText(text: LBVoiceString(assistant.string(forKey: ts.localizedKey), id: UUID().uuidString), speakAfter: true)
            }
            AnalyticsService.shared.log(AnalyticsService.CustomEventType.ButtonPressed.rawValue, properties: ["Button":"ClockFace"])
        }
        .frame(maxWidth:.infinity,maxHeight:.infinity)
    }
    var textBox: some View {
        VStack{
            let texts = self.viewModel.showChildInfo ? self.viewModel.tempusTexts : self.viewModel.todayTexts
            ForEach(texts, id:\.id) { string in
                Text(string.display)
                    .font(properties.font, ofSize: .n)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth:.infinity,alignment: .top)
        .padding(properties.spacing[.m])
        .primaryContainerBackground()
    }
    public var body: some View {
        VStack {
            if viewModel.showChildInfo {
                if selectedChildIsHere {
                    personClockView
                } else {
                    GeometryReader { p in
                        Text( viewModel.selectedChild == nil ? "💡" : "🤷").font(.system(size: p.size.height * 0.5))
                            .frame(maxWidth:.infinity,maxHeight:.infinity)
                    }.frame(maxWidth:.infinity,maxHeight:.infinity)
                }
            } else {
                clockView
            }
            VStack {
                textBox
                //.frame(height: proxy.size.height * 0.06, alignment: .top)
                if self.horizontalSizeClass == .regular, viewModel.showChildInfo == false {
                    HorizontalTimeLineView(viewModel: viewModel.clockViewModel) { item in
                        AnalyticsService.shared.log(AnalyticsService.CustomEventType.ButtonPressed.rawValue, properties: ["Button":"TimeLineEmoji", "Emoji":item.emoji, "EmojiText":item.text])
                        self.viewModel.showText(text: LBVoiceString(viewModel.localizedString(for: item)), speakAfter: true)
                    }
                    .padding(properties.spacing[.m])
                    .primaryContainerBackground()
                } else if self.viewModel.showChildInfo {
                    childGrid.frame(height: properties.contentSize.height * 0.30, alignment: .bottom)
                }
            }
        }
        .onAppear {
            viewModel.initiate(using: assistant, service: service)
            viewState.characterHidden(true, for: .time)
            contentProvider?.childrenPublisher().sink(receiveValue: { children in
                if let children = children {
                    self.viewModel.children = children
                } else {
                    print("⚠️ [\(#fileID):\(#function):\(#line)] " + String(describing: "We are not handling nil results from content provider"))
                }
                
            }).store(in: &cancellables)
            contentProvider?.otherClockItemsPublisher().sink(receiveValue: { items in
                viewModel.otherClockItems = items ?? []
                viewModel.update()
            }).store(in: &cancellables)
            AnalyticsService.shared.logPageView(self)
        }
        .onDisappear() {
            cancellables.removeAll()
        }
        .onReceive(viewState.$options) { val in
            guard let opt = viewState.options, opt == TimeView.showChildInfoId else {
                viewModel.setChildInfoVisible(false)
                viewState.actionButtons([.languages,.home], for: .time)
                return
            }
            viewState.actionButtons([.languages,.back], for: .time)
            viewModel.setChildInfoVisible(true)
        }
        .onReceive(properties.actionBarNotifier) { action in
            if action == .back {
                viewState.clearOptions(for: .time)
                viewModel.setChildInfoVisible(false)
            }
        }
        .environmentObject(self.viewModel.clockViewModel)
        .transition(.opacity.combined(with: .scale))
    }
    
}

struct TimeView_Previews: PreviewProvider {
    static var service: TimeService = {
        let service = TimeService()
        return service
    }()
    static var previews: some View {
        LBFullscreenContainer { _ in
            TimeView(service: service, contentProvider: nil)
        }.attachPreviewEnvironmentObjects()
    }
}
