import UIKit

public struct TextAutoCorrector {
    public var ignoredWords = [Locale:[String]]()
    public init(ignore words:[Locale:[String]]) {
        ignoredWords = words
    }
    func clean(_ string:String) -> String {
        return string.replacingOccurrences(of: "\\s?\\([\\w\\s]*\\)", with: "", options: .regularExpression)
    }
    func removeTags(_ string:String) -> String {
        return string.replacingOccurrences(of: "^.*:", with: "", options: .regularExpression)
    }
    func fixComma(_ string:String) -> String {
        return string.split(separator: ",").map { s in String(s).trimmingCharacters(in: .whitespacesAndNewlines)}.joined(separator: ", ")
    }
    func split(sentenses: String) -> [String] {
        return sentenses.split(separator: ".").map { s in String(s).trimmingCharacters(in: .whitespacesAndNewlines)}
    }
    public func correct(word: String, locale:Locale = Locale.current) -> String {
        let checker = UITextChecker()
        checker.ignoredWords = ignoredWords[locale]
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: locale.identifier)
        guard misspelledRange.location != NSNotFound else {
            return word
        }
        guard let guesses =  checker.guesses(forWordRange: misspelledRange, in: word, language: locale.identifier) else {
            return word
        }
        return guesses.first ?? word
    }
    public func correct(sentense: String, locale:Locale = Locale.current) -> String {
        var sentense = sentense
        sentense = clean(sentense)
        sentense = removeTags(sentense)
        sentense = fixComma(sentense)
        sentense = sentense.trimmingCharacters(in: .whitespacesAndNewlines)
        let words = sentense.split(separator: " ").map { s  in String(s) }
        var new = [String]()
        for (index,word) in words.enumerated() {
            let w = correct(word: word, locale: locale)
            if index == 0 {
                new.append(w.capitalized)
            } else if index == words.count - 1 {
                if w.contains(".") {
                    new.append(w)
                } else {
                    new.append(w + ".")
                }
            } else {
                new.append(w)
            }
        }
        return new.joined(separator: " ")
    }
    public func correct(text: String, locale:Locale = Locale.current) -> String {
        let sentenses = split(sentenses: text)
        var new = [String]()
        for sentense in sentenses {
            new.append(correct(sentense: sentense, locale: locale))
        }
        return new.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
