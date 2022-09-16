//
//  SwiftUIView.swift
//  
//
//  Created by Tomas Green on 2022-06-10.
//

import SwiftUI

private struct LBScrollViewOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) { }
}
public struct LBScrollView<Content: View>: View {
    let axes: Axis.Set
    let showsIndicator: Bool
    let offsetChanged: (CGPoint) -> Void
    let content: () -> Content
    public init(
        axes: Axis.Set = .vertical,
        showsIndicator: Bool = true,
        offsetChanged: @escaping (CGPoint) -> Void = { _ in },
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.axes = axes
        self.showsIndicator = showsIndicator
        self.offsetChanged = offsetChanged
        self.content = content
    }
    public func onOffsetChanged(_ offsetChanged: @escaping (CGPoint) -> Void) -> Self {
        Self.init(
            axes: axes,
            showsIndicator: showsIndicator,
            offsetChanged: offsetChanged,
            content: content
        )
    }
    public var body: some View {
        ScrollView(axes, showsIndicators: showsIndicator) {
            GeometryReader { proxy in
                Color.clear.preference(
                    key: LBScrollViewOffsetPreferenceKey.self,
                    value: proxy.frame(
                        in: .named("ScrollViewOrigin")
                    ).origin
                )
            }
            .frame(width: 0, height: 0)
            content()
        }
        .coordinateSpace(name: "ScrollViewOrigin")
        .onPreferenceChange(LBScrollViewOffsetPreferenceKey.self, perform: offsetChanged)
    }
}

struct LBScrollView_Previews: PreviewProvider {
    static var previews: some View {
        LBScrollView {
            
        }.onOffsetChanged { point in
            print(point)
        }
    }
}
