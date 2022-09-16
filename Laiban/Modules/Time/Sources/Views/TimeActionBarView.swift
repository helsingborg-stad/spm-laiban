//
//  TimeActionBarView.swift
//  LaibanApp
//
//  Created by Tomas Green on 2022-05-18.
//

import SwiftUI

import Assistant

public struct TimeActionBarView: View {
    @Environment(\.fullscreenContainerProperties) var properties
    @EnvironmentObject var assistant:Assistant
    @EnvironmentObject var viewState:LBViewState
    var actionBarProperties:LBAactionBarProperties
    var visible:Bool {
        if let opt = viewState.options, opt == TimeView.showChildInfoId {
            return false
        } else {
            return true
        }
    }
    public init(actionBarProperties:LBAactionBarProperties) {
        self.actionBarProperties = actionBarProperties
    }
    public var body: some View {
        HStack() {
            Text(LocalizedStringKey("clock_select_show_tempus_info"),bundle: LBBundle)
                .frame(maxWidth:.infinity,maxHeight:.infinity,alignment:.center)
                .font(properties.font, ofSize: .s,color:.white)
                .multilineTextAlignment(.center)
                .scaleEffect(assistant.currentlySpeaking?.tag == "clock_select_show_tempus_info" ? 1.2 : 1)
            Button(action:{
                viewState.options(TimeView.showChildInfoId, for: .time)
            }) {
                LBBadgeView(rimColor: Color("RimColorClock",bundle:LBBundle), backgroundColor:Color.black.opacity(0.5)) { diameter in
                    Text("💡").font(Font.system(size: diameter * 0.5))
                }
            }
        }
        .frame(maxWidth:.infinity,maxHeight:.infinity,alignment: .center)
        .padding(properties.spacing[.m])
        .capsuleContainerBackround(color: Color("RimColorClock",bundle:LBBundle))
        .opacity(self.visible ? 1 : 0)
        .disabled(!self.visible)
    }
}
//
//struct TimeActionBarView_Previews: PreviewProvider {
//    static var previews: some View {
//        TimeActionBarView()
//    }
//}
//if manager.appState?.tempus.isAvailable == true && manager.children.count > 0 {
//    HStack() {
//        let s = LocalizedString.string(key: "clock_select_show_tempus_info", in: manager.language)
//        Text(s)
//            .frame(maxWidth:.infinity,maxHeight:.infinity,alignment:.center)
//            .modifier(LaibanFont(size:.s,color:.white)).multilineTextAlignment(.center)
//            .scaleEffect(manager.legacyTTS.currentlySpeaking == s.description ? 1.2 : 1)
//        Button(action:{
//            self.manager.toggleTempus()
//        }) {
//            #warning("exchange for LBBadge with backgroundColor: Color.black.opacity(0.5)")
//            DimmedEmojiCircleView(emoji: "💡", rimColor: Color("RimColorClock"))
//        }
//    }
//    .frame(maxWidth:.infinity,maxHeight:.infinity,alignment: .center)
//    .padding(properties.spacing[.m])
//    .background(CapsuleBackdrop(color:Color("RimColorClock")))
//    .opacity(manager.showTempus ? 0 : 1)
//    .disabled(!manager.canInterrupt)
//} else {
//    Spacer()
//}
