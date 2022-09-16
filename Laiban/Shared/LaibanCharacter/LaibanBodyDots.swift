//
//  LaibanBodyDots.swift
//
//  Created by Tomas Green on 2020-03-17.
//

import SwiftUI

public struct LaibanBodyDots: View {
    let timer = Timer.publish(every: 0.5, on: .current, in: .common).autoconnect()
    @State var redDotLit = true
    @State var greenDotLit = true
    @State var yellowDotLit = true
    var ellipsified:Bool
    init(ellipsified:Bool = true) {
        self.ellipsified = ellipsified
    }
    public var body: some View {
        GeometryReader { proxy in
            let aspect:CGFloat = ellipsified ? 6/10 : 1
            let size:CGFloat = proxy.size.width * 0.03
            let litSaturation:CGFloat = 1
            let unlitSaturation:CGFloat = 0.3
            let litOpacity:CGFloat = 1
            let unlitOpacity:CGFloat = 0.8
            HStack(alignment:.center, spacing: proxy.size.width/18) {
                Ellipse()
                    .fill(Color.red)
                    .aspectRatio(aspect,contentMode: .fit)
                    .saturation(self.redDotLit ?  litSaturation : unlitSaturation)
                    .opacity(self.redDotLit ? litOpacity : unlitOpacity)
                    .padding(size)
                    .shadow(color: Color.red, radius: self.redDotLit ? size : 0).drawingGroup()
                    .animation(.none, value: redDotLit)
                Ellipse()
                    .fill(Color.green)
                    .aspectRatio(aspect,contentMode: .fit)
                    .saturation(self.greenDotLit ? litSaturation : unlitSaturation)
                    .opacity(self.greenDotLit ?litOpacity : unlitOpacity)
                    .padding(size)
                    .shadow(color: Color.green, radius: self.greenDotLit ? size : 0).drawingGroup()
                    .animation(.none, value: greenDotLit)
                Ellipse()
                    .fill(Color.yellow)
                    .aspectRatio(aspect,contentMode: .fit)
                    .saturation(self.yellowDotLit ?  litSaturation : unlitSaturation)
                    .opacity(self.yellowDotLit ? litOpacity : unlitOpacity)
                    .padding(size)
                    .shadow(color: Color.yellow, radius: self.yellowDotLit ? size : 0).drawingGroup()
                    .animation(.none, value: yellowDotLit)
            }
            .position(x: proxy.size.width/2, y: proxy.size.height/2)
        }
        .onReceive(timer) { (timer) in
            self.redDotLit = Bool.random()
            self.greenDotLit = Bool.random()
            self.yellowDotLit = Bool.random()
        }
        .aspectRatio(ellipsified ? 2/1 : 3/1,contentMode: .fit)
        .drawingGroup()
    }
}

struct LaibanBodyDots_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            LaibanBodyDots(ellipsified:false).frame(width: 200)
            LaibanBodyDots().frame(width: 200)
        }
    }
}
