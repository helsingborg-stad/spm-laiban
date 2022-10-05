//
//  SwiftUIView.swift
//  
//
//  Created by Tomas Green on 2022-05-13.
//

import SwiftUI
import Combine
import Assistant

public struct LBRootViewConfig {
    internal let dashboardItems:[[LBDashboardItem]]
    internal let adminServices:[LBAdminService]
    internal let languageService:LanguageService?
    internal let homescreenService:ReturnToHomeScreenService?
    public init(dashboardItems:[[LBDashboardItem]], adminServices:[LBAdminService]) {
        self.dashboardItems = dashboardItems
        self.adminServices = adminServices
        self.languageService = adminServices.first(where: { $0 is LanguageService }) as? LanguageService
        self.homescreenService = adminServices.first(where: { $0 is ReturnToHomeScreenService }) as? ReturnToHomeScreenService
    }
}
public struct LBRootView<Screen:View, Icon:View, ActionBar:View> : View {
    public typealias ShouldDisable = () -> Bool
    public typealias InactivityTimeInterval = TimeInterval
    public typealias ContainerAction = (LBFullscreenContainerAction) -> Void
    public typealias ViewDidChange = (LBViewIdentity?) -> Void
    public typealias LanguageDidChange = (Locale) -> Void
    @EnvironmentObject var assistant:Assistant
    @StateObject var viewState = LBViewState()
    @Environment(\.locale) var locale
    @State private var cancellables = Set<AnyCancellable>()
    @State private var nonAvailableItems = [LBViewIdentity]()
    @State private var isDisabled:Bool = false
    var config: LBRootViewConfig
    var viewChanged: ViewDidChange?
    var shouldDisable: ShouldDisable?
    var containerAction: ContainerAction?
    var langaugeChanged: LanguageDidChange?
    var screen:(LBViewIdentity?,LBFullscreenContainerProperties) -> Screen
    var icon:(LBViewIdentity?) -> Icon
    var actionBar:(LBViewIdentity?,LBAactionBarProperties) -> ActionBar
    public var body: some View {
        LBFullscreenContainer { props in
            if viewState.value == .languages && config.languageService != nil {
                LanguageSelectionView(service: config.languageService!, currentLocale: locale) { locale in
                    withAnimation {
                        guard let locale = locale else {
                            viewState.dismiss()
                            return
                        }
                        self.langaugeChanged?(locale)
                        viewState.dismiss()
                    }
                }
            } else if viewState.value == .home {
                LBDashboard(items: dashboardLayout(config.dashboardItems)) {
                    screen(.home,props)
                }
                .onSelectItem { item in
                    viewState.navigate(to: item)
                }
                .onRenderIcon { item in
                    icon(item)
                }
                .hide(nonAvailableItems)
                .transition(.opacity.combined(with: .asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading))))
            } else {
                screen(viewState.value, props)
            }
        }
        .onContainerAction { action in
            viewState.registerInteraction()
            if let c = containerAction  {
                c(action)
            } else {
                switch action {
                case .back:
                    if viewState.previousValue != nil {
                        viewState.dismiss()
                    }
                case .home: viewState.clear()
                case .languages:
                    assistant.cancelSpeechServices()
                    viewState.present(.languages)
                case .admin:  break
                case .character: break
                case .custom(let string):
                    for item in self.flatten(config.dashboardItems) {
                        if item.viewIdentity.id == string {
                            viewState.navigate(to: item.viewIdentity)
                            break;
                        }
                    }
                }
            }
        }
        .character(image: viewState.characterImage)
        .character(hidden: viewState.characterHidden)
        .character(position: viewState.characterPosition)
        .actionBarButtons(viewState.actionButtons)
        .adminServices(adminServices: config.adminServices)
        .actionBar({ p in
            actionBar(viewState.value,p)
        })
        .environmentObject(viewState)
        .animation(.spring(), value: viewState.value)
        .statusBar(hidden: true)
        .onReceive(viewState.$value) { val in
            viewState.registerInteraction()
            assistant.cancelSpeechServices()
            viewChanged?(val)
        }
        .onReceive(assistant.$isSpeaking) { isSpeaking in
            viewState.inactivityTimeInterval = isSpeaking ? 0 : (config.homescreenService?.data.timeInterval ?? 0)
            isDisabled = isSpeaking && shouldDisable?() != false
        }
        .disabled(isDisabled)
        .onAppear {
            for item in flatten(config.dashboardItems) {
                item.isAvailablePublisher.sink { available in
                    if available {
                        self.nonAvailableItems.removeAll { $0 == item.viewIdentity }
                    } else {
                        self.nonAvailableItems.append(item.viewIdentity)
                    }
                }.store(in: &cancellables)
            }
            config.homescreenService?.$data.sink { val in
                self.viewState.inactivityTimeInterval = val.timeInterval
            }.store(in: &cancellables)
        }
    }
    private func flatten(_ items:[[LBDashboardItem]]) -> [LBDashboardItem] {
        var arr = [LBDashboardItem]()
        items.forEach { i in
            arr.append(contentsOf: i)
        }
        return arr
    }
    private func dashboardLayout(_ items:[[LBDashboardItem]]) -> [[LBViewIdentity]] {
        var arr = [[LBViewIdentity]]()
        items.forEach { i in
            arr.append(i.map({ $0.viewIdentity }))
        }
        return arr
    }
}
public extension LBRootView {
    func screen<B:View>(@ViewBuilder screen: @escaping (LBViewIdentity?,LBFullscreenContainerProperties) -> B) -> LBRootView<B,Icon,ActionBar> {
        LBRootView<B,Icon,ActionBar>(
            config: config,
            viewChanged: viewChanged,
            shouldDisable: shouldDisable,
            containerAction: containerAction,
            langaugeChanged: langaugeChanged,
            screen: screen,
            icon: icon,
            actionBar:actionBar
        )
    }
    func icon<C:View>(@ViewBuilder icon: @escaping (LBViewIdentity?) -> C) -> LBRootView<Screen,C,ActionBar>  {
        LBRootView<Screen,C,ActionBar>(
            config: config,
            viewChanged: viewChanged,
            shouldDisable: shouldDisable,
            containerAction: containerAction,
            langaugeChanged: langaugeChanged,
            screen: screen,
            icon: icon,
            actionBar: actionBar
        )
    }
    func actionBar<D:View>(@ViewBuilder actionBar: @escaping (LBViewIdentity?,LBAactionBarProperties) -> D) -> LBRootView<Screen,Icon,D>  {
        LBRootView<Screen,Icon,D>(
            config: config,
            viewChanged: viewChanged,
            shouldDisable: shouldDisable,
            containerAction: containerAction,
            langaugeChanged: langaugeChanged,
            screen: screen,
            icon: icon,
            actionBar: actionBar
        )
    }
    func onLangaugeChanged(_ langaugeChanged: LanguageDidChange?) -> Self {
        Self.init(
            config: config,
            viewChanged: viewChanged,
            shouldDisable: shouldDisable,
            containerAction: containerAction,
            langaugeChanged: langaugeChanged,
            screen: screen,
            icon: icon,
            actionBar: actionBar
        )
    }
    func onViewChanged(_ viewChanged: ViewDidChange?) -> Self {
        Self.init(
            config: config,
            viewChanged: viewChanged,
            shouldDisable: shouldDisable,
            containerAction: containerAction,
            langaugeChanged: langaugeChanged,
            screen: screen,
            icon: icon,
            actionBar: actionBar
        )
    }
    func onShouldDisable(_ shouldDisable: ShouldDisable?) -> Self {
        Self.init(
            config: config,
            viewChanged: viewChanged,
            shouldDisable: shouldDisable,
            containerAction: containerAction,
            langaugeChanged: langaugeChanged,
            screen: screen,
            icon: icon,
            actionBar: actionBar
        )
    }
    func onContainerAction(_ containerAction:ContainerAction?) -> Self {
        Self.init(
            config: config,
            viewChanged: viewChanged,
            shouldDisable: shouldDisable,
            containerAction: containerAction,
            langaugeChanged: langaugeChanged,
            screen: screen,
            icon: icon,
            actionBar: actionBar
        )
    }
    init(
        config:LBRootViewConfig,
        viewChanged: ViewDidChange? = nil,
        shouldDisable: ShouldDisable? = nil,
        containerAction:ContainerAction? = nil,
        langaugeChanged: LanguageDidChange? = nil,
        @ViewBuilder screen: @escaping (LBViewIdentity?,LBFullscreenContainerProperties) -> Screen
    ) where Icon == EmptyView, ActionBar == EmptyView  {
        self.init(
            config: config,
            viewChanged: viewChanged,
            shouldDisable: shouldDisable,
            containerAction: containerAction,
            langaugeChanged: langaugeChanged,
            screen: screen,
            icon: { _ in EmptyView() },
            actionBar:  { (_,_) in EmptyView() }
        )
    }
    init(
        config:LBRootViewConfig,
        viewChanged: ViewDidChange? = nil,
        shouldDisable: ShouldDisable? = nil,
        containerAction:ContainerAction? = nil,
        langaugeChanged: LanguageDidChange? = nil,
        @ViewBuilder icon: @escaping (LBViewIdentity?) -> Icon
    ) where Screen == EmptyView, ActionBar == EmptyView {
        self.init(
            config: config,
            viewChanged: viewChanged,
            shouldDisable: shouldDisable,
            containerAction: containerAction,
            langaugeChanged: langaugeChanged,
            screen: { (_,_) in EmptyView() },
            icon: icon,
            actionBar: { (_,_) in EmptyView() }
        )
    }
    init(
        config:LBRootViewConfig,
        viewChanged: ViewDidChange? = nil,
        shouldDisable: ShouldDisable? = nil,
        containerAction:ContainerAction? = nil,
        langaugeChanged: LanguageDidChange? = nil,
        @ViewBuilder actionBar: @escaping (LBViewIdentity?,LBAactionBarProperties) -> ActionBar
    ) where Icon == EmptyView, Screen == EmptyView {
        self.init(
            config: config,
            viewChanged: viewChanged,
            shouldDisable: shouldDisable,
            containerAction: containerAction,
            langaugeChanged: langaugeChanged,
            screen: { (_,_) in EmptyView() },
            icon: { _ in EmptyView() },
            actionBar:  actionBar
        )
    }
    init(
        config:LBRootViewConfig,
        viewChanged: ViewDidChange? = nil,
        shouldDisable: ShouldDisable? = nil,
        containerAction:ContainerAction? = nil,
        langaugeChanged: LanguageDidChange? = nil,
        @ViewBuilder screen: @escaping (LBViewIdentity?,LBFullscreenContainerProperties) -> Screen,
        @ViewBuilder actionBar: @escaping (LBViewIdentity?,LBAactionBarProperties) -> ActionBar
    ) where Icon == EmptyView  {
        self.init(
            config: config,
            viewChanged: viewChanged,
            shouldDisable: shouldDisable,
            containerAction: containerAction,
            langaugeChanged: langaugeChanged,
            screen: screen,
            icon: { _ in EmptyView() },
            actionBar: actionBar
        )
    }
    init(
        config:LBRootViewConfig,
        viewChanged: ViewDidChange? = nil,
        shouldDisable: ShouldDisable? = nil,
        containerAction:ContainerAction? = nil,
        langaugeChanged: LanguageDidChange? = nil,
        @ViewBuilder icon: @escaping (LBViewIdentity?) -> Icon,
        @ViewBuilder actionBar: @escaping (LBViewIdentity?,LBAactionBarProperties) -> ActionBar
    ) where Screen == EmptyView {
        self.init(
            config: config,
            viewChanged: viewChanged,
            shouldDisable: shouldDisable,
            containerAction: containerAction,
            langaugeChanged: langaugeChanged,
            screen: { (_,_) in EmptyView() },
            icon: icon,
            actionBar: actionBar
        )
    }
    init(
        config:LBRootViewConfig,
        viewChanged: ViewDidChange? = nil,
        shouldDisable: ShouldDisable? = nil,
        containerAction:ContainerAction? = nil,
        langaugeChanged: LanguageDidChange? = nil
    ) where Icon == EmptyView, Screen == EmptyView, ActionBar == EmptyView {
        self.init(
            config: config,
            viewChanged: viewChanged,
            shouldDisable: shouldDisable,
            containerAction: containerAction,
            langaugeChanged: langaugeChanged,
            screen: { (_,_) in EmptyView() },
            icon: { _ in EmptyView() },
            actionBar: { (_,_) in EmptyView() }
        )
    }
    init(
        config:LBRootViewConfig,
        viewChanged: ViewDidChange? = nil,
        shouldDisable: ShouldDisable? = nil,
        containerAction:ContainerAction? = nil,
        langaugeChanged: LanguageDidChange? = nil,
        @ViewBuilder screen: @escaping (LBViewIdentity?,LBFullscreenContainerProperties) -> Screen,
        @ViewBuilder icon: @escaping (LBViewIdentity?) -> Icon,
        @ViewBuilder actionBar: @escaping (LBViewIdentity?,LBAactionBarProperties) -> ActionBar
    ) {
        self.config = config
        self.viewChanged = viewChanged
        self.shouldDisable = shouldDisable
        self.containerAction = containerAction
        self.langaugeChanged = langaugeChanged
        self.icon = icon
        self.screen = screen
        self.actionBar = actionBar
        for item in flatten(config.dashboardItems) {
            if item.isAvailable {
                self.nonAvailableItems.removeAll { $0 == item.viewIdentity }
            } else {
                self.nonAvailableItems.append(item.viewIdentity)
            }
        }
    }
}

