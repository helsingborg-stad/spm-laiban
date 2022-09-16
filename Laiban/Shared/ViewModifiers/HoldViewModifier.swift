//
//  SwiftUIView.swift
//  
//
//  Created by Tomas Green on 2021-12-02.
//

import SwiftUI

public struct Hold: ViewModifier {
    public typealias Trigger = () -> Void
    @State private var isHolding:Bool = false
    public var minimumDuration:Double = 0
    public var maximumDistance:CGFloat =  0
    public var trigger:Trigger
    public init(minimumDuration: Double = 0, maximumDistance: CGFloat = 0, trigger: @escaping Trigger) {
        self.minimumDuration = minimumDuration
        self.maximumDistance = maximumDistance
        self.trigger = trigger
    }
    public func body(content:Content) -> some View {
        content
            .onLongPressGesture(minimumDuration: minimumDuration, maximumDistance: maximumDistance) {
                trigger()
            } onPressingChanged: { hold in
                withAnimation {
                    self.isHolding = hold
                }
            }
            .scaleEffect(isHolding ? 0.8 : 1.0)
            .opacity(isHolding ? 0.5 : 1.0)
            .animation(.spring(), value: isHolding)

    }
}
public extension View {
    func hold(minimumDuration:Double = 0, maximumDistance:CGFloat =  0, trigger: @escaping Hold.Trigger) -> some View {
        self.modifier(Hold(minimumDuration: minimumDuration, maximumDistance: maximumDistance, trigger: trigger))
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    struct TestHold: View {
        @State var triggered = 0
        var body: some View {
            Text("Hello, World! \(triggered) ").hold(minimumDuration: 1) {
                triggered += 1
            }
        }
    }
    static var previews: some View {
        TestHold()
    }
}
