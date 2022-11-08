//
//  MovementFootsteps.swift
//  
//
//  Created by Fredrik Häggbom on 2022-11-02.
//

import Foundation
import SwiftUI

struct MovementFootsteps: View {
    @State var animating = false

    var body: some View {
        GeometryReader { proxy in
            ForEach(1...getCount(proxy: proxy), id: \.self) { i in
                let isLeft = i%2 == 0
                let point = getPoint(index: i, proxy: proxy, isLeft: isLeft)

                MovementFootstep(flip: isLeft, proxy: proxy, isLeft: isLeft)
                    .position(x: point.x, y: point.y)
                    .animation(nil)
                    .opacity(animating ? 1 : 0)
                    .animation(Animation.easeIn.delay(0.35*Double(i)), value: animating)
            }
        }.onAppear {
            animating = true
        }
    }
}

func getCount(proxy: GeometryProxy) -> Int {
    let height = proxy.frame(in: .local).height
    return Int(floor(height/(height*0.12)))
}

func getPoint(index: Int, proxy: GeometryProxy, isLeft: Bool) -> CGPoint {
    let yStart = proxy.frame(in: .local).height * 1.05
    let yDelta = CGFloat(index) * (proxy.frame(in: .local).height * 0.12)
    let y = yStart - yDelta
    
    let xStart = proxy.frame(in: .local).width * 0.35
    let xDelta = (!isLeft ? -45 : 45) - (index * 10)
    let x = xStart - CGFloat(xDelta)
    
    return CGPoint(x: x, y: y)
}

struct MovementFootsteps_Previews: PreviewProvider {
    static var previews: some View {
        MovementFootsteps()
    }
}

struct MovementFootstep: View {
    var flip: Bool
    var proxy: GeometryProxy
    var isLeft: Bool
    var body: some View {
            let fontSize = max(min(proxy.size.width, proxy.size.height) * 0.2, 60)
            Text("🦶")
                .font(.system(size: fontSize))
                .rotation3DEffect(.degrees(flip ? 180 : 0), axis: (x: 0, y: 1, z: 0))
                .rotationEffect(.degrees(isLeft ? 0 : 22))
    }
}
