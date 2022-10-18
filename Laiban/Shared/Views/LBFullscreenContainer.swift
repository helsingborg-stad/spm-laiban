//
//  LaibanContainer.swift
//  Testing
//
//  Created by Tomas Green on 2022-04-13.
//

import SwiftUI
import Combine
import Analytics

public struct LBSpacing {
    public enum Amount {
        case xs
        case s
        case m
        case l
        case xl
        public var scaleFactor:CGFloat {
            switch self {
            case .xs: return 0.01
            case .s: return 0.02
            case .m: return 0.03
            case .l: return 0.04
            case .xl: return 0.06
            }
        }
    }
    public let basedOnSize:CGSize
    public func ofAmount(_ amount:Amount = .m) -> CGFloat {
        return min(basedOnSize.height,basedOnSize.width) * amount.scaleFactor
    }
    public subscript(amount: Amount) -> CGFloat {
        ofAmount(amount)
    }
    
}
public struct LBScaleEffectButtonStyle: ButtonStyle {
    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.8 : 1.0)
            .opacity(configuration.isPressed ? 0.5 : 1.0)
            .animation(.spring(), value: configuration.isPressed)
    }
}
public enum LBLayout {
    case landscape
    case portrait
}
public struct LBAactionBarProperties {
    public enum Layout: Equatable {
        case center
        case right
    }
    public let size:CGFloat
    public let spacing:LBSpacing
    public let containerLayout:LBLayout
    public let layout:Layout
    public let font:LBFont
    public let visibleButtons:[LBFullscreenContainerButton]
    public let trigger:((LBFullscreenContainerAction) -> Void)
}
public struct LBFullscreenContainerProperties {
    public let windowSize:CGSize
    public let contentSize:CGSize
    public let safeAreaInsets:EdgeInsets
    public let spacing:LBSpacing
    public let layout:LBLayout
    public let font:LBFont
    public let verticalSizeClass:UserInterfaceSizeClass?
    public let horizontalSizeClass:UserInterfaceSizeClass?
    public let actionBarNotifier:AnyPublisher<LBFullscreenContainerAction,Never>
    public static var `default`:Self = .init(
        windowSize: UIScreen.main.bounds.size,
        contentSize: UIScreen.main.bounds.size,
        safeAreaInsets: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
        spacing: LBSpacing(basedOnSize: UIScreen.main.bounds.size),
        layout: .portrait,
        font: LBFont.init(container: UIScreen.main.bounds.size),
        verticalSizeClass: nil,
        horizontalSizeClass: nil,
        actionBarNotifier: PassthroughSubject<LBFullscreenContainerAction,Never>().eraseToAnyPublisher()
    )
    public var windowRatio:CGFloat {
        let size = windowSize
        return size.height > size.width ? size.width/size.height : size.height/size.width
    }
    public var contentRatio:CGFloat {
        let size = contentSize
        return size.height > size.width ? size.width/size.height : size.height/size.width
    }
}
public enum LBFullscreenContainerButton : CaseIterable {
    case home
    case back
    case languages
    case admin
    case character
}
public struct LBCharacterConfig: Equatable {
    public static let `default` = LBCharacterConfig()
    public enum Position: Equatable {
        case center
        case right
    }
    public var hidden:Bool
    public var position:Position
    public var image:Image?
    public init(hidden:Bool = false, position:Position = .right, image:Image? = nil) {
        self.hidden = hidden
        self.position = position
        self.image = image
    }
}

public enum LBFullscreenContainerAction : Equatable {
    case back
    case home
    case languages
    case admin
    case character
    case custom(String)
}
struct LBLayoutProperties {
    var ratio:CGFloat
    var iconSize:CGFloat
    var characterSize:CGFloat
    var padding:CGFloat
    var topMargin:CGFloat
    var bottomMargin:CGFloat
    var trailingMargin:CGFloat
    var leadingMargin:CGFloat
    var characterYOffset:CGFloat
    var characterXOffset:CGFloat
    var contentBottomInset:CGFloat
    var groundHeight:CGFloat
    var backdropHeight: CGFloat
    var actionBarSize:CGSize
    var contentSize:CGSize
    var font:LBFont
    var layout:LBLayout
    var spacing:LBSpacing
    var proxy:GeometryProxy
    var contentInset:EdgeInsets
    var actionBarInset:EdgeInsets
    
