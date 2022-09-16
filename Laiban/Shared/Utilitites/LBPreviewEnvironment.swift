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
private let previewAssistant:Assistant = {
    let a = Assistant(
        sttService: AppleSTT(audioSwitchboard: lbPreviewAssistantProxySwitchboard),
        ttsServices: AppleTTS(audioSwitchBoard: lbPreviewAssistantProxySwitchboard),
        voiceCommands: Assistant.CommandBridge.DB()
    )
    a.dragoman.add(bundle: LBBundle)
    a.stt.disabled = true
    a.tts.disabled = true
    return a
}()
private let previewViewState = LBViewState()
public extension View {
    func attachPreviewEnvironmentObjects(ttsDisabled:Bool = true) -> some View {
        previewAssistant.tts.disabled = ttsDisabled
        return self.environmentObject(previewAssistant).environmentObject(previewViewState)
    }
}