private struct LBRootViewPreview : View {
    static private let previewItemIdentity: LBViewIdentity = .init("LBRootViewPreview")
    class PreviewService: ObservableObject, LBDashboardItem {
        var viewIdentity: LBViewIdentity = LBRootViewPreview.previewItemIdentity
        var isAvailablePublisher: AnyPublisher<Bool, Never> {
            return $isAvailable.eraseToAnyPublisher()
        }
        @Published var isAvailable: Bool = true
    }
    @StateObject var assistant = createPreviewAssistant()
    @StateObject var dashboardItem = PreviewService()
    @StateObject var returnToHomeScreenService = ReturnToHomeScreenService()
    var config: LBRootViewConfig {
        .init(
            dashboardItems: [[dashboardItem]],
            adminServices: [returnToHomeScreenService]
        )
    }
    @State var val:ReturnToHomeScreen = .never
    var testView: some View {
        VStack {
            Spacer()
            Text("Returns to homescreen interval set to **\(val.title)**")
            Button {
                if val == .never {
                    returnToHomeScreenService.data = .after30seconds
                } else {
                    returnToHomeScreenService.data = .never
                }
            } label: {
                Text("Toggle").padding(20)
            }
            .buttonStyle(LBPrimaryButtonStyle())
            Spacer()
        }
        .onReceive(returnToHomeScreenService.$data) { val in
            self.val = val
        }
    }
    var body: some View {
        LBRootView(config: config)
            .icon { item in
                switch item {
                case LBRootViewPreview.previewItemIdentity: LBEmojiBadgeView(emoji: "🫵", rimColor: .yellow)
                default: EmptyView()
                }
            }
            .screen { item, propertis in
                switch item {
                case LBRootViewPreview.previewItemIdentity: testView
                default: EmptyView()
                }
            }
            .environmentObject(assistant)
    }
}

struct LBRootView_Previews: PreviewProvider {
    static var previews: some View {
       LBRootViewPreview()
            
    }
}