    init(layout:LBLayout, proxy:GeometryProxy, characterConfig:LBCharacterConfig, vClass:UserInterfaceSizeClass?) {
        self.proxy = proxy
        self.layout = layout
        self.spacing             = LBSpacing(basedOnSize: proxy.size)
        self.font                = LBFont(container: proxy.size)
        if layout == .portrait {
            self.ratio               = proxy.size.width/proxy.size.height
            self.iconSize            = ratio * proxy.size.height * 0.13
            self.characterSize       = iconSize * 2.2
            self.padding             = spacing.ofAmount(.m)
            self.topMargin           = max(padding - proxy.safeAreaInsets.top, 0)
            self.bottomMargin        = max(padding - proxy.safeAreaInsets.bottom, 0)
            self.trailingMargin      = 0
            self.leadingMargin       = 0
            self.characterYOffset    = characterSize * -0.1
            self.characterXOffset    = characterConfig.position == .right ? proxy.size.width/2 - characterSize/2 : 0
            self.contentBottomInset  = characterConfig.hidden ? iconSize * 0.1 : characterSize * 0.3 + characterYOffset
            self.actionBarSize       = CGSize(width: proxy.size.width, height: iconSize + bottomMargin + padding)
            self.groundHeight        = actionBarSize.height
            self.contentSize         = CGSize(width: proxy.size.width, height: proxy.size.height - actionBarSize.height)
            self.contentInset        = EdgeInsets(top: topMargin,leading: padding, bottom: contentBottomInset, trailing: padding)
            self.actionBarInset      = EdgeInsets(top: padding,leading: padding,bottom: bottomMargin,trailing: padding)
            
        } else {
            self.ratio               = proxy.size.height/proxy.size.width
            self.iconSize            = vClass == .compact ? proxy.size.width * 0.07 : ratio * proxy.size.height * 0.18
            self.characterSize       = iconSize * 1.7
            self.padding             = spacing.ofAmount(.m)
            self.bottomMargin        = max(padding - proxy.safeAreaInsets.bottom, 0)
            self.topMargin           = max(padding - proxy.safeAreaInsets.top, 0)
            self.trailingMargin      = max(padding - proxy.safeAreaInsets.trailing, 0)
            self.leadingMargin       = max(padding - proxy.safeAreaInsets.leading, 0)
            self.contentBottomInset  = 0
            self.characterXOffset    = iconSize * -0.2
            self.characterYOffset    = iconSize * -0.1
            self.actionBarSize       = CGSize(width: iconSize + trailingMargin, height: proxy.size.height)
            self.groundHeight        = characterSize * 0.7 - proxy.safeAreaInsets.bottom
            self.contentSize         = CGSize( width: proxy.size.width - actionBarSize.width,height: proxy.size.height)
            self.contentInset        = EdgeInsets(top: topMargin,leading: leadingMargin,bottom: bottomMargin, trailing: padding)
            self.actionBarInset      = EdgeInsets(top: topMargin,leading: padding,bottom: bottomMargin,trailing: trailingMargin)
        }
        self.backdropHeight      = proxy.size.height + proxy.safeAreaInsets.top - groundHeight
    }
}
func flag(for locale:Locale) -> String {
    guard let region = locale.regionCode else {
        return ["🌏","🌎","🌍"].randomElement()!
    }
    if region.range(of: #"[0-9]"#,options: .regularExpression) != nil {
        return ["🌏","🌎","🌍"].randomElement()!
    }
    let base : UInt32 = 127397
    var s = ""
    for v in region.unicodeScalars {
        s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
    }
    return String(s)
}

public struct LBFullscreenContainer<Content:View,ActionBar:View>: View {
    @State var showAdminScreen:Bool = false
    @State var showAdminSheet:Bool = false
    @Environment(\.horizontalSizeClass) var hClass
    @Environment(\.verticalSizeClass) var vClass
    @Environment(\.locale) var locale
    let actionNotifier = PassthroughSubject<LBFullscreenContainerAction,Never>()
    var backdrop:Image = Image("Wall", bundle:.module)
    var ground = LinearGradient(gradient: Gradient(colors: [Color("FloorColor2", bundle:.module), Color("FloorColor1", bundle:.module)]), startPoint: .top, endPoint: .bottom)
    var containerAction:((LBFullscreenContainerAction) -> Void)? = nil
    var actionBarButtons: [LBFullscreenContainerButton] = [.home,.languages]
    var characterConfig: LBCharacterConfig = .default
    var adminServices:[LBAdminService] = []
    let content: (LBFullscreenContainerProperties) -> Content
    let actionBar: (LBAactionBarProperties) -> ActionBar
    
