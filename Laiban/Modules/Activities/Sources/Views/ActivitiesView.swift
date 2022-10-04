//
//  ActivitiesView.swift
//  LaibanApp
//
//  Created by Ehsan Zilaei on 2022-05-10.
//

import SwiftUI

import Combine
import SDWebImageSwiftUI
import Assistant

enum CirleViewRimWidth {
    case thin
    case normal
    case thick
    var percentage:CGFloat {
        switch self {
        case .thin: return 0.03
        case .normal: return 0.05
        case .thick: return 0.08
        }
    }
}
struct EmojiCircleSimpleView: View {
    var emoji:String
    var disabled:Bool = false
    var rimWidth:CirleViewRimWidth = .normal
    var body: some View {
        GeometryReader { proxy in
            Circle()
                .fill(Color.gray.opacity(0.1))
                .overlay(Text(self.emoji).font(Font.system(size: proxy.size.width * 0.5)))
                .padding(proxy.size.width * self.rimWidth.percentage)
                .frame(width: proxy.size.width, height: proxy.size.width)
                .background(Color.white.clipShape(Circle()))
                .shadow(color: Color.black.opacity(self.disabled ? 0 : 0.3), radius: self.disabled ? 0 : 4, x: 0, y: 0)
                .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
        }.aspectRatio(1, contentMode: .fit)
    }
}
struct PhotoCircleSimpleView: View {
    // proxy.size.width * 0.03
    var image:Image
    var disabled:Bool = false
    var rimWidth:CirleViewRimWidth = .normal
    var body: some View {
        GeometryReader { proxy in
            Circle()
                .strokeBorder(Color.white,lineWidth: proxy.size.width * self.rimWidth.percentage)
                .background(
                    self.image
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Circle())
                        .padding(proxy.size.width * self.rimWidth.percentage)
                )
                .shadow(color: Color.black.opacity(self.disabled ? 0 : 0.3), radius: self.disabled ? 0 : 4, x: 0, y: 0)
        }.frame(maxWidth:.infinity,maxHeight:.infinity,alignment: .center).aspectRatio(1, contentMode: .fit)
    }
}
struct PhotoURLCircleSimpleView: View {
    @State var loading:Bool = true
    var url:URL
    var disabled:Bool = false
    var rimWidth:CirleViewRimWidth = .normal
    var body: some View {
        GeometryReader { proxy in
            Circle()
                .strokeBorder(Color.white,lineWidth: proxy.size.width * self.rimWidth.percentage)
                .background(
                    WebImage(url: url)
                        .resizable()
                        .renderingMode(.original)
                        .placeholder {
                            LBActivityIndicator(isAnimating: $loading, style: .large).foregroundColor(.gray)
                        }
                        
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Circle())
                        .padding(proxy.size.width * self.rimWidth.percentage)
                )
                .shadow(color: Color.black.opacity(self.disabled ? 0 : 0.3), radius: self.disabled ? 0 : 4, x: 0, y: 0)
        }.frame(maxWidth:.infinity,maxHeight:.infinity,alignment: .center).aspectRatio(1, contentMode: .fit)
    }
}

public struct ActivitiesView: View {
    @Environment(\.fullscreenContainerProperties) var properties
    @ObservedObject var service: ActivityService
    @EnvironmentObject var assistant: Assistant
    
    struct Item : Identifiable {
        var id:String
        var image:Image?
        var imageURL:URL?
        var title:String
        var titleNew = [String]()
        var emoji:String
        var activity:Activity? = nil
        var goals:[UNDPGoal] = []
        init(id:String, image:Image?, title:String, emoji:String) {
            self.id = id
            self.image = image
            self.title = title
            self.emoji = emoji
        }
        init(_ activity:Activity) {
            self.id = activity.id
            self.image = Activity.imageStorage.image(with: activity.image)
            self.title = activity.formattedContent()
            self.titleNew = ["Todo"]
            self.emoji = activity.emoji ?? "🧩"
            self.imageURL = activity.imageURL
            self.activity = activity
            for tag in activity.sharedActivity?.tags ?? [] {
                guard let goal = UNDPGoal.goalFrom(sharedActivityTag: tag) else {
                    continue
                }
                self.goals.append(goal)
            }
        }
        var canReview:Bool {
            return activity?.canReview ?? false
        }
    }
    @State var title = "activities_title"
    @State var items = [Item]() {
        didSet {
            self.selectedItem = items.first
        }
    }
    @State var selectedItem:Item?
    @State var speechCarouselItems = Set<AnyCancellable>()
    func setupView() {
        let activities = service.todaysActivities
        guard activities.count > 0 else {
            title = "activities_nothing_here"
            assistant.speak(["activities_nothing_here"])
            
            return
        }
        var strings = [("activities_title","activities_title")]
        strings.append(contentsOf: items.map { ($0.title,$0.id) })
        title = "activities_title"
        assistant.speak(strings)
    }
    
