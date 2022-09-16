//
//  LBActionBarViews.swift
//  Testing
//
//  Created by Tomas Green on 2022-04-19.
//

import SwiftUI


public struct LBActionBarCircleAdminView: View {
    @Environment(\.isEnabled) var isEnabled
    public let emoji:String
    public init(emoji:String = "🧑‍💼") {
        self.emoji = emoji
    }
    public var body: some View {
        GeometryReader { proxy in
            let size = proxy.size.width
            Text("🧑‍💼")
                .font(.system(size: size * 0.3))
                .padding(size * 0.2)
                .position(x: size/2, y: size/2)
        }
        .background(Circle().fill(Color.black).opacity(0.3))
        .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 2)
        .aspectRatio(1,contentMode: .fit)
        .saturation(isEnabled ? 1 : 0)
        .opacity(isEnabled ? 1: 0.5)
    }
}
public struct LBActionBarCircleEmojiView: View {
    @Environment(\.isEnabled) var isEnabled
    var emoji: String
    var color: Color
    public init(emoji:String, color:Color) {
        self.emoji = emoji
        self.color = color
    }
    public var body: some View {
        GeometryReader { proxy in
            let size = proxy.size.width
            Circle().fill(color).shadow(color: Color.black.opacity(0.3), radius: size * 0.03, x: 0, y: 0)
            Text(emoji)
                .font(Font.system(size: size * 0.6))
                .minimumScaleFactor(0.01)
                .frame(width:size * 0.7,height:size * 0.7)
                .shadow(color: Color.black.opacity(0.3), radius: 1, x: 0, y: 2)
                .position(x: size/2, y: size/2)
        }
        .aspectRatio(1,contentMode: .fit)
        .saturation(isEnabled ? 1 : 0)
        .opacity(isEnabled ? 1: 0.5)
    }
}
public struct LBActionBarCircleImageView: View {
    @Environment(\.isEnabled) var isEnabled
    var image: Image
    var color: Color
    public init(image:Image, color:Color) {
        self.image = image
        self.color = color
    }
    public var body: some View {
        GeometryReader { proxy in
            Circle().fill(color).shadow(color: Color.black.opacity(0.3), radius: proxy.size.width * 0.03, x: 0, y: 0)
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width:proxy.size.width * 0.7,height:proxy.size.height * 0.7)
                .shadow(color: Color.black.opacity(0.3), radius: 1, x: 0, y: 2)
                .position(x: proxy.size.width/2, y: proxy.size.height/2)
        }
        .aspectRatio(1,contentMode: .fit)
        .saturation(isEnabled ? 1 : 0.3)

    }
}
