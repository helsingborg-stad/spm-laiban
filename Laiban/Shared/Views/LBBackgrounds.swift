//
//  Backdrop.swift
//
//  Created by Tomas Green on 2020-03-24.
//

import SwiftUI

public enum LBBackground {
    case primary
    case secondary
}

public struct LBCapsuleBackground : View {
    var color:Color
    public init(color:Color? = nil) {
        self.color = color ?? Color("PrimaryContainerBackgroundColor", bundle:.module)
    }
    public var body: some View {
        Capsule().fill(color).foregroundColor(Color.black.opacity(0.8))
            .frame(maxWidth:.infinity,alignment: .leading)
            .clipShape(Capsule())
            .shadow(color: Color.black.opacity(0.2), radius: 7, x: 0, y: 0)
    }
}
public struct LBPrimaryContainerBackground : View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    public var smallestSizeClass:UserInterfaceSizeClass {
        return (verticalSizeClass == .compact || horizontalSizeClass == .compact) ? .compact : .regular
    }
    var cornerRadius:CGFloat?
    var color:Color
    public init(cornerRadius:CGFloat? = nil, color:Color? = nil) {
        self.color = color ?? Color("PrimaryContainerBackgroundColor", bundle:.module)
        self.cornerRadius = cornerRadius
    }
    var radius:CGFloat {
        cornerRadius ?? (smallestSizeClass == .compact ? 15 : 30)
    }
    public var body: some View {
        RoundedRectangle(cornerRadius: radius)
            .fill(color)
            .clipShape(RoundedRectangle(cornerRadius: radius))
            .shadow(color: Color.black.opacity(0.2), radius: 7, x: 0, y: 0)
    }
}
public struct LBTertiaryContainerBackground : View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    public var smallestSizeClass:UserInterfaceSizeClass {
        return (verticalSizeClass == .compact || horizontalSizeClass == .compact) ? .compact : .regular
    }
    var cornerRadius:CGFloat?
    var color:Color
    public init(cornerRadius:CGFloat? = nil, color:Color? = nil) {
        self.color = color ?? Color.white
        self.cornerRadius = cornerRadius
    }
    var radius:CGFloat {
        cornerRadius ?? (smallestSizeClass == .compact ? 15 : 30)
    }
    public var body: some View {
        RoundedRectangle(cornerRadius: radius)
            .fill(color)
            .clipShape(RoundedRectangle(cornerRadius: radius))
            .shadow(color: Color.black.opacity(0.2), radius: 7, x: 0, y: 0)
    }
}
public struct LBSecondaryContainerBackground : View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    public var smallestSizeClass:UserInterfaceSizeClass {
        return (verticalSizeClass == .compact || horizontalSizeClass == .compact) ? .compact : .regular
    }
    var cornerRadius:CGFloat?
    var color:Color
    var borderColor:Color
    var radius:CGFloat {
        cornerRadius ?? (smallestSizeClass == .compact ? 15 : 30)
    }
    public init(cornerRadius:CGFloat? = nil, color:Color? = nil, borderColor:Color? = nil) {
        self.color = color ?? Color("SecondaryContainerBackgroundColor", bundle:.module)
        self.borderColor = borderColor ?? Color("SecondaryContainerBorderColor", bundle:.module)
        self.cornerRadius = cornerRadius
    }
    public var body: some View {
        Rectangle()
            .fill(color)
            .frame(maxWidth:.infinity, maxHeight:.infinity,alignment: .center)
            .overlay(RoundedRectangle(cornerRadius: radius).stroke(borderColor, lineWidth: 6))
            .clipShape(RoundedRectangle(cornerRadius: radius))
    }
}

public extension View {
    func primaryContainerBackground(cornerRadius:CGFloat? = nil,color:Color? = nil) -> some View {
        background(LBPrimaryContainerBackground(cornerRadius:cornerRadius,color:color))
    }
    func secondaryContainerBackground(cornerRadius:CGFloat? = nil,color:Color? = nil, borderColor:Color? = nil) -> some View {
        background(LBSecondaryContainerBackground(cornerRadius:cornerRadius,color:color,borderColor:borderColor))
    }
    func tertieryContainerBackground(cornerRadius:CGFloat? = nil,color:Color? = nil) -> some View {
        background(LBTertiaryContainerBackground(cornerRadius:cornerRadius,color:color))
    }
    func tertieryClippedContainerBackground(cornerRadius:CGFloat? = nil,color:Color? = nil) -> some View {
        background(LBTertiaryContainerBackground(cornerRadius:cornerRadius,color:color))
    }
    func capsuleContainerBackround(color:Color? = nil) -> some View {
        background(LBCapsuleBackground(color: color))
    }
    @ViewBuilder func background(_ background:LBBackground?) -> some View {
        if background == .primary {
            self.primaryContainerBackground()
        } else if background == .secondary {
            self.secondaryContainerBackground()
        } else {
            self
        }
    }
}
public struct LBPrimaryButtonStyle: ButtonStyle {
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
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(LinearGradient(gradient: gradient, startPoint: .top, endPoint: .bottom))
            .clipShape(Capsule())
            .shadow(color: Color.black.opacity(configuration.isPressed ? 0 : 0.35), radius: 2, x: 0, y: 1)
            .opacity(configuration.isPressed ? 0.5 : 1)
            .animation(.spring(), value: configuration.isPressed)
    }
}
