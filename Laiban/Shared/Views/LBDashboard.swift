//
//  HomeScreen.swift
//  Testing
//
//  Created by Tomas Green on 2022-04-21.
//

import SwiftUI
import Combine

public protocol LBDashboardItem {
    var viewIdentity:LBViewIdentity { get }
    var isAvailablePublisher:AnyPublisher<Bool,Never> { get }
    var isAvailable:Bool { get }
}

public struct LBDashboard<Content,BottomContent,T> : View where Content: View, BottomContent: View, T: Identifiable {
    var items:[[T]]
    var hiddenItems:[T] = []
    var action: ((T) -> Void)? = nil
    var content: ((T) -> Content)? = nil
    var bottomContent: () -> BottomContent
    var columns:CGFloat {
        var col = 0
        for i in items {
            if i.count > col {
                col = i.count
            }
        }
        return col > 5 ? CGFloat(col) : 5
    }
    public init(items:[[T]],hiddenItems:[T] = [], action:((T) -> Void)? = nil, content: ((T) -> Content)? = nil, @ViewBuilder bottomContent: @escaping (() -> BottomContent)) {
        self.items = items
        self.hiddenItems = hiddenItems
        self.action = action
        self.content = content
        self.bottomContent = bottomContent
    }
    func columnBasedSize(_ proxy:GeometryProxy) -> (CGFloat,CGFloat) {
        let blockSize = proxy.size.width/columns
        let padding = blockSize * 0.2
        let size = (proxy.size.width - padding * (columns + 1))/columns
        return (padding,size)
    }
    func rowBasedSize(_ proxy:GeometryProxy) -> (CGFloat,CGFloat) {
        let rows = CGFloat(items.count)
        let blockSize = proxy.size.height/rows
        let padding = blockSize * 0.2
        let size = (proxy.size.height - padding * (rows + 1))/rows
        return (padding,size)
    }
    public var body:some View {
        VStack {
            GeometryReader { proxy in
                let (cPadding,cSize) = columnBasedSize(proxy)
                let (rPadding,rSize) = rowBasedSize(proxy)
                let padding = min(cPadding,rPadding)
                let size = min(cSize,rSize)
                VStack(spacing:padding) {
                    ForEach(0..<items.count, id:\.self) { i in
                        HStack(spacing:padding) {
                            ForEach(items[i]) { item in
                                if hiddenItems.contains(where: { $0.id == item.id }) {
                                    Rectangle()
                                        .frame(width: size, height: size)
                                        .invisible()
                                } else {
                                    Button {
                                        action?(item)
                                    } label: {
                                        content?(item)
                                            .frame(width: size, height: size)
                                    }.buttonStyle(LBScaleEffectButtonStyle())
                                }
                            }
                        }.frame(maxWidth:.infinity)
                    }
                }
                .frame(maxWidth:.infinity)
                .padding(padding)
            }.drawingGroup()
            bottomContent()
        }
    }
    public func onSelectItem(_ action: @escaping (T) -> Void) -> Self {
        Self.init(items: items, hiddenItems: hiddenItems, action: action, content: content, bottomContent: bottomContent)
    }
    public func onRenderIcon(@ViewBuilder content: @escaping (T) -> Content) -> Self {
        Self.init(items: items, hiddenItems: hiddenItems, action: action, content: content, bottomContent: bottomContent)
    }
    public func hide(_ hiddenItems:[T]) -> Self {
        Self.init(items: items, hiddenItems: hiddenItems, action: action, content: content, bottomContent: bottomContent)
    }
}
public extension LBDashboard where Content == EmptyView {
    init(items:[[T]], @ViewBuilder bottomContent:@escaping () -> BottomContent) {
        self.init(items:items, content: { _ in EmptyView() }, bottomContent: bottomContent )
    }
}
private enum TestScreen:String,CaseIterable,Equatable,Hashable,Identifiable,RawRepresentable {
    var id:String {
        return self.rawValue
    }
    case food
    case calendar
    case trashmonsters
    case a
    case b
}
struct LBDashboard_Previews: PreviewProvider {
    static var previews: some View {
        LBFullscreenContainer { p in
            LBDashboard(items: [TestScreen.allCases]) {
                Text("hej \n hej2 askd \n hej2")
                    .frame(maxWidth:.infinity)
                    .padding(p.spacing[.m])
                    .primaryContainerBackground()
                    .font(p.font, ofSize: .n)
            }
            .onRenderIcon { i in
                switch i {
                case .calendar:      LBEmojiBadgeView(emoji: "🗓", rimColor: .red)
                case .food:          LBEmojiBadgeView(emoji: "🍽", rimColor: .green)
                case .trashmonsters: LBEmojiBadgeView(emoji: "😸", rimColor: .blue)
                case .a:             LBEmojiBadgeView(emoji: "🍽", rimColor: .green)
                case .b:             LBEmojiBadgeView(emoji: "😸", rimColor: .blue)
                }
            }
            .onSelectItem { i in
                print(i.id)
            }
        }
        .character(position: .right)
        .actionBarButtons([.languages,.admin])
    }
}
