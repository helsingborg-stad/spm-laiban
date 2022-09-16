//
//  Recreation.swift
//
//  Created by Tomas Green on 2020-09-10.
//

import Foundation
import Combine

import Assistant

struct Recreation : Codable {
    var activities:[Activity] = []
    var inventories:[Inventory] = []
    struct Inventory : Codable,Identifiable {
        var id:String = UUID().uuidString
        var name:String
        var items:[Item]
        struct Item : Codable, Identifiable {
            static let imageStorage = LBImageStorage(folder: "recreationObject")
            var id:String = UUID().uuidString
            var prefix:String
            var name:String
            var imageName:String?
            var emoji:String?
            init(id:String = UUID().uuidString, prefix: String = "", name:String = "", imageName:String? = nil, emoji:String? = nil) {
                self.id = id
                self.prefix = prefix
                self.name = name
                self.imageName = imageName
                self.emoji = emoji
            }

            func itemDescription() -> String {
                if prefix.count > 0 {
                    return prefix + " " + name
                }
                
                return name
            }
        }
    }
    struct Activity : Codable,Identifiable {
        var id:String = UUID().uuidString
        var name:String
        var sentence:String
        var objectSentence:String? = nil
        var emoji:String
        var inventories:[String] = []

        func activityDescription(hasObject: Bool, using assistant:Assistant) -> String {
            var result = assistant.string(forKey: sentence)
            if hasObject, let objectSentence = objectSentence {
                result += " " + assistant.string(forKey: objectSentence)
            }
            return result
        }
    }
    static var standard:Recreation {
        var recreation = Recreation()
        var activities = [Activity]()
        let songs = Inventory(id: "songs", name: "Sånger", items: [])
        let misc = Inventory(id: "misc", name: "Diverse", items: [
            .init(id: "rainbow", prefix: "en", name: "regnbåge", emoji: "🌈"),
            .init(id: "house", prefix: "ett", name: "hus", emoji: "🏡"),
            .init(id: "car", prefix: "en", name: "bil", emoji: "🚗"),
            .init(id: "airplane", prefix: "ett", name: "flygplan", emoji: "✈️"),
            .init(id: "boat", prefix: "en", name: "båt", emoji: "⛵️"),
            .init(id: "helicopter", prefix: "en", name: "helikopter", emoji: "🚁"),
            .init(id: "tree", prefix: "ett", name: "träd", emoji: "🌳"),
            .init(id: "playground", prefix: "en", name: "lekplats", emoji: "🧗‍♂️"),
            
        ])
        let animals = Inventory(id: "animals", name: "Djur", items: [
            .init(id: "elephant", prefix: "en", name: "elefant", emoji: "🐘"),
            .init(id: "cow", prefix: "en", name: "kossa", emoji: "🐄"),
            .init(id: "pig", prefix: "en", name: "gris", emoji: "🐖"),
            .init(id: "vildsvin", prefix: "ett", name: "vildsvin", emoji: "🐗"),
            .init(id: "ape", prefix: "en", name: "apa", emoji: "🐒"),
            .init(id: "fox", prefix: "en", name: "räv", emoji: "🦊"),
            .init(id: "lion", prefix: "ett", name: "lejon", emoji: "🦁"),
            .init(id: "frog", prefix: "en", name: "groda", emoji: "🐸"),
            .init(id: "lizzard", prefix: "en", name: "ödla", emoji: "🦎"),
            .init(id: "owl", prefix: "en", name: "ugla", emoji: "🦉"),
            .init(id: "fish", prefix: "en", name: "fisk", emoji: "🐠"),
            .init(id: "panda", prefix: "en", name: "panda", emoji: "🐼"),
            .init(id: "giraffe", prefix: "en", name: "giraff", emoji: "🦒"),
            .init(id: "gorilla", prefix: "en", name: "gorilla", emoji: "🦍"),
            .init(id: "cat", prefix: "en", name: "katt", emoji: "🐈"),
            .init(id: "hund", prefix: "en", name: "hund", emoji: "🐕"),
            .init(id: "horse", prefix: "en", name: "häst", emoji: "🐎"),
            .init(id: "llama", prefix: "en", name: "lama", emoji: "🦙")
        ])
        recreation.inventories = [songs,misc,animals]
        activities.append(Activity(id: "singing", name: "Sjunga", sentence: "Gå till någon bra plats för att dansa och sjunga med en eller flera kompisar.",objectSentence: "Till kan till exempel sjunga...", emoji: "🎤", inventories: ["songs"]))
        activities.append(Activity(id: "puzzleSolving", name: "Pussel", sentence: "Gå och lägg ett pussel.", objectSentence: "Till exempel...", emoji: "🧩"))
        activities.append(Activity(id: "games", name: "Spel", sentence: "Gå och spela ett spel tillsammans med en kompis.", objectSentence: "Till exempel kan ni spela...", emoji: "🎲"))
        activities.append(Activity(id: "listen", name: "Spel", sentence: "Gå och hämta en iPad med en kompis och lyssna på en saga.", objectSentence: "Ni kan till exempel lyssna på...", emoji: "🎧"))
        activities.append(Activity(id: "read", name: "Läsa", sentence: "Gå och hämta en bok tillsammans med en kompis och prata om bilderna.", objectSentence: "Ni kan till exempel titta i...", emoji: "📚"))
        activities.append(Activity(id: "trace", name: "Kalkera", sentence: "Gå och hämta en iPad och be en vuxen om hjälp för att kalkera av ett djur.", objectSentence: "Till exempel...", emoji: "✏️"))
        activities.append(Activity(id: "painting", name: "Måla", sentence: "Gå till ateljén och måla.", objectSentence: "Försök att måla...", emoji: "🎨", inventories: ["misc","animals"]))
        activities.append(Activity(id: "drawing", name: "Draw", sentence: "Gå till ateljén tillsammans med en kompis och rita.", objectSentence: "Ni kanske kan rita...", emoji: "🎨", inventories: ["misc","animals"]))
        activities.append(Activity(id: "legoBuilding", name: "Lego", sentence: "Gå till legot och bygg.", objectSentence: "Testa att bygga...", emoji: "🏗", inventories: ["misc"]))
        activities.append(Activity(id: "building", name: "Bygga", sentence: "Gå till byggrummet tillsammans med en kompis och bygg ett så högt torn som möjligt.", emoji: "🗼"))
        activities.append(Activity(id: "movie", name: "Skapa film", sentence: "Hämta en iPad och gå till fantasirummet och skapa en film tillsammans med en kompis.", emoji: "🎬"))
        activities.append(Activity(id: "create", name: "Skapa", sentence: "Gå till ateljén och skapa med lim och annat material.", emoji: "✂️"))
        activities.append(Activity(id: "clay", name: "Lera", sentence: "Gå till något bra bord och skapa med lera.", objectSentence: "Försök göra...", emoji: "🤔", inventories: ["misc","animals"]))
        activities.append(Activity(id: "enlarge", name: "Förstora", sentence: "Gå och hämta en iPad och förstora saker så du kan undersöka dem nära.", emoji: "🔍"))
        recreation.activities = activities
        return recreation
    }
}
/*
 - ett gui för att hantera aktiviter
 - ett gui för att hantera inventory
 - ett gui för att hantera objekt
 
 */
