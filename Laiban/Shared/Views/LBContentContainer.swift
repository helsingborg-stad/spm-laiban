//
//  FullscreenContainer.swift
//  Laiban
//
//  Created by Tomas Green on 2021-06-16.
//

import SwiftUI

public enum LBContentContainerOverlay : Equatable {
    case laibanFace(LaibanExpression)
    case emoji(String,Color)
    case image(Image)
}
public enum LBContentContainerOverlayScale {
    case small
    case medium
    public var size:CGFloat {
        switch self {
        case .small: return 130
        case .medium: return 200
        }
    }
}
public enum LBContentContainerOverlayRatio {
    case dynamic
    case fixed(CGFloat)
}
struct LBContentContainer<Content: View>: View {
    var scrollable:Bool = false
    var overlay:LBContentContainerOverlay = .laibanFace(.wink)
    var overlayScale:LBContentContainerOverlayScale = .medium
    var overlayRatio:LBContentContainerOverlayRatio = .dynamic
    var background:LBBackground? = .primary
    var overlayAction: (() -> Void)? = nil
    let content: () -> Content
    func emojiOverlay(emoji:String, rimColor:Color) ->  some View {
        LBEmojiBadgeView(emoji: emoji, rimColor: rimColor)
    }
    func imageOverlay(image:Image) -> some View {
        image.resizable().aspectRatio(contentMode: .fit)
    }
    func laibanFaceOverlay(ratio:CGFloat, height:CGFloat) -> some View {
        VStack(spacing: overlayScale.size/10 * ratio) {
            LaibanFaceView(expression: .wink,showImage: true)
            LaibanBodyDots(ellipsified: false).frame(height: height * 0.05)
        }
    }
    func topOverlay(ratio:CGFloat, height:CGFloat) -> some View {
        topOverlaySymbol(ratio: ratio, height: height)
            .frame(height: height)
            .frame(maxWidth: .infinity,maxHeight: .infinity, alignment: .top)
            .offset(y: height / -2)
            .animation(.spring(), value: overlay)
            .transition(.scale)
            .onTapGesture {
                overlayAction?()
            }
    }
    @ViewBuilder func topOverlaySymbol(ratio:CGFloat, height:CGFloat) -> some View {
        if case .emoji(let emoji,let color) = overlay {
            emojiOverlay(emoji: emoji, rimColor: color)
        } else if case .image(let image) = overlay {
            imageOverlay(image: image)
        } else {
            laibanFaceOverlay(ratio: ratio, height: height)
        }
    }
    func getRatio(_ proxy:GeometryProxy) -> CGFloat {
        if case let .fixed(s) = overlayRatio {
            return s
        }
        let size = proxy.size
        return size.height > size.width ? size.width/size.height : size.height/size.width
    }
    var body: some View {
        GeometryReader { proxy in
            let ratio = getRatio(proxy)
            let overlayHeight = ratio * overlayScale.size
            if scrollable {
                ScrollView {
                    content()
                        .frame(minWidth:overlayHeight * 2, minHeight: overlayHeight)
                        .padding(.top, overlayHeight/2)
                }
                .background(background)
                .overlay(topOverlay(ratio: ratio, height: overlayHeight))
                .padding(.top, overlayHeight/2)
            } else {
                content()
                    .padding(.top, overlayHeight/2)
                    .background(background)
                    .overlay(topOverlay(ratio: ratio, height: overlayHeight))
                    .padding(.top, overlayHeight/2)
            }
        }
    }
    func contentOverlay(_ overlay:LBContentContainerOverlay = .laibanFace(.wink)) -> Self {
        Self(
            scrollable: scrollable,
            overlay: overlay,
            overlayScale:overlayScale,
            overlayRatio: overlayRatio,
            background:background,
            overlayAction: overlayAction,
            content: content
        )
    }
}
public extension View {
    func wrap(
        scrollable:Bool = false,
        overlay:LBContentContainerOverlay = .laibanFace(.wink),
        overlayScale:LBContentContainerOverlayScale = .medium,
        overlayRatio:LBContentContainerOverlayRatio = .dynamic,
        background:LBBackground? = .primary,
        onTapOverlayAction:(() -> Void)? = nil
    ) -> some View {
        LBContentContainer(scrollable: scrollable, overlay: overlay, overlayScale:overlayScale, overlayRatio: overlayRatio, background:background, overlayAction: onTapOverlayAction) {
            self
        }
    }
}
struct LBContentContainer_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LBFullscreenContainer { props in
                VStack {
                    Text("Hejhejhslkmsd \nhejhej")
                        .fixedSize()
                        .padding(props.spacing.ofAmount(.l))
                        .font(props.font, ofSize: .xxl)
                        .frame(maxWidth:.infinity,maxHeight: .infinity,alignment:.leading)
                        .wrap(overlay: .emoji("👻", .blue), overlayScale: .small, overlayRatio: .fixed(props.contentRatio), background:.secondary)
                        
                }
                .padding(props.spacing.ofAmount(.m))
                .frame(maxWidth:.infinity)
                .wrap(scrollable: false, overlay: .laibanFace(.wink), background: .primary)
            }
            LBFullscreenContainer { props in
                Text("hej")
                    .frame(maxWidth:.infinity,maxHeight: .infinity)
                    .wrap(scrollable: true, overlay: .emoji("👻", .blue))
                    
                    .padding(props.spacing.ofAmount(.m))
            }
            LBFullscreenContainer { props in
                Text("hej")
                    .frame(maxWidth:.infinity,maxHeight: .infinity)
                    .padding(props.spacing.ofAmount(.m))
                    .wrap(scrollable: false, overlay: .emoji("👻", .blue))
            }
            .previewDevice("iPhone 13 Pro Max")
        }
    }
}
