//
//  Created by Tomas Green on 2022-05-19.
//

import Foundation
import TTS
import TextTranslator
import SwiftUI

public struct LanguageServiceModel: Codable {
    public var languages:[Locale] = [Locale(identifier: "sv_SE")]
    public var speechRecognizerEnabled:Bool = false
    public var voiceCancellable:Bool = false
    public var ttsGender:TTSGender = .other
    public var ttsPitch:Double = 1
    public var ttsRate:Double = 0.8
}

public extension Locale {
    var direction: LayoutDirection {
        if NSLocale.characterDirection(forLanguage: identifier) == .rightToLeft {
            return .rightToLeft
        }
        if NSLocale.characterDirection(forLanguage: identifier) == .leftToRight {
            return .leftToRight
        }
        return .leftToRight
    }
    var localizedDisplayName: String? {
        return (Locale.current as NSLocale).displayName(forKey: .identifier, value: identifier)?.capitalizingFirstLetter()
    }
    var localizedLanguageName: String? {
        guard let code = languageCode else {
            return nil
        }
        return (Locale.current as NSLocale).displayName(forKey: .languageCode, value: code)?.capitalizingFirstLetter()
    }
    var localizedCountryName: String? {
        guard let code = regionCode else {
            return nil
        }
        return (Locale.current as NSLocale).displayName(forKey: .countryCode, value: code)?.capitalizingFirstLetter()
    }
    var displayName: String? {
        return (self as NSLocale).displayName(forKey: .identifier, value: identifier)?.capitalizingFirstLetter()
    }
    var languageName: String? {
        guard let code = languageCode else {
            return nil
        }
        return (self as NSLocale).displayName(forKey: .languageCode, value: code)?.capitalizingFirstLetter()
    }
    var countryName: String? {
        guard let region = regionCode else {
            return nil
        }
        return (self as NSLocale).displayName(forKey: .countryCode, value: region)?.capitalizingFirstLetter()
    }
    var flag:String? {
        guard let region = regionCode else {
            return nil
        }
        if region.range(of: #"[0-9]"#,options: .regularExpression) != nil {
            return "🗺"
        }
        let base : UInt32 = 127397
        var s = ""
        for v in region.unicodeScalars {
            s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
        }
        return String(s)
    }
    func displayName(in locale:Locale) -> String? {
        return (locale as NSLocale).displayName(forKey: .identifier, value: identifier)?.capitalizingFirstLetter()
    }
    func languageName(in locale:Locale) -> String? {
        guard let code = languageCode else {
            return nil
        }
        return (locale as NSLocale).displayName(forKey: .languageCode, value: code)?.capitalizingFirstLetter()
    }
}
