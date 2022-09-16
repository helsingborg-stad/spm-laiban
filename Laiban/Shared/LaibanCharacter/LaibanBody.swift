//
//  Robot.swift
//
//  Created by Tomas Green on 2020-03-10.
//

import SwiftUI

public struct LaibanBody: View {
    var expression:LaibanExpression
    var animated:Bool = true
    public init(expression:LaibanExpression,animated:Bool = true) {
        self.expression = expression
        self.animated = animated
    }
    public var body: some View {
        ZStack {
            GeometryReader() { proxy in
                LaibanBodyDots()
                    .frame(width: proxy.size.width * 0.08,height: proxy.size.width * 0.08)
                    .position(x:proxy.size.width/2 + proxy.size.width * 0.04, y:proxy.size.height/2 + proxy.size.height * 0.22)
                    .zIndex(6)
                LaibanFaceView(expression: expression, showImage: false, animated: self.animated)
                    .frame(width: proxy.size.width * 0.8)
                    .position(x:proxy.size.width/2 + proxy.size.width * -0.04,y:proxy.size.height/2 - proxy.size.height * 0.155)
                    .zIndex(4)
                Image("RobotLaibanBodyRight", bundle:.module)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(alignment: .center)
        .drawingGroup()
    }
}
public struct LaibanBodyWithShadow: View {
    @State var timer = Timer.publish(every: 2.2, on: .current, in: .common).autoconnect()
    @State private var atTop:Bool = false
    var animated:Bool = true
    var expression:LaibanExpression
    public init(expression:LaibanExpression,animated:Bool = true) {
        self.expression = expression
        self.animated = animated
    }
    public var body: some View {
        ZStack {
            GeometryReader { proxy in
                let bodySize = proxy.size.height*0.93
                let centerOffset = (proxy.size.height - bodySize)/2
                LaibanBody(expression: expression)
                    .frame(width: bodySize)
                    .frame(width: proxy.size.width,height: proxy.size.height, alignment: .top)
                    .zIndex(10)
                    .offset(y: atTop ? centerOffset/2 : centerOffset)
                ZStack(alignment: .center) {
                    Ellipse()
                        .fill(Color.black)
                        .frame(width:proxy.size.width*0.5, height: proxy.size.height*0.1)
                        .zIndex(3)
                        .opacity(atTop ? 0.1 : 0.3)
                        .scaleEffect(atTop ? 0.6 : 1)
                        .offset(x:proxy.size.width * 0.12)
                }
                .frame(maxWidth:.infinity,maxHeight: .infinity,alignment: .bottom)
            }.drawingGroup()
        }
        .aspectRatio(1,contentMode: .fit)
        .onReceive(timer) { timer in
            withAnimation(.easeInOut(duration: 2)) {
                atTop.toggle()
            }
        }
    }
}

struct Robot_Previews: PreviewProvider {
    static var previews: some View {
        LaibanBodyWithShadow(expression: .smile)
    }
}
