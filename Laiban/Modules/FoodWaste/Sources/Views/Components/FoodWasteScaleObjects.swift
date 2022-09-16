//
//  BalanceScaleFoodObjects.swift
//
//  Created by Tomas Green on 2021-03-09.
//

import SwiftUI

struct FoodWasteScaleObjects: BalanceScaleObjects,Identifiable {
    var id:String {
        return image
    }
    var emoji: String
    var image: String
    var weight: Double
    var scaleFactor: CGFloat
    init(emoji:String,image:String,weight:Double,scaleFactor:CGFloat) {
        self.emoji = emoji
        self.image = image
        self.weight = weight
        self.scaleFactor = scaleFactor
    }
    static var `default`:[Self] {
        var arr = [FoodWasteScaleObjects]()
        arr.append(FoodWasteScaleObjects(emoji: "🍓", image: "ObjectStrawberry", weight: 25, scaleFactor: 0.4))
        arr.append(FoodWasteScaleObjects(emoji: "🍏", image: "ObjectApple", weight: 50, scaleFactor: 0.6))
        arr.append(FoodWasteScaleObjects(emoji: "🍞", image: "ObjectBread", weight: 50, scaleFactor: 0.55))
        arr.append(FoodWasteScaleObjects(emoji: "🥔", image: "ObjectPotato", weight: 75, scaleFactor: 0.6))
        arr.append(FoodWasteScaleObjects(emoji: "🥕", image: "ObjectCarrot", weight: 75, scaleFactor: 0.6))
        arr.append(FoodWasteScaleObjects(emoji: "🥝", image: "ObjectKiwi", weight: 100, scaleFactor:0.7))
        arr.append(FoodWasteScaleObjects(emoji: "🍊", image: "ObjectOrange", weight: 100, scaleFactor: 0.7))
        arr.append(FoodWasteScaleObjects(emoji: "🍌", image: "ObjectBanana", weight: 150, scaleFactor: 0.8))
        arr.append(FoodWasteScaleObjects(emoji: "🍈", image: "ObjectMelon", weight: 500, scaleFactor: 1.1))
        arr.append(FoodWasteScaleObjects(emoji: "🥩", image: "ObjectSteak", weight: 250, scaleFactor: 0.9))
        arr.append(FoodWasteScaleObjects(emoji: "🐟", image: "ObjectFish", weight: 250, scaleFactor: 0.9))
        arr.append(FoodWasteScaleObjects(emoji: "🍗", image: "ObjectChickenClub", weight: 250, scaleFactor: 0.9))
        return arr
    }
    static func convert(emoji:String) -> FoodWasteScaleObjects? {
        switch emoji {
        case "🍓" : return FoodWasteScaleObjects(emoji: "🍓", image: "ObjectStrawberry", weight: 25, scaleFactor: 0.4)
        case "🥔" : return FoodWasteScaleObjects(emoji: "🥔", image: "ObjectPotato", weight: 75, scaleFactor: 0.6)
        case "🍏" : return FoodWasteScaleObjects(emoji: "🍏", image: "ObjectApple", weight: 50, scaleFactor: 0.6)
        case "🥝" : return FoodWasteScaleObjects(emoji: "🥝", image: "ObjectKiwi", weight: 100, scaleFactor:0.7)
        case "🍊" : return FoodWasteScaleObjects(emoji: "🍊", image: "ObjectOrange", weight: 100, scaleFactor: 0.7)
        case "🍌" : return FoodWasteScaleObjects(emoji: "🍌", image: "ObjectBanana", weight: 150, scaleFactor: 0.8)
        case "🍈" : return FoodWasteScaleObjects(emoji: "🍈", image: "ObjectMelon", weight: 500, scaleFactor: 1.1)
        case "🥩" : return FoodWasteScaleObjects(emoji: "🥩", image: "ObjectSteak", weight: 250, scaleFactor: 0.9)
        case "🐟" : return FoodWasteScaleObjects(emoji: "🐟", image: "ObjectFish", weight: 250, scaleFactor: 0.9)
        case "🍗" : return FoodWasteScaleObjects(emoji: "🍗", image: "ObjectChickenClub", weight: 250, scaleFactor: 0.9)
        case "🦐" : return FoodWasteScaleObjects(emoji: "🦐", image: "ObjectShrimp", weight: 10, scaleFactor: 0.4)
        case "🍞" : return FoodWasteScaleObjects(emoji: "🍞", image: "ObjectBread", weight: 50, scaleFactor: 0.55)
        case "🥕" : return FoodWasteScaleObjects(emoji: "🥕", image: "ObjectCarrot", weight: 75, scaleFactor: 0.6)
        default: return nil
        }
    }
    static func convert(emoji:Character) -> FoodWasteScaleObjects? {
        return convert(emoji: String(emoji))
    }
    static func convert(emojis:String) -> [FoodWasteScaleObjects] {
        var arr = [FoodWasteScaleObjects]()
        emojis.forEach { c in
            if let o = convert(emoji: c) {
                arr.append(o)
            }
        }
        return arr
    }
}