    var homeButton: some View {
        Button(action: {
            containerActionTrigger(.home)
        }) {
            LBActionBarCircleImageView(image: Image("ButtonIconHome", bundle:.module), color: Color("ButtonIconHomeColor", bundle:.module))
        }
        .id("ActionBarHomeButton")
        .transition(.scale)
    }
    var backButton: some View {
        Button(action: {
            containerActionTrigger(.back)
        }) {
            LBActionBarCircleImageView(image: Image("ButtonIconBack", bundle:.module), color: Color("ButtonIconBackColor", bundle:.module))
        }
        .id("ActionBarBackButton")
        .transition(.scale)
    }
    var languageButton: some View {
        Button(action: {
            containerActionTrigger(.languages)
        }) {
            LBActionBarCircleEmojiView(emoji: flag(for: locale), color: Color("ButtonIconLanguageColor", bundle:.module))
        }
        .id("ActionLanguageButton")
        .transition(.scale)
    }
    var adminButton: some View {
        LBActionBarCircleAdminView().hold(minimumDuration: 1.5) {
            containerActionTrigger(.admin)
        }
        .id("ActionAdminButton")
        .transition(.scale)
    }
    func adminScreen(_ properties:LBFullscreenContainerProperties) -> some View {
        Rectangle()
            .fill(.clear)
            .font(.system(size: 100))
            .parentalGate(properties: properties)
            .onStatusChanged { status in
                if status == .cancelled || status == .failed {
                    self.showAdminScreen = false
                } else {
                    self.showAdminSheet = true
                    AnalyticsService.shared.logPageView("AdminView")
                }
            }
            .transition(.opacity.combined(with: .scale))
            .animation(.spring(), value: showAdminScreen)
    }
    var adminSheet: some View {
        LBAdminView(services: adminServices).onDisappear {
            self.showAdminScreen = false
            self.showAdminSheet = false
        }
    }
    @ViewBuilder func setupContent(_ properties:LBFullscreenContainerProperties) -> some View {
        let content = content(properties).environment(\.fullscreenContainerProperties, properties)
        if showAdminScreen {
            adminScreen(properties)
        } else {
            content
        }
    }
    func containerActionTrigger(_ action:LBFullscreenContainerAction) {
        if action == .admin && !adminServices.isEmpty {
            showAdminScreen = true
            return
        } else if action == .back && showAdminScreen && !adminServices.isEmpty{
            showAdminScreen = false
            return
        }
        containerAction?(action)
        actionNotifier.send(action)
    }
    func backdrop(_ p:LBLayoutProperties) -> some View {
        VStack(spacing:0) {
            backdrop.resizable()
                .aspectRatio(contentMode: ContentMode.fill)
                .frame(height: p.backdropHeight, alignment: .bottom)
            ground
        }
        .frame(maxWidth:.infinity,maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
    }
    private func actionBarPortrait(_ p:LBLayoutProperties) -> some View {
        HStack(spacing:p.spacing[.m]) {
            let actionBarProperties = LBAactionBarProperties(
                size: p.iconSize,
                spacing: p.spacing,
                containerLayout: .landscape,
                layout: characterConfig.position == .right ? .right : .center,
                font: p.font,
                visibleButtons: actionBarButtons,
                trigger: containerActionTrigger
            )
            if actionBarButtons.isEmpty {
                actionBar(actionBarProperties)
                    .transition(.scale)
            } else {
                if actionBarButtons.contains(.languages) {
                    languageButton.frame(width:p.iconSize,height: p.iconSize)
                }
                if actionBarButtons.contains(.admin) && showAdminScreen == false {
                    adminButton.frame(width:p.iconSize * 0.7,height: p.iconSize * 0.7)
                        .frame(maxHeight: .infinity,alignment:.bottom)
                }
                if characterConfig.position != .right {
                    if actionBar is ((LBAactionBarProperties) -> EmptyView) {
                        Spacer()
                    } else {
                        actionBar(actionBarProperties)
                            .transition(.scale)
                    }
                } else {
                    actionBar(actionBarProperties)
                        .transition(.scale)
                }
                if actionBarButtons.contains(.back) || showAdminScreen {
                    backButton.frame(width:p.iconSize, height: p.iconSize)
                }
                if actionBarButtons.contains(.home) {
                    homeButton.frame(width:p.iconSize, height: p.iconSize)
                }
                if characterConfig.position == .right {
                    Spacer()
                }
            }
        }
        .padding(p.actionBarInset)
        .frame(width: p.actionBarSize.width, height: p.actionBarSize.height)
        .background(
            characterPortrait(size: p.characterSize, xOffset: p.characterXOffset, yOffset: p.characterYOffset)
        )
        .buttonStyle(LBScaleEffectButtonStyle())
        .animation(.spring(), value: actionBarButtons)
        .animation(.spring(), value: characterConfig)
        
    }
    private func actionBarLandscape(_ p: LBLayoutProperties) -> some View {
        VStack(spacing:p.spacing[.m]) {
            let actionBarProperties = LBAactionBarProperties(
                size: p.iconSize,
                spacing: p.spacing,
                containerLayout: .landscape,
                layout: .center,
                font:p.font,
                visibleButtons: actionBarButtons,
                trigger: containerActionTrigger
            )
            if actionBarButtons.isEmpty {
                actionBar(actionBarProperties)
                    .transition(.scale)
            } else {
                if actionBarButtons.contains(.languages) {
                    languageButton.frame(width:p.iconSize,height: p.iconSize)
                }
                if actionBarButtons.contains(.admin) {
                    adminButton.frame(width:p.iconSize * 0.7,height: p.iconSize * 0.7)
                }
                if actionBarButtons.contains(.back) {
                    backButton.frame(width:p.iconSize, height: p.iconSize)
                }
                if actionBarButtons.contains(.home) {
                    homeButton.frame(width:p.iconSize, height: p.iconSize)
                }
                if actionBar is ((LBAactionBarProperties) -> EmptyView) {
                    Spacer()
                } else {
                    actionBar(actionBarProperties)
                }
            }
        }
        .modifyIf(!characterConfig.hidden, content: { content in
            content.background(characterLandscape(size: p.characterSize, xOffset: p.characterXOffset, yOffset: p.characterYOffset))
        })
        .padding(p.actionBarInset)
        .frame(width: p.actionBarSize.width, height: p.actionBarSize.height)
        .buttonStyle(LBScaleEffectButtonStyle())
        .animation(.spring(), value: actionBarButtons)
        .animation(.spring(), value: characterConfig)
    }
    private func characterPortrait(size:CGFloat, xOffset:CGFloat, yOffset:CGFloat) -> some View {
        LBCharacterScene(showCharacter: !characterConfig.hidden, image: characterConfig.image)
            .frame(height: size)
            .frame(maxWidth:.infinity,maxHeight: .infinity,alignment: .bottom)
            .offset(x: xOffset, y: yOffset)
            .onTapGesture {
                containerActionTrigger(.character)
            }
            .id("CharacterView")
            .animation(.spring(), value: characterConfig)
            .transition(.move(edge: .trailing))
    }
    private func characterLandscape(size:CGFloat, xOffset:CGFloat, yOffset:CGFloat) -> some View {
        Group {
            if characterConfig.image != nil {
                characterConfig.image?
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width:size * 2,height: size) // * 2 width fixes animation glitches
                    .offset(x:xOffset,y:yOffset)
                    .frame(maxWidth:.infinity,maxHeight: .infinity,alignment: .bottom)
                    .onTapGesture {
                        containerActionTrigger(.character)
                    }
                    .animation(.spring(), value: characterConfig)
                    .transition(.move(edge: .trailing))
            } else {
                LaibanBodyWithShadow(expression: .wink)
                    .frame(width:size * 2,height: size) // * 2 width fixes animation glitches
                    .offset(x:xOffset,y:yOffset)
                    .frame(maxWidth:.infinity,maxHeight: .infinity,alignment: .bottom)
                    .onTapGesture {
                        containerActionTrigger(.character)
                    }
                    .animation(.spring(), value: characterConfig)
                    .transition(.move(edge: .trailing))
            }
        }
        .id("CharacterView")
        .animation(.spring(), value: characterConfig)
        .transition(.move(edge: .trailing))
    }
    private var root: some View {
        GeometryReader { proxy in
            let layout:LBLayout = proxy.size.width > proxy.size.height ? .landscape : .portrait
            let p = LBLayoutProperties(layout: layout, proxy: proxy, characterConfig: characterConfig, vClass: vClass)
            ZStack(alignment: p.layout == .portrait ? .top : .leading) {
                GeometryReader { contentProxy in
                    let props = LBFullscreenContainerProperties(
                        windowSize: p.proxy.size,
                        contentSize: contentProxy.size,
                        safeAreaInsets: p.proxy.safeAreaInsets,
                        spacing: p.spacing,
                        layout: p.layout,
                        font: p.font,
                        verticalSizeClass: vClass,
                        horizontalSizeClass: hClass,
                        actionBarNotifier: actionNotifier.eraseToAnyPublisher()
                    )
                    setupContent(props)
                        .frame(maxWidth:contentProxy.size.width,maxHeight: contentProxy.size.height,alignment: p.layout == .portrait ? .top : .leading)
                }
                .padding(p.contentInset)
                .frame(width: p.contentSize.width, height: p.contentSize.height)
                if p.layout == .portrait {
                    actionBarPortrait(p)
                        .frame(maxWidth:.infinity,maxHeight: .infinity,alignment: .bottom)
                } else {
                    actionBarLandscape(p)
                        .frame(maxWidth:.infinity,maxHeight: .infinity,alignment: .trailing)
                }
            }
            .frame(width: p.proxy.size.width, height: p.proxy.size.height)
            .animation(.spring(), value: showAdminScreen)
            .background(backdrop(p))
        }
        .frame(maxWidth:.infinity, maxHeight: .infinity)
    }
    public var body: some View {
        if #available(iOS 14.0, *) {
            root.fullScreenCover(isPresented: $showAdminSheet) {
                adminSheet
            }
        } else {
            root.sheet(isPresented: $showAdminSheet) {
                adminSheet
            }
        }
    }
}
public struct LBFullscreenContainerPropertiesKey: EnvironmentKey {
    public static let defaultValue:LBFullscreenContainerProperties = .default
}

