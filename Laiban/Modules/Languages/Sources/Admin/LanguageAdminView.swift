//
//  LanguageAdminView.swift
//  LaibanApp
//
//  Created by Tomas Green on 2022-05-20.
//

import SwiftUI
import TTS

import Assistant

extension TTSGender {
    var description:String {
        switch self {
        case .male: return "Manlig röst"
        case .female: return "Kvinnlig röst"
        case .other: return "Ospecificerad"
        }
    }
}

struct LanguageAdminView: View {
    @ObservedObject var service:LanguageService
    @EnvironmentObject var assistant:Assistant
    @State private var showingCacheAlert = false
    var supportedGenders:[TTSGender] {
        var genders = [TTSGender]()
        for g in TTSGender.allCases {
            guard assistant.tts.hasSupport(for: TTSVoice(gender: g, locale: Locale(identifier: "sv_SE"))) else {
                continue
            }
            genders.append(g)
        }
        return genders
    }
    var body: some View {
        Group {
            NavigationLink(destination: LanguageSelectionAdminView(service: service)) {
                Text("Språk")
            }
            HStack {
                Text("Avbryt Laiban med interaktion")
                Spacer()
                LBToggleView(isOn: service.data.voiceCancellable) { bool in
                    service.data.voiceCancellable = bool
                    service.save()
                }
            }
            HStack {
                Text("Taligenkänning")
                Spacer()
                LBToggleView(isOn: service.data.speechRecognizerEnabled) { bool in
                    service.data.speechRecognizerEnabled = bool
                    service.save()
                }
            }
            if supportedGenders.count > 1 {
                LBNonOptionalPicker(title: "Röstsyntes", items: supportedGenders, selection: $service.data.ttsGender) { item in
                    Text(item.description)
                }
            }
            VStack(alignment:.leading,spacing:0) {
                HStack(alignment:.firstTextBaseline) {
                    Text("Uppläsningstakt").padding(.top, 10)
                    Spacer()
                    Text("\(Int(service.data.ttsRate * 100 - 100))%")
                }
                Slider(value: $service.data.ttsRate, in: Double(0)...Double(2),step:0.05)
            }
            VStack(alignment:.leading,spacing:0) {
                HStack(alignment:.firstTextBaseline) {
                    Text("Tonläge").padding(.top, 10)
                    Spacer()
                    Text("\(Int(service.data.ttsPitch * 100 - 100))%")
                }
                Slider(value: $service.data.ttsPitch, in: Double(0)...Double(2),step:0.05)
            }
            Button("Spela upp testljud") {
                let u = TTSUtterance(
                    "Såhär låter dina inställningar",
                    gender: service.data.ttsGender,
                    locale: Locale(identifier: "sv-SE"),
                    rate: service.data.ttsRate,
                    pitch: service.data.ttsPitch,
                    tag: "testplay"
                )
                assistant.interrupt(using: [u])
            }
            Button("Rensa cache") {
                assistant.tts.clearCache()
                showingCacheAlert = true
            }
            .alert(isPresented: $showingCacheAlert, content: {
                Alert(title: Text("Cachen rensad!"), message: Text("De temporära ljudfilerna har tagits bort"), dismissButton: .default(Text("Ok")))
            })
        }.onDisappear {
            service.save()
        }
    }
}

struct LanguageAdminView_Previews: PreviewProvider {
    static var service = LanguageService()
    static var previews: some View {
        NavigationView {
            Form {
                Section(header:Text(service.listViewSection.title)) {
                    LanguageAdminView(service: service)
                }
            }
        }
        .navigationViewStyle(.stack)
        .attachPreviewEnvironmentObjects()
    }
}
