//
//  LanguageSelectionAdminView.swift
//  LaibanApp
//
//  Created by Tomas Green on 2022-05-20.
//

import SwiftUI

import AVFoundation
import TextTranslator
import Speech
import Assistant

var availableIdentifiers:Set<String> = {
    return Set(Locale.availableIdentifiers)
}()
struct LanguageSelectionAdminView: View {
    @ObservedObject var service:LanguageService
    @EnvironmentObject var viewState:LBViewState
    @EnvironmentObject var assistant:Assistant
    @Environment(\.fullscreenContainerProperties) var properties
    @Environment(\.locale) var locale
    var currentLocales:[Locale] {
        let voices = AVSpeechSynthesisVoice.speechVoices().map { $0.language.replacingOccurrences(of: "-", with: "_")}
        let speech = SFSpeechRecognizer.supportedLocales().map { $0.identifier.replacingOccurrences(of: "-", with: "_")}
        let a1 = availableIdentifiers.intersection(voices)
        let a2 = availableIdentifiers.intersection(speech)
        let a3 = a1.intersection(a2)
        
        return Array(a3.map({ Locale(identifier: $0)})).sorted { $0.identifier < $1.identifier }
    }
    var languagesSelectionView: some View {
        LanguagesSelectionAdminView(service:service)
    }
    var body: some View {
        Form {
            NavigationLink(destination: languagesSelectionView) {
                Text("Lägg till språk")
            }.foregroundColor(.blue)
            
            Section(header: Text("Dina valda språk")) {
                ForEach(service.data.languages, id:\.identifier) { language in
                    let isSwedish = language.languageCode == "sv"
                    Text((language.flag ?? "🌍") + " " + (language.localizedDisplayName ?? "Okänt språk"))
                        .deleteDisabled(isSwedish)
                        .foregroundColor(Color(isSwedish ? .secondaryLabel : .label))
                }.onDelete { indexSet in
                    service.data.languages.remove(atOffsets: indexSet)
                }
            }
        }
        .navigationBarTitle("Språkstöd")
    }
}


struct LanguagesSelectionAdminView: View {
    @EnvironmentObject var viewState:LBViewState
    @EnvironmentObject var assistant:Assistant
    @Environment(\.fullscreenContainerProperties) var properties
    @Environment(\.locale) var locale
    @ObservedObject var service:LanguageService
    @State var locales:[Locale] = []
    @State var searchString:String = ""
    var filtered: [Locale] {
        if searchString.isEmpty {
            return locales
        }
        return locales.filter({
            $0.displayName?.lowercased().contains(searchString.lowercased()) == true ||
            $0.localizedDisplayName?.lowercased().contains(searchString.lowercased()) == true
        })
    }
    func updateLocales() {
        guard let loc = assistant.getAvailableLangaugeCodes(includeTTSService: true, includeSTTService: service.data.speechRecognizerEnabled, includeTextTranslation: true) else {
            return
        }
        let regex = try! NSRegularExpression(pattern: "[0-9]")
        let english = ["GB","US","AU","CA","NZ","IE","IN","KE","TZ","ZA"]
        var arr = [Locale]()
        for l in Locale.availableIdentifiers.map({ Locale(identifier: $0)}) {
            guard let code = l.languageCode else {
                continue
            }
            guard code != "sv" else {
                continue
            }
            guard let rc = l.regionCode else {
                continue
            }
            guard regex.firstMatch(in: rc, options: [], range: NSRange(location: 0, length: rc.utf16.count)) == nil else {
                continue
            }

            guard loc.contains(where: { $0 == code}) else {
                continue
            }
            if code == "en" {
                if english.contains(rc) && l.identifier.contains("POSIX") == false {
                    arr.append(l)
                }
            } else {
                arr.append(l)
            }
        }
        self.locales = arr.sorted(by: { $0.identifier < $1.identifier })
    }
    var root: some View {
        Form {
            ForEach(filtered, id:\.identifier) { locale in
                HStack {
                    Text((locale.flag ?? "🌍") + " " + (locale.localizedDisplayName ?? "Okänt språk"))
                    Spacer()
                    Button {
                        if service.data.languages.contains(locale) {
                            service.data.languages.removeAll { $0.identifier == locale.identifier }
                            service.save()
                        } else {
                            service.data.languages.append(locale)
                            service.save()
                        }
                    } label: {
                        if service.data.languages.contains(locale) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.red)
                        } else {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .onReceive(assistant.languageUpdatesAvailablePublisher) {
            updateLocales()
        }
        .onAppear {
            updateLocales()
        }
        .buttonStyle(.plain)
        .navigationBarTitle("Val av språk")
    }
    var body: some View {
        if #available(iOS 15.0, *) {
            root.searchable(text: $searchString, placement: .navigationBarDrawer(displayMode: .always), prompt: "Sök land eller språk")
        } else {
            root
        }
    }
}
struct LanguageSelectionAdminView_Previews: PreviewProvider {
    static var service = LanguageService()
    static var previews: some View {
        NavigationView {
            LanguageSelectionAdminView(service: service)
        }
        .navigationViewStyle(.stack)
        .attachPreviewEnvironmentObjects()
    }
}
