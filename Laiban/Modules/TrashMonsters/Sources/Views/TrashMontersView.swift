//
//  TrashMontersView.swift
//  Laiban
//
//  Created by Tomas Green on 2021-06-01.
//

import Combine

import SwiftUI
import Assistant

public struct MonsterInfoRegularView : View {
    @Environment(\.fullscreenContainerProperties) var properties
    var monster:Monster
    public init(monster:Monster) {
        self.monster = monster
    }
    public var body: some View {
        GeometryReader { p in
            HStack(alignment:.top,spacing: 20) {
                VStack(spacing: 10) {
                    Text(monster.name)
                        .font(properties.font, ofSize: .l)
                        .frame(maxWidth:.infinity,alignment: .topLeading)
                    Text(LocalizedStringKey(monster.descriptionKey),bundle: LBBundle)
                        .font(properties.font, ofSize: .n)
                        .frame(maxWidth:.infinity,alignment: .topLeading)
                        .lineLimit(nil)
                    
                }.frame(maxWidth:.infinity,maxHeight: .infinity,alignment: .topLeading)
                monster.image.resizable().aspectRatio(contentMode: .fit).frame(width:p.size.height * 0.7)
            }.padding(30)
        }
        .frame(maxWidth:.infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(enabled: true)
    }
}
public struct MonsterInfoView : View {
    @Environment(\.fullscreenContainerProperties) var properties
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var monster:Monster
    public init(monster:Monster) {
        self.monster = monster
    }
    public var body : some View {
        if horizontalSizeClass == .regular {
            MonsterInfoRegularView(monster: monster)
        } else {
            MonsterInfoCompactView(monster: monster)
        }
    }
}

public struct MonsterInfoCompactView : View {
    @Environment(\.fullscreenContainerProperties) var properties
    var monster:Monster
    public init(monster:Monster) {
        self.monster = monster
    }
    public var body: some View {
        GeometryReader { p in
            HStack(alignment:.top, spacing: 15) {
                VStack(alignment:.leading) {
                    Text(monster.name)
                        .font(properties.font, ofSize: .l)
                        .frame(maxWidth:.infinity,alignment: .topLeading)
                    Text(LocalizedStringKey(monster.descriptionKey),bundle: LBBundle)
                        .font(properties.font, ofSize: .n)
                        .frame(maxWidth:.infinity,alignment: .topLeading)
                        .lineLimit(nil)
                }
                monster.image.resizable().aspectRatio(contentMode: .fit).frame(height:p.size.height * 0.2)

            }.frame(maxWidth:.infinity,maxHeight: .infinity,alignment: .topLeading).padding(20)
        }
        .frame(maxWidth:.infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(enabled: true)
    }
}

public struct TrashMontersView: View {
    @Environment(\.fullscreenContainerProperties) var properties
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject var assistant: Assistant
    var monsters: [Monster] = Monster.loadSync()
    @State var selectedMonster: Monster? {
        didSet {
            if let monster = selectedMonster {
                assistant.speak(monster.descriptionKey)
            }
        }
    }
    public init () {
        
    }
    public var body: some View {
        VStack {
            LBGridView(items: monsters.count, columns: 5, verticalSpacing: 7, horizontalSpacing: 7, verticalAlignment: .top, horizontalAlignment: .center) { index in
                let m = monsters[index]
                Button(action: {
                    selectedMonster = m
                    LBAnalyticsProxy.shared.logContentImpression("TrashMonster", piece: m.name)
                }, label: {
                    m.avatar
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: (properties.contentSize.width / 5) * 0.7)
                        .shadow(radius: assistant.isSpeaking ? 0 : 5)
                })
            }.frame(maxWidth: .infinity)
            if selectedMonster != nil {
                MonsterInfoView(monster: selectedMonster!)
                    .padding(.top, horizontalSizeClass == .regular ? 40 : 20)
            } else {
                Text(LocalizedStringKey("trashmonster_press_to_learn_more"),bundle: LBBundle)
                    .font(properties.font, ofSize: .l)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(properties.spacing[.m])
        .primaryContainerBackground()
        .onAppear {
            assistant.speak([
                ("trashmonster_press_to_learn_more", "trashmonster_press_to_learn_more"),
            ])
            LBAnalyticsProxy.shared.logPageView(self)
        }
    }
}

struct TrashMontersView_Previews: PreviewProvider {
    static var previews: some View {
        LBFullscreenContainer { _ in
            TrashMontersView()
        }.attachPreviewEnvironmentObjects()
    }
}
