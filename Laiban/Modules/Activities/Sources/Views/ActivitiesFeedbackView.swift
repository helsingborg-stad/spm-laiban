import SwiftUI
import Combine
import Assistant
import SDWebImageSwiftUI

public struct ActivitiesFeedbackView : View {
    struct Item : Identifiable,Equatable {
        var id:String
        var image:Image?
        var imageURL:URL?
        var title:String
        var titleNew = [String]()
        var emoji:String
        var activity:Activity
        var goals:[UNDPGoal] = []
        init(_ activity:Activity) {
            self.id = activity.id
            self.image = Activity.imageStorage.image(with: activity.image)
            self.title = activity.content
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
            return activity.canReview
        }
    }
    @EnvironmentObject var viewState:LBViewState
    @EnvironmentObject var assistant:Assistant
    @Environment(\.fullscreenContainerProperties) var properties
    @Environment(\.locale) var locale
    var service = ActivityService()
    var items:[Item]
    @State var selectedItem:Item?
    @State var cancellables = Set<AnyCancellable>()
    @State var reaction:LBFeedbackReaction?
    @State var isLoading:Bool = false
    public init(service:ActivityService) {
        self.service = service
        self.items = service.todaysActivities.filter({ $0.canReview}).map({ Item($0) })
        if items.count == 1 {
            _selectedItem = State(initialValue: items.first)
        }
    }
    var selectItemView: some View {
        ScrollView {
            VStack(spacing:properties.spacing[.m]) {
                Text(LocalizedStringKey("feedback_select_activity"),bundle:.module)
                    .frame(maxWidth:.infinity,alignment:.center)
                    .font(properties.font,ofSize:.n)
                let p = properties.spacing[.m]
                let width = (properties.contentSize.width - p * 2 - p/2)/2
                LBGridView(items: items.count, columns: 2,verticalSpacing: p,horizontalSpacing: p) { index in
                    let item = items[index]
                    Button {
                        withAnimation {
                            selectedItem = item
                        }
                    } label: {
                        if item.image == nil && item.imageURL == nil {
                            ActivitiesViewEmojiItem(title: item.title, emoji: item.emoji,goals:item.goals, fontSize: .xxs)
                                .aspectRatio(6/4,contentMode: .fit)
                                .frame(width: width)
                        } else if item.image != nil {
                            ActivitiesViewImageItem(title: item.title, goals:item.goals, fontSize: .xxs)
                                .modifier(ActivityImageModifier(image: item.image!))
                                .aspectRatio(6/4,contentMode: .fit)
                                .frame(width: width)
                                
                        } else if item.imageURL != nil {
                            ActivitiesViewImageItem(title: item.title, goals:item.goals, fontSize: .xxs)
                                .modifier(ActivityImageURLModifier(url: item.imageURL!))
                                .aspectRatio(6/4,contentMode: .fit)
                                .frame(width: width)
                        } else {
                            EmptyView()
                        }
                    }
                    .buttonStyle(LBScaleEffectButtonStyle())
                    .scaleEffect(assistant.currentlySpeaking?.tag == item.id ? 1.02 : 1)
                    .animation(.spring(), value: assistant.currentlySpeaking)
                    .id(item.id)
                }
            }
            .padding(properties.spacing[.m])
        }
        .frame(maxWidth:.infinity,maxHeight: .infinity)
        .primaryContainerBackground()
        .onAppear {
            var strings = [("feedback_select_activity","feedback_select_activity")]
            strings.append(contentsOf: items.map { ($0.title,$0.id) })
            assistant.speak(strings)
        }
    }
    var didRateView: some View {
        VStack {
            Spacer()
            LBEmojiBadgeView(emoji: reaction!.emoji, rimColor: reaction!.color)
                .aspectRatio(1,contentMode: .fit)
                .frame(width: properties.contentSize.height * 0.4, height: properties.contentSize.height * 0.4)
            Spacer()
            Text(LocalizedStringKey("feedback_activity_thanks"),bundle:.module)
                .frame(maxWidth:.infinity,alignment:.leading)
                .padding(properties.spacing[.m])
                .primaryContainerBackground()
                .font(properties.font,ofSize:.n)
        }
        .onAppear {
            assistant.speak("feedback_activity_thanks").last?.statusPublisher.sink(receiveValue: { status in
                if status == .finished {
                    viewState.clear()
                }
            }).store(in: &cancellables)
        }
    }
    var rateView: some View {
        GeometryReader { geometry in
            VStack(alignment: .center, spacing: properties.spacing[.m]) {
                let item = selectedItem!
                if item.image == nil && item.imageURL == nil {
                    ActivitiesViewEmojiItem(title: item.title, emoji: item.emoji,goals:item.goals)
                        .frame(maxWidth:.infinity,maxHeight: .infinity)
                } else if item.image != nil {
                    ActivitiesViewImageItem(title: item.title, goals:item.goals)
                        .modifier(ActivityImageModifier(image: item.image!))
                        .frame(maxWidth:.infinity,maxHeight: .infinity)
                } else if item.imageURL != nil {
                    ActivitiesViewImageItem(title: item.title, goals:item.goals)
                        .modifier(ActivityImageURLModifier(url: item.imageURL!))
                        .frame(maxWidth:.infinity,maxHeight: .infinity)
                } else {
                    EmptyView()
                }
                LBFeedbackReactionsListView { reaction in
                    self.reaction = reaction
                    self.service.register(reaction, to: selectedItem!.activity)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(properties.spacing[.m])
        .primaryContainerBackground()
        .multilineTextAlignment(.center)
        .onAppear {
            assistant.cancelSpeechServices()
        }
    }
    public var body: some View {
        VStack(spacing:properties.spacing[.m]) {
            if reaction != nil {
                didRateView
                    .transition(.opacity.combined(with: .move(edge: .leading)))
            } else if selectedItem != nil {
                rateView
                    .transition(.opacity.combined(with: .move(edge: .leading)))
            } else {
                selectItemView
                    .transition(.opacity.combined(with: .move(edge: .leading)))
            }
        }
        
        .animation(.spring(), value:selectedItem)
        .animation(.spring(), value:reaction)
    }
}

struct ActivitiesFeedbackView_Previews: PreviewProvider {
    static var service:ActivityService = {
        let s = ActivityService()
        let now = Date()
        var a1 = Activity(
            date: now,
            content: "En kortare text",
            emoji: "🧑‍🎓",
            starts: now.addingTimeInterval(60 * -120),
            ends: now.addingTimeInterval(60 * -10)
        )
        var a3 = Activity(
            date: now,
            content: "En kortare text",
            emoji: "🧑‍🎓",
            starts: now.addingTimeInterval(60 * -120),
            ends: now.addingTimeInterval(60 * -10)
        )
        var a4 = Activity(
            date: now,
            content: "En kortare text",
            emoji: "🧑‍🎓",
            starts: now.addingTimeInterval(60 * -120),
            ends: now.addingTimeInterval(60 * -10)
        )
        var a5 = Activity(
            date: now,
            content: "En kortare text",
            emoji: "🧑‍🎓",
            starts: now.addingTimeInterval(60 * -120),
            ends: now.addingTimeInterval(60 * -10)
        )
        a1.imageURL = URL(string: "https://images.unsplash.com/photo-1630512996510-c6a301d874cc?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=672&q=80")
        var a2 = Activity(
            date: now,
            content: "Ee lite längre test som ska bryta rader?",
            emoji: "🧑‍🎓",
            activityParticipants: ["Simon", "Lisa"],
            starts: now.addingTimeInterval(60 * -120),
            ends: now.addingTimeInterval(60 * -10)
        )
        a2.imageURL = URL(string: "https://images.unsplash.com/photo-1655321591297-2e332ad3859f?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=688&q=80")
        a3.imageURL = URL(string: "https://images.unsplash.com/photo-1655365225178-b1b4c59cbdb2?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1470&q=80")
        s.add(a1)
        s.add(a2)
        s.add(a3)
        s.add(a4)
        s.add(a5)
        return s
    }()
    static var previews: some View {
        LBFullscreenContainer { _ in
            ActivitiesFeedbackView(service: service)
            //ActivitiesFeedbackHomeView(service: service)
        }.attachPreviewEnvironmentObjects(ttsDisabled: true)
    }
}
