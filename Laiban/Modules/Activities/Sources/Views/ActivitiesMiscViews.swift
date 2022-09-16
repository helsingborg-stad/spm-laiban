//
//  ActivitiesMiscViews.swift
//  LaibanApp
//
//  Created by Tomas Green on 2022-04-26.
//

import SwiftUI
import SharedActivities
import SDWebImageSwiftUI

import Assistant

struct ActivityImageURLModifier: ViewModifier {
    @State var loading:Bool = true
    var url:URL
    var bg: some View {
        WebImage(url: url)
            .resizable()
            .placeholder {
                LBActivityIndicator(isAnimating: $loading, style: .large).foregroundColor(.gray)
            }
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth:.infinity,maxHeight:.infinity)
            .background(Color.black.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: 30))
        
    }
    func body(content:Content) -> some View {
        content
            .background(bg)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 0)
    }
}
struct ActivityImageModifier: ViewModifier {
    @State var loading:Bool = true
    var image:Image
    var bg: some View {
        image.resizable()
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth:.infinity,maxHeight:.infinity)
            .clipShape(RoundedRectangle(cornerRadius: 30))
    }
    func body(content:Content) -> some View {
        content
            .background(bg)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 0)
    }
}

struct ActivitiesViewImageItem: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject var assistant:Assistant
    @EnvironmentObject var viewState:LBViewState
    @Environment(\.fullscreenContainerProperties) var properties
    @Environment(\.locale) var locale
    var title:String
    var goals:[UNDPGoal] = []
    var fontSize:LBFont.Size = .s
    var overlay: some View {
        GeometryReader { proxy in
            let size = proxy.size.height * 0.12 * properties.windowRatio
            HStack {
                Spacer()
                ForEach(goals) { goal in
                    UNDPCircleView(goal: goal, size: size)
                }
            }
        }.padding().frame(maxWidth:.infinity,maxHeight:.infinity,alignment: .topTrailing)
    }
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Text(LocalizedStringKey(title),bundle: assistant.translationBundle)
            }
            .frame(maxWidth:.infinity)
            .padding()
            .background(Color.white)
            .cornerRadius(25)
            .font(properties.font, ofSize: fontSize,weight:.semibold)
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth:.infinity,maxHeight:.infinity)
        .padding()
        .overlay(overlay)
    }
}
struct ActivitiesViewEmojiItem: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject var assistant:Assistant
    @EnvironmentObject var viewState:LBViewState
    @Environment(\.fullscreenContainerProperties) var properties
    @Environment(\.locale) var locale
    var title:String
    var emoji:String
    var goals:[UNDPGoal] = []
    var fontSize:LBFont.Size = .s
    var overlay: some View {
        GeometryReader { proxy in
            let size = proxy.size.height * 0.12 * properties.windowRatio
            HStack {
                Spacer()
                ForEach(goals) { goal in
                    UNDPCircleView(goal: goal, size: size)
                }
            }
        }.padding().frame(maxWidth:.infinity,maxHeight:.infinity,alignment: .topTrailing)
    }
    var body: some View {
        GeometryReader { geometry in
            VStack {
                GeometryReader { geometry2 in
                    Text(emoji).font(.system(size: geometry2.size.height * 0.7))
                        .frame(maxWidth:.infinity,maxHeight: .infinity,alignment: .center)
                }.frame(maxWidth:.infinity,maxHeight: .infinity,alignment: .center)
                Text(LocalizedStringKey(title),bundle: assistant.translationBundle)
                    .font(properties.font, ofSize: fontSize,weight:.semibold)
                    .padding()
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth:.infinity,maxHeight:.infinity,alignment:.center)
        }
        .padding()
        .frame(maxWidth:.infinity,maxHeight:.infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 0)
        .overlay(overlay)
    }
}
