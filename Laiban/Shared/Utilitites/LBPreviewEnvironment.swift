//
//  LBAssistant.swift
//  LaibanApp
//
//  Created by Tomas Green on 2022-04-26.
//

import Foundation
import TTS
import STT
import Combine
import AudioSwitchboard
import SwiftUI
import TextTranslator
import Assistant

private let lbPreviewAssistantProxySwitchboard:AudioSwitchboard = {
    AudioSwitchboard()
}()
private let lbPreviewAssistantTTS:TTS = {
    TTS(AppleTTS(audioSwitchBoard: lbPreviewAssistantProxySwitchboard))
}()
private func createPreviewAssistant() -> Assistant{
    let a = Assistant(
        sttService: AppleSTT(audioSwitchboard: lbPreviewAssistantProxySwitchboard),
        ttsServices: AppleTTS(audioSwitchBoard: lbPreviewAssistantProxySwitchboard),
        voiceCommands: Assistant.CommandBridge.DB()
    )
    a.dragoman.add(bundle: LBBundle)
    a.stt.disabled = true
    a.tts.disabled = true
    return a
}
private let previewAssistant:Assistant = {
    return createPreviewAssistant()
}()
private let previewViewState = LBViewState()
public extension View {
    func attachPreviewEnvironmentObjects(identity:LBViewIdentity? = nil, ttsDisabled:Bool = true) -> some View {
        if let identity {
            previewViewState.navigate(to: identity)
        }
        previewAssistant.tts.disabled = ttsDisabled
        return self.environmentObject(previewAssistant).environmentObject(previewViewState)
    }
}
struct LBPreviewContainer<Screen:View>: View {
    @StateObject var assistant = createPreviewAssistant()
    @StateObject var viewState = LBViewState()
    var identity:LBViewIdentity
    var content:() -> Screen
    public var body: some View {
        LBFullscreenContainer { props in
           content()
        }
        .onContainerAction { action in
            switch action {
            case .back:
                if viewState.previousValue != nil {
                    viewState.dismiss()
                }
            case .home: viewState.clear()
            case .languages: viewState.present(.languages)
            case .admin:  break
            case .character: break
            case .custom(let string): print(string)
            }
        }
        .character(image: viewState.characterImage)
        .character(hidden: viewState.characterHidden)
        .character(position: viewState.characterPosition)
        .actionBarButtons(viewState.actionButtons)
        .animation(.spring(), value: viewState.value)
        .statusBar(hidden: true)
        .environmentObject(assistant)
        .environmentObject(viewState)
        .onAppear {
            viewState.navigate(to: identity)
        }
    }
}
