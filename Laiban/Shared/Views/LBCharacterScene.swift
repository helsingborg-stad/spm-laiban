//
//  LaibanScene.swift
//  Testing
//
//  Created by Tomas Green on 2022-04-14.
//

import SwiftUI

public struct LBCharacterScene: View {
    var showCharacter: Bool
    var image:Image?
    public init(showCharacter:Bool = true, image:Image? = nil) {
        self.showCharacter = showCharacter
        self.image = image
    }
    public var body: some View {
        ZStack {
            GeometryReader { proxy in
                let bodySize = proxy.size.height*0.9
                let platformSize = proxy.size.width * 0.8
                if showCharacter {
                    if image != nil {
                        image?
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: bodySize)
                            .offset(x: 0, y:bodySize * 0.01)
                            .frame(maxWidth:.infinity,maxHeight: .infinity,alignment: .top)
                            .zIndex(10)
                            .animation(.spring(), value: image)
                            .animation(.spring(), value: showCharacter)
                            .transition(.move(edge: .trailing))
                    } else {
                        LaibanBodyWithShadow(expression: .smile)
                            .frame(height: bodySize)
                            .offset(x: proxy.size.width * -0.03, y:bodySize * 0.01)
                            .frame(maxWidth:.infinity,maxHeight: .infinity,alignment: .top)
                            .zIndex(10)
                            .animation(.spring(), value: image)
                            .animation(.spring(), value: showCharacter)
                            .transition(.move(edge: .trailing))
                    }
                    
                }
                ZStack(alignment: .center) {
                    Ellipse().fill(Color.white).frame(height: proxy.size.height*0.3)
                        .opacity(0.05)
                    Ellipse().fill(Color.white).frame(width:platformSize*0.75, height: proxy.size.height*0.16)
                        .opacity(0.05)
                }
                .frame(width: proxy.size.width * 0.8)
                .frame(maxWidth:.infinity,maxHeight: .infinity,alignment: .bottom)
                .zIndex(2)
            }
        }
        .aspectRatio(130/50,contentMode: .fit)
        .animation(.spring(), value: image)
        .animation(.spring(), value: showCharacter)
        .transition(.move(edge: .leading))
    }
}
struct LaibanScene_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LBCharacterScene()
                .frame(maxWidth:.infinity,maxHeight: .infinity,alignment: .bottom)
        }
    }
}
