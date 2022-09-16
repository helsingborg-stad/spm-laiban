//
//  MonsterSpeechBubbleView.swift
//  LaibanApp
//
//  Created by Jonatan Hanson on 2022-05-03.
//


import SwiftUI

struct MonsterSpeechBubbleView: View {
    @Environment(\.fullscreenContainerProperties) var properties
    var text: String
    var image: Image
    var action: () -> Void
    var overlay: some View {
        Button(action: action) {
            image.resizable().aspectRatio(1, contentMode: .fit)
        }
    }

    var body: some View {
        GeometryReader { proxy in
            HStack(alignment: .center) {
                Spacer()
                Text(text)
                    .padding(properties.spacing[.s])
                    .padding(.trailing, proxy.size.width * 0.22)
                    .background(RoundedRectangle(cornerRadius: 15).fill(Color("BubbleBackgroundColor",bundle:LBBundle)))
                    .padding(.trailing, proxy.size.height * 0.5)
                    .clipped()
                    .padding(.top, proxy.size.height * 0.3)
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                .font(properties.font, ofSize: .s)
                .overlay(overlay.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing))
                .shadow()
        }
    }
}

struct MonsterSpeechBubbleView2: View {
    @Environment(\.fullscreenContainerProperties) var properties
    var text: String
    var image: Image
    var action: () -> Void
    var overlay: some View {
        image.resizable().aspectRatio(1, contentMode: .fit)
    }

    var body: some View {
        GeometryReader { proxy in
            let proc: CGFloat = 0.5
            Text(text)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(properties.spacing[.s])
                .background(RoundedRectangle(cornerRadius: 15).fill(Color("BubbleBackgroundColor",bundle:LBBundle)))
                .padding(.top, proxy.size.height * proc * 0.7)
                .clipped()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .font(properties.font, ofSize: .s)
                .overlay(overlay.frame(width: proxy.size.height * proc, height: proxy.size.height * proc, alignment: .top).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top))
                .shadow()
        }
    }
}

struct MonsterSpeechBubbleView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            MonsterSpeechBubbleView(text: "Vill du väga mat? Tryck på mig, Kompostina!", image: Image("Monster-Kompostina-Avatar")) {}.frame(height: 200)
            MonsterSpeechBubbleView2(text: "Vill du väga mat? Tryck på mig, Kompostina!", image: Image("Monster-Kompostina-Avatar")) {}.frame(width: 400, height: 200)
        }
    }
}