public extension EnvironmentValues {
    var fullscreenContainerProperties: LBFullscreenContainerProperties {
        get { self[LBFullscreenContainerPropertiesKey.self] }
        set { self[LBFullscreenContainerPropertiesKey.self] = newValue }
    }
}
public extension View {
    func fullscreenContainerProperties(_ value: LBFullscreenContainerProperties) -> some View {
        environment(\.fullscreenContainerProperties, value)
    }
}
@available(iOS 15.0, *) struct LaibanContainer_Previews: PreviewProvider {
    struct FontTest : View {
        var props:LBFullscreenContainerProperties
        var text:String
        var body: some View {
            VStack {
                ForEach(LBFont.Size.allCases, id: \.self) { s in
                    Text(s.name).font(props.font, ofSize: s)
                }
            }
            .frame(maxWidth:.infinity,maxHeight: .infinity)
            .primaryContainerBackground()
        }
    }
    @State static var text:String = "Hej"
    @State static var status:LBParentalGateStatus = .undetermined
    static let config = LBCharacterConfig(position: .center, image: Image("Monster-Kompostina"))
    
    static var previews: some View {
        Group {
            LBFullscreenContainer { props in
                FontTest(props: props, text: text)
            }
            .actionBar { props in
                Group {
                    Text("hej")
                        .frame(maxWidth:.infinity,maxHeight: .infinity)
                        .background(LBCapsuleBackground())
                    
                }
            }
            .actionBarButtons([.home,.languages])
            .character(config:config)
            .previewDevice("iPad Pro (12.9-inch) (5th generation)")
            .previewInterfaceOrientation(.portrait)
            
            LBFullscreenContainer { props in
                FontTest(props: props, text: text)
            }
            .character(config:config)
            .actionBarButtons([.home,.languages,.back,.admin])
            .previewDevice("iPhone 13 Pro Max")
            .previewInterfaceOrientation(.portrait)
            LBFullscreenContainer { props in
                FontTest(props: props, text: text)
            }
            .character(config:config)
            .actionBarButtons([.home,.languages,.back,.admin])
            .previewDevice("iPad (9th generation)")
            .previewInterfaceOrientation(.portrait)
            
            LBFullscreenContainer { props in
                FontTest(props: props, text: text)
            }
            .actionBar { props in
                Text("hej").frame(maxWidth:.infinity,maxHeight: .infinity).background(LBCapsuleBackground())
            }
            .character(config:config)
            .actionBarButtons([.home,.languages,.back,.admin])
            .previewDevice("iPad Pro (12.9-inch) (5th generation)")
            .previewInterfaceOrientation(.landscapeLeft)
            // Previews does not support safeareas in landscape mode
            
            LBFullscreenContainer { props in
                FontTest(props: props, text: text)
            }
            .character(config:config)
            .actionBarButtons([.home,.languages,.back,.admin])
            .previewDevice("iPhone 13 Pro Max")
            .previewInterfaceOrientation(.landscapeRight)
            // Previews does not support safeareas in landscape mode
 
            LBFullscreenContainer { props in
                FontTest(props: props, text: text)
            }
            .character(config:config)
            .actionBarButtons([.home,.languages,.back,.admin])
            .previewDevice("iPhone 13 Pro Max")
            .previewInterfaceOrientation(.landscapeLeft)
            // Previews does not support safeareas in landscape mode
            
            LBFullscreenContainer { props in
                FontTest(props: props, text: text)
            }
            .character(config:config)
            .actionBarButtons([.home,.languages,.back,.admin])
            .previewDevice("iPad (9th generation)")
            .previewInterfaceOrientation(.landscapeLeft)
            // Previews does not support safeareas in landscape mode
        }
    }
}
