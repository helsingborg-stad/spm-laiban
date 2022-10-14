//
//  LanguageSelectionView.swift
//
//  Created by Tomas Green on 2020-03-17.
//

import SwiftUI
import Assistant
import Analytics

public struct LanguageSelectionView: View {
    @EnvironmentObject var viewState:LBViewState
    @EnvironmentObject var assistant:Assistant
    @Environment(\.fullscreenContainerProperties) var properties
    @Environment(\.locale) var locale
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @ObservedObject var service:LanguageService
    func string(from locale:Locale) -> String {
        if locale.languageCode == "sv" {
            return locale.localizedLanguageName ?? "Okänt språk"
        }
        guard let native = locale.languageName(in: locale) else {
            return "Okänt språk"
        }
        guard let local = locale.languageName(in: Locale(identifier:"sv_SE")) else {
            return "Okänt språk"
        }
        return local + " / " + native
    }
    var currentLocale:Locale
    var onSelectLanguage: (Locale?) -> Void
    public init(service:LanguageService, currentLocale:Locale,onSelectLanguage: @escaping (Locale?) -> Void) {
        self.service = service
        self.currentLocale = currentLocale
        self.onSelectLanguage = onSelectLanguage
    }
    public var body: some View {
        VStack(spacing: properties.spacing[.xs]) {
            Text(LocalizedStringKey("language_choose"), bundle: LBBundle)
                .padding(.bottom, properties.spacing[.m])
                .frame(maxWidth: .infinity)
                .font(properties.font, ofSize: .n, weight: .heavy)
            ForEach(service.data.languages, id: \.self) { language in
                Button(action: {
                    onSelectLanguage(language)
                    AnalyticsService.shared.log("LanguageChanged", properties: ["Language": "\(language.identifier)"])
                }) {
                    HStack(spacing: properties.spacing[.m]) {
                        Text(self.string(from: language))
                        Spacer()
                        Text(language.flag ?? "🌍").font(Font.system(size: self.horizontalSizeClass == .regular ? 40 : 30))
                    }
                    .font(properties.font, ofSize: .n, weight: .semibold)
                    .frame(alignment: .leading)
                    .padding(.vertical, properties.spacing[.xs])
                    .padding(.horizontal, properties.spacing[.m])
                }
                .buttonStyle(LBPrimaryButtonStyle())
            }
        }
        .padding(properties.spacing[.m])
        .wrap(scrollable:true, overlay: .emoji(currentLocale.flag ?? "🌍", .gray))
        .transition(.opacity.combined(with: .scale))
        .onAppear {
            viewState.inactivityTimerDisabled(true, for: .languages)
            viewState.actionButtons([.back], for: .languages)
            AnalyticsService.shared.logPageView(self)
        }
    }
}