    func listView (_ geometry: GeometryProxy) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 30) {
                Spacer()
                ForEach(items) { item in
                    Button(action: {
                        selectedItem = item
                        assistant.speak(item.title)
                    }) {
                        if item.image != nil {
                            PhotoCircleSimpleView(image: item.image!, disabled: assistant.isSpeaking)
                        } else if item.imageURL != nil {
                            PhotoURLCircleSimpleView(url: item.imageURL!, disabled:assistant.isSpeaking)
                        } else {
                            EmojiCircleSimpleView(emoji: item.emoji, disabled:assistant.isSpeaking)
                        }
                    }
                    .frame(width: geometry.size.height * 0.13 * properties.windowRatio, height: geometry.size.height * 0.13 * properties.windowRatio)
                    .scaleEffect(item.id == selectedItem?.id ? 1.3 : 1)
                    .animation(.easeInOut(duration: 0.2))
                    .disabled(assistant.isSpeaking)
                }
                Spacer()
            }
            .frame(minWidth:geometry.size.width,alignment: .center)
            .frame(height: properties.windowRatio * geometry.size.height * 0.2)
        }
        .frame(maxWidth:.infinity,alignment: .center)
        .frame(height: properties.windowRatio * geometry.size.height * 0.2)
    }
    
    var emptyView: some View {
        Group {
            Text(LocalizedStringKey(title),bundle: .module)
                .font(properties.font, ofSize: .n, weight: .heavy)
                .frame(maxWidth:.infinity)
                .padding()
            Spacer()
        }
    }
    public init(service:ActivityService) {
        self.service = service
    }
    public var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center, spacing: 10) {
                if service.todaysActivities.count == 0 {
                    emptyView
                } else {
                    Text(LocalizedStringKey(title),bundle: .module)
                        .font(properties.font, ofSize: .n, weight: .heavy)
                        .padding(.bottom, 5)
                    let item = selectedItem
                    if item != nil {
                        VStack {
                            if item?.image == nil && item?.imageURL == nil {
                                ActivitiesViewEmojiItem(title: item!.title, emoji: item!.emoji,goals:item!.goals)
                                    .frame(maxWidth:.infinity,maxHeight: .infinity)
                            } else if item?.image != nil {
                                ActivitiesViewImageItem(title: item!.title, goals:item!.goals)
                                    .modifier(ActivityImageModifier(image: item!.image!))
                                    .frame(maxWidth:.infinity,maxHeight: .infinity)
                            } else if item?.imageURL != nil {
                                ActivitiesViewImageItem(title: item!.title, goals:item!.goals)
                                    .modifier(ActivityImageURLModifier(url: item!.imageURL!))
                                    .frame(maxWidth:.infinity,maxHeight: .infinity)
                            } else {
                                EmptyView()
                            }
                        }
                        .animation(.easeInOut(duration: 0.2))
                        .onAppear {
                            LBAnalyticsProxy.shared.logContentImpression("Activity", piece: item?.activity?.content)
                        }
                    }
                    if items.count > 1 {
                        listView(geometry)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(properties.spacing[.m])
        .primaryContainerBackground()
        .multilineTextAlignment(.center)
        .onAppear {
            for activity in service.todaysActivities {
                items.append(Item(activity))
            }
            setupView()
            LBAnalyticsProxy.shared.logPageView(self)
        }
        .onReceive(assistant.tts.speaking) { utterance in
            guard let item = items.first(where: { $0.id == utterance.tag}) else {
                return
            }
            if item.id != self.selectedItem?.id {
                self.selectedItem = item
            }
        }
    }
}

struct ActivitiesView_Previews: PreviewProvider {
    static var service: ActivityService = {
        let now = Date()
        let serviceResult = ActivityService()
        
        var activityURL = Activity(date: now, content: "Image as URL", emoji: "⚽️")
        activityURL.imageURL = URL(string: "https://images.unsplash.com/photo-1630512996510-c6a301d874cc?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=672&q=80")
        
        let activityEmoji = Activity(date: now, content: "Context text", emoji: "🐘")
        
        serviceResult.data = [activityURL, activityEmoji]
        
        return serviceResult
    }()
    
    
    static var previews: some View {
        LBFullscreenContainer { _ in
            ActivitiesView(service: service)
        }.attachPreviewEnvironmentObjects()
    }
}
