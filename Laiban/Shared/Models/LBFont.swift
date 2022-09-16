//
//  LBFont.swift
//  Testing
//
//  Created by Tomas Green on 2022-04-20.
//

import SwiftUI

public struct LBFontModifier : ViewModifier {
    public var font:LBFont
    public var size:LBFont.Size
    public var weight:Font.Weight? = nil
    public var color:Color? = nil
    public func body(content:Content) -> some View {
        content
            .font(font.ofSize(size,weight: weight))
            .minimumScaleFactor(font.ratio)
            .foregroundColor(color ?? font.color)
    }
}
public extension View {
    func font(_ font:LBFont, ofSize size:LBFont.Size, weight:Font.Weight? = nil, color:Color? = nil ) -> some View {
        modifier(LBFontModifier(font: font, size: size, weight:weight, color:color ?? Color("DefaultTextColor", bundle:Bundle.module)))
    }
}
public struct LBFont {
    public enum Size : String, CaseIterable, Equatable {
        case xxxs
        case xxs
        case xs
        case s
        case n
        case l
        case xl
        case xxl
        var name:String {
            switch self {
            case .xxxs: return "Extra-extra-extra small"
            case .xxs: return "Extra-extra small"
            case .xs: return "Extra small"
            case .s: return "Small"
            case .n: return "Normal"
            case .l: return "Large"
            case .xl: return "Extra large"
            case .xxl: return "Extra-extra large"
            }
        }
    }
    public let weight:Font.Weight
    public let color:Color
    public let sizes:[Size:CGFloat]
    public let ratio:CGFloat
    public init(container size:CGSize,weight:Font.Weight = .semibold, color:Color? = nil) {
        self.color = color ?? Color("DefaultTextColor", bundle:Bundle.module)
        self.weight = weight
        ratio = size.height > size.width ? size.width/size.height : size.height/size.width
        var sizes = [Size:CGFloat]()
        sizes[.xxxs] = ratio * 20
        sizes[.xxs] = ratio * 24
        sizes[.xs] = ratio * 28
        sizes[.s] = ratio * 32
        sizes[.n] = ratio * 35
        sizes[.l] = ratio * 45
        sizes[.xl] = ratio * 50
        sizes[.xxl] = ratio * 80
        self.sizes = sizes
    }
    public func ofSize(_ size:Size, weight:Font.Weight? = nil) -> Font {
        return .system(size: sizes[size]!, weight: weight ?? self.weight, design: .rounded)
    }
}
