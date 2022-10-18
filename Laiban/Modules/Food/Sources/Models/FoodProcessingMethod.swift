//
//  FoodProcessor.swift
//
//  Created by Tomas Green on 2020-11-02.
//

import Foundation
import Combine
import UDPipe
import Analytics

public var cancellables = Set<AnyCancellable>()
public enum FoodProcessingMethod: String,CaseIterable,Identifiable,Hashable,Codable {
    public struct Result {
        let original:String
        let processed:String
    }
    public var id:String {
        return rawValue
    }
    case none
    case wordFilter
    case grammaticalAnalysis
    public var title:String {
        switch self {
        case .none: return "Ingen/Orginalbeskrivning"
        case .wordFilter: return "Filtrering av ord"
        case .grammaticalAnalysis: return "Grammatisk filtrering/analys"
        }
    }
    public func capitalizingFirstLetter(_ string:String) -> String {
        return string.prefix(1).capitalized + string.dropFirst()
    }
    public func process(_ strings:[String]) -> AnyPublisher<[Result],Never> {
        switch self {
        case .none: return Just(strings.map({ Result(original: $0, processed: $0)})).eraseToAnyPublisher()
        case .wordFilter: return Just(WordFilter.refine(strings: strings)).eraseToAnyPublisher()
        case .grammaticalAnalysis: break
        }
        let subject = PassthroughSubject<[Result],Never>()
        UDPipe.latest(language: "swedish", modelName: "lines").sink { model in
            model?.analyze(strings).sink(receiveCompletion: { completion in
                switch completion {
                case .failure: subject.send(strings.map({ Result(original: $0, processed: $0)}))
                case .finished: break
                }
            }, receiveValue: { response in
                var final = [Result]()
                response.forEach { r in
                    if let p = r.response  {
                        var sentence = [String]()
                        for a in p.components {
                            if a.uPosTag != "ADJ" && a.uPosTag != "ADV" && a.uPosTag != "VERB" {
                                sentence.append(a.form)
                            }
                        }
                        let p = capitalizingFirstLetter(sentence.joined(separator: " ").replacingOccurrences(of: " .", with: ".").replacingOccurrences(of: " ,", with: ","))
                        final.append(.init(original: r.original, processed: p))
                    } else {
                        final.append(.init(original: r.original, processed: r.original))
                    }
                }
                subject.send(final)
            }).store(in: &cancellables)
        }.store(in: &cancellables)
        
        return subject.eraseToAnyPublisher()
    }
}
fileprivate struct WordFilter {
    struct RawData {
        var title:String
        var date:Date
        var items:[String]
    }
    struct Rules : Codable {
        let nonVeg: [String]
        let banned: [String]
        let sides: [String]
        let other:[String]
        let meals: [RegexRule]
        let mains: [Rule]
        let deserts: [RegexRule]
        let replace: [RegexReplace]
        struct RegexRule : Codable {
            let regex:String
            let exclude:[String]
            let remove:[String]?
        }
        struct Rule : Codable {
            let name:String
            let exclude:[String]
        }
        struct RegexReplace : Codable {
            let match:String
            let replacement:String
        }
        struct TempObject {
            var meal:String
            var main:[String] = []
            var sides:[String] = []
            var deserts:[String] = []
            var other:[String] = []
            var concatenated:[String] {
                var arr = [String]()
                arr.append(contentsOf: main)
                arr.append(contentsOf: sides)
                arr.append(contentsOf: other)
                return arr
            }
        }
        func refineSentence(words:[String]) -> String {
            var words = words
            if words.count == 1 {
                return words.first!
            } else if words.count == 2 {
                return words.joined(separator: " med ")
            } else if words.count == 3 {
                let last = words.last!
                words.removeLast()
                return words.joined(separator: " med ") + " och " + last
            } else if words.count > 3 {
                let last = words.last!
                words.removeLast()
                return words.joined(separator: ", ") + " och " + last
            }
            return ""
        }
        func findMain(words:[String]) -> ([String],[String]) {
            var words = words
            var result = [String]()
            var remove = [String]()
            for word in words {
                for main in mains {
                    if !word.contains(main.name) {
                        continue
                    }
                    if result.contains(where: { s in s.contains(word)}) {
                        continue
                    }
                    if remove.contains(main.name) {
                        continue
                    }
                    remove.append(main.name)
                    result.append(word)
                }
            }
            if remove.count > 0 {
                words = words.filter({ word in
                    return remove.contains { r in !word.contains(r) }
                })
            }
            return (result,words)
        }
        func findSides(words:[String],main:[String]) -> ([String],[String]) {
            var words = words
            var result = [String]()
            var remove = [String]()
            for word in words {
                for side in sides {
                    if !word.contains(side) {
                        continue
                    }
                    if !result.contains(word) {
                        remove.append(side)
                        result.append(word)
                    }

                }
            }
            if remove.count > 0 {
                words = words.filter({ word in
                    return !remove.contains(word)
                })
            }
            return (result,words)
        }
        func findOther(words:[String],main:[String]) -> ([String],[String]) {
            var words = words
            var result = [String]()
            var remove = [String]()
            for word in words {
                for o in other {
                    if !word.contains(o) {
                        continue
                    }
                    if !result.contains(word) {
                        remove.append(o)
                        result.append(word)
                    }

                }
            }
            if remove.count > 0 {
                words = words.filter({ word in
                    return !remove.contains(word)
                })
            }
            return (result,words)
        }
        func refine(_ description:String) -> String {
            var string = description
            for i in replace {
                string = string.replacingOccurrences(of: i.match, with: i.replacement, options: [.regularExpression])
            }
            string = clean(string.lowercased())
            var words = createWordArray(string: string)
            words = removeBannend(words: words)
            var extractedMains = [String]()
            var extractedSides = [String]()
            var extractedOthers = [String]()
            (extractedMains,words) = findMain(words: words)
            (extractedSides,words) = findSides(words: words, main: extractedMains)
            (extractedOthers,words) = findOther(words: words, main: extractedMains)
            var obj = TempObject(meal: string)
            obj.main = extractedMains
            obj.sides = extractedSides
            obj.other = extractedOthers
            string = refineSentence(words: obj.concatenated)
            guard string.count > 0 else {
                return description
            }
            return string
        }
        func clean(_ string:String) -> String {
            var res = string.replacingOccurrences(of: #"(\W|-)"#, with: " ", options: [.regularExpression])
            res = res.replacingOccurrences(of: "[\\s\n]+", with: " ", options: [.regularExpression])
            return res
        }
        func createWordArray(string:String) -> [String] {
            return string.split(separator: " ").map { String($0) }
        }
        func removeBannend(words:[String]) -> [String] {
            var res = [String]()
            for word in words {
                if banned.contains(word) {
                    continue
                }
                res.append(word)
            }
            return res
        }
    }
    static func refine(strings:[String]) -> [FoodProcessingMethod.Result] {
        guard let rules = read() else {
            return strings.map { FoodProcessingMethod.Result(original: $0, processed: $0) }
        }
        return strings.map { FoodProcessingMethod.Result(original: $0, processed: rules.refine($0)) }
    }
    static func read() -> Rules? {
        let decoder = JSONDecoder()
        guard let url = Bundle.module.url(forResource: "Skolmaten", withExtension: "json") else {
            print("no rule definition")
            return nil
        }
        do {
            let data = try Data(contentsOf: url)
            return try decoder.decode(Rules.self, from: data)
        } catch {
            AnalyticsService.shared.logError(error)
            print(error)
        }
        return nil
    }
}
