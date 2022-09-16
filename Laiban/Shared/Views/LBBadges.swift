//
//  LBBadges.swift
//  Testing
//
//  Created by Tomas Green on 2022-04-20.
//

import SwiftUI

public struct LBMulticolorCircle: View {

    struct Slice: Identifiable {
        let id: UUID = UUID()
        var color:Color
        var startAngle: Angle! = .degrees(0)
        var endAngle: Angle! = .degrees(0)
    }
    static func convert(colors:[Color]) -> [Slice]{
        let percentage:Double = 1/Double(colors.count)
        var slizes = [Slice]()
        var prev:Double = -90
        for color in colors {
            let start = Angle(degrees: prev)
            let end = Angle(degrees: prev + 360 * percentage)
            slizes.append(Slice(color: color, startAngle: start, endAngle: end))
            prev = end.degrees
        }
        return slizes
    }
    var slices:[Slice]
    public init(_ colors:[Color]) {
        self.slices = Self.convert(colors: colors)
    }
    func path(for item:Slice, of diameter:CGFloat) -> Path {
        let radius = diameter / 2
        let centerX = radius
        let centerY = radius
        
        var path = Path()
        path.move(to: CGPoint(x: centerX, y: centerY))
        path.addArc(center: CGPoint(x: centerX, y: centerY),
                    radius: radius,
                    startAngle: item.startAngle,
                    endAngle: item.endAngle,
                    clockwise: false)
        path.closeSubpath()
        return path
    }
    public var body: some View {
        GeometryReader { geometry in
            ForEach(slices) { item in
                path(for: item, of: geometry.size.width)
                    .fill(item.color)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }.aspectRatio(1, contentMode: .fit).clipShape(Circle())
    }
}

public enum LBBadgeRimThickness {
    case thin
    case normal
    case thick
    public var percentage:CGFloat {
        switch self {
        case .thin: return 0.03
        case .normal: return 0.05
        case .thick: return 0.08
        }
    }
}
public struct LBBadgeBackground: View {
    public var gradient:Gradient
    public init(from:Color, to:Color) {
        gradient = Gradient(colors: [ from, to])
    }
    public init(_ color:Color) {
        gradient = Gradient(colors: [ color.opacity(0.6), color])
    }
    public init(gradient:Gradient) {
        self.gradient = gradient
    }
    public init() {
        gradient = Gradient(colors: [
            Color("BadgeBackgroundGradient1", bundle:.module),
            Color("BadgeBackgroundGradient2", bundle:.module)
        ])
    }
    public var body: some View {
        LinearGradient(gradient: gradient, startPoint: .top, endPoint: .bottom).background(Color.white).clipShape(Circle())
    }
}
public struct LBBadgeView<Content:View>: View {
    public typealias Diameter = CGFloat
    @Environment(\.isEnabled) var isEnabled
    var rimColor:[Color]
    var backgroundColor:Color?
    var thickness:LBBadgeRimThickness
    var content: (Diameter) -> Content
    public init(rimColor:[Color], thickness:LBBadgeRimThickness = .normal, backgroundColor:Color? = nil, @ViewBuilder content: @escaping (Diameter) -> Content) {
        self.rimColor = rimColor
        self.thickness = thickness
        self.backgroundColor = backgroundColor
        self.content = content
    }
    public init(rimColor:Color, thickness:LBBadgeRimThickness = .normal, backgroundColor:Color? = nil, @ViewBuilder content: @escaping (Diameter) -> Content) {
        self.rimColor = [rimColor]
        self.thickness = thickness
        self.backgroundColor = backgroundColor
        self.content = content
    }
    @ViewBuilder var rim: some View {
        if rimColor.count == 1 {
            LBBadgeBackground(rimColor.first!)
        } else {
            LBMulticolorCircle(rimColor)
        }
    }
    @ViewBuilder func background(shadowRadius:CGFloat) -> some View {
        if backgroundColor != nil {
            backgroundColor!.clipShape(Circle()).shadow(color: Color.black.opacity(0.2), radius: isEnabled ? shadowRadius : 0, x: 0, y: 0)
        } else {
            LBBadgeBackground().shadow(color: Color.black.opacity(0.2), radius: isEnabled ? shadowRadius : 0, x: 0, y: 0)
        }
    }
    public var body: some View {
        GeometryReader { proxy in
            let shadowRadius = proxy.size.width * 0.03
            content(proxy.size.width)
                .frame(maxWidth:.infinity,maxHeight: .infinity)
                .clipShape(Circle())
                .background(background(shadowRadius: shadowRadius/2))
                .padding(proxy.size.width * thickness.percentage)
                .background(rim.shadow(color: Color.black.opacity(0.2), radius: isEnabled ? shadowRadius : 0, x: 0, y: 0))
                .frame(width: proxy.size.width, height: proxy.size.width)
        }
        .aspectRatio(1, contentMode: .fit)
        .saturation(isEnabled ? 1 : 0.3)
    }
}
public struct LBEmojiBadgeView: View {
    @Environment(\.isEnabled) var isEnabled
    var emoji:String
    var rimColor:Color
    var thickness:LBBadgeRimThickness
    public init(emoji:String,rimColor:Color,thickness:LBBadgeRimThickness = .normal) {
        self.emoji = emoji
        self.rimColor = rimColor
        self.thickness = thickness
    }
    public var body: some View {
        LBBadgeView(rimColor: rimColor, thickness: thickness) { diameter in
            Text(self.emoji).font(Font.system(size: diameter * 0.5))
        }
    }
}
public struct LBImageBadgeView: View {
    public enum ImageScale {
        case small
        case medium
        case large
        case custom(CGFloat)
        public var value:CGFloat {
            switch self {
            case .small: return 0.5
            case .medium: return 0.85
            case .large: return 1
            case .custom(let v): return v
            }
        }
    }
    var image:Image
    var rimColor:Color
    var thickness:LBBadgeRimThickness
    var imageScaleFactor:ImageScale
    var renderingMode:Image.TemplateRenderingMode = .original
    public init(image:Image,renderingMode:Image.TemplateRenderingMode = .original, imageScaleFactor:ImageScale = .small, rimColor:Color,thickness:LBBadgeRimThickness = .normal) {
        self.rimColor = rimColor
        self.thickness = thickness
        self.image = image
        self.renderingMode = renderingMode
        self.imageScaleFactor = imageScaleFactor
    }
    public var body: some View {
        LBBadgeView(rimColor: rimColor, thickness: thickness) { diameter in
            image
                .renderingMode(renderingMode)
                .resizable()
                .frame(width: diameter * imageScaleFactor.value, height: diameter * imageScaleFactor.value)
        }
    }
}
public struct LBEmojisBadgeView: View {
    public enum EmojiSize {
        case normal
        case large
        case extraLarge
        var center:CGFloat {
            switch self {
            case .normal: return 0.2
            case .large: return 0.3
            case .extraLarge: return 0.4
            }
        }
        var outer:CGFloat {
            switch self {
            case .normal: return 0.14
            case .large: return 0.12
            case .extraLarge: return 0.10
            }
        }
        var offset:CGFloat {
            switch self {
            case .normal: return 0.3
            case .large: return 0.32
            case .extraLarge: return 0.34
            }
        }
    }
    var centerEmoji:String
    var surroundingEmojis:[String]
    var emojiSize:EmojiSize
    var rimColor:Color
    var thickness:LBBadgeRimThickness
    func index(of emoji:String) -> Double {
        return Double(surroundingEmojis.firstIndex(of: emoji)!)
    }
    func angle(for emoji:String) -> Double {
        return 360/Double(surroundingEmojis.count) * self.index(of: emoji)
    }
    public init(centerEmoji:String,surroundingEmojis:[String],emojiSize:EmojiSize = .normal, rimColor:Color,thickness:LBBadgeRimThickness = .normal) {
        self.centerEmoji = centerEmoji
        self.surroundingEmojis = surroundingEmojis
        self.rimColor = rimColor
        self.thickness = thickness
        self.emojiSize = emojiSize
    }
    public var body: some View {
        LBBadgeView(rimColor: rimColor, thickness: thickness) { diameter in
            ZStack() {
                Text(centerEmoji).font(Font.system(size: diameter * emojiSize.center))
                ForEach(surroundingEmojis, id: \.self) { emoji in
                    Text(emoji)
                        .font(Font.system(size: diameter * emojiSize.outer))
                        .rotationEffect(Angle(degrees: angle(for: emoji) * -1))
                        .offset(x: diameter * emojiSize.offset, y: 0)
                        .rotationEffect(Angle(degrees: angle(for: emoji)))
                }
            }
        }
    }
}
struct LBBackgrounds_Previews: PreviewProvider {
    static var previews: some View {
//        LBEmojiBadgeView(emoji: "👻", rimColor: Color.yellow)
//        LBEmojiBadgeView(emoji: "👻", rimColor: Color.yellow).disabled(true)
//        LBEmojisBadgeView(centerEmoji: "😄", surroundingEmojis: ["🎒", "🤸‍♂️", "👩‍💻", "🎸", "⚽️","🧩","🌳","✏️"], rimColor: Color.blue)
        LBMulticolorCircle([Color.red,.green,.gray,.yellow])
            .frame(maxWidth:.infinity,maxHeight: .infinity)
            .background(Color.blue)
    }
}
