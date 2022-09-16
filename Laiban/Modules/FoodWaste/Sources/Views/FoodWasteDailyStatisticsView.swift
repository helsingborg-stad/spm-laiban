//
//  FoodWasteDailyStatisticsView.swift
//
//  Created by Tomas Green on 2021-03-10.
//

import SwiftUI

import Assistant

struct FoodWasteDailyStatisticsItemView: View {
    @EnvironmentObject var viewState:LBViewState
    @EnvironmentObject var assistant:Assistant
    @Environment(\.fullscreenContainerProperties) var properties
    @Environment(\.locale) var locale
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var item:FoodWasteDailyStatisticsView.Item
    var size:CGFloat = 70
    var emojis:String {
        var s = ""
        for _ in 0..<item.count {
            s += item.emoji
        }
        return s
    }
    var abc:CGFloat {
        horizontalSizeClass == .compact ? 0.6 : 1
    }
    var body: some View {
        VStack(spacing: 10) {
            Text(emojis)
                .font(.system(size: size * properties.windowRatio * item.scaleFactor * abc) )
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.4)
            Text(item.title(using: assistant))
                .font(properties.font,ofSize:.n)
        }
        .frame(maxWidth:.infinity)
        .padding(horizontalSizeClass != .compact ? 20 : 8)
    }
}

struct FoodWasteDailyStatisticsView: View {
    @Environment(\.fullscreenContainerProperties) var properties
    @Environment(\.locale) var locale
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject var assistant:Assistant
    @EnvironmentObject var viewState:LBViewState
    
    struct Item: Identifiable {
        var id:String {
            return emoji
        }
        var emoji:String
        var scaleFactor:CGFloat
        var count:Int
        func title(using assistant:Assistant) -> String {
            let s = unicode(from: emoji)
            if count == 0 || count > 1 {
                let str = assistant.string(forKey: "emoji_\(s)_name_plural")
                return "\(count) \(str.lowercased())"
            }
            let str = assistant.string(forKey: "emoji_\(s)_name")
            return "\(count) \(str.lowercased())"
        }
        private func unicode(from emoji:String) -> String {
            let uni = emoji.unicodeScalars
            let unicode = uni[uni.startIndex].value
            return String(unicode, radix: 16, uppercase: true)
        }
        static func convert(objects:[BalanceScaleView.ViewModel.Item]) -> [Self] {
            var emojis = [String:Int]()
            var scaleFactor = [String:CGFloat]()
            objects.forEach { item in
                if emojis[item.emoji] == nil {
                    scaleFactor[item.emoji] = item.scaleFactor
                    emojis[item.emoji] = 1
                } else {
                    emojis[item.emoji] = 1 + emojis[item.emoji]!
                }
            }
            var items = [Item]()
            emojis.forEach { key, value in
                let s = scaleFactor[key]!
                let c = emojis[key]!
                items.append(.init(emoji: key, scaleFactor: s, count: c))
            }
            return items.sorted { s1, s2 in
                s1.emoji < s2.emoji
            }
        }
        static func convert(emojis:String) -> [Self] {
            var arr = [BalanceScaleView.ViewModel.Item]()
            emojis.forEach { emoji in
                if let object = FoodWasteScaleObjects.convert(emoji: emoji) {
                    arr.append(BalanceScaleView.ViewModel.Item(object: object))
                }
            }
            return convert(objects: arr)
        }
        static func convert(waste:FoodWasteManager.FoodWaste) -> [Self] {
            var arr = [BalanceScaleView.ViewModel.Item]()
            waste.emojis.forEach { emoji in
                if let object = FoodWasteScaleObjects.convert(emoji: emoji) {
                    arr.append(BalanceScaleView.ViewModel.Item(object: object))
                }
            }
            return convert(objects: arr)
        }
    }
    var title:String {
        let str:String
        let a = Int(Date().timeIntervalSince(date) / 60 / 60 / 24)
        if a == 0 {
            str = "food_waste_statistics_title_today"
        } else if a == 1 {
            str = "food_waste_statistics_title_yesterday"
        } else {
            str = "food_waste_statistics_title_weekday_\(date.actualWeekDay)"
        }
        return assistant.formattedString(forKey: str, String(Int(foodWaste)))
    }
    var foodWaste:Double
    var items:[Item]
    var date:Date
    var infoTitle:String? = nil
    var infoDescription:String? = nil
    var infoEmoji:String? = nil
    var body: some View {
        contentView
    }
    var contentView: some View {
        let columns = items.count > 4 ? 3 : 2
        let size:CGFloat = items.count > 4 ? 90 : 100
        let h = horizontalSizeClass == .regular ? properties.windowSize.height * 0.4 : properties.windowSize.height * 0.3
        return VStack(spacing: 20) {
            Text(title)
                .font(properties.font, ofSize: .n)
                .multilineTextAlignment(.center)
                .padding(.top,10)
            LBGridView(items: items.count, columns: columns,verticalAlignment:.bottom) { index in
                let item = items[index]
                FoodWasteDailyStatisticsItemView(item: item, size:size)
            }
            .frame(minHeight:h)
            .background(Color.white)
            .cornerRadius(36)
            .shadow(color: Color.black.opacity(0.2), radius: 7, x: 0, y: 0)
            Button {
                assistant.speak([
                    infoTitle ?? assistant.string(forKey: "food_waste_info_why"),
                    infoDescription ?? assistant.string(forKey: "food_waste_info_why_description")
                ])
            } label: {
                informationView
            }
        }.frame(maxWidth:.infinity,maxHeight: .infinity,alignment: .top)
    }
    var informationView: some View {
        HStack(alignment:.top,spacing: 20) {
            if horizontalSizeClass == .regular {
                Text(infoEmoji ?? "💡").font(.system(size: 50))
            }
            VStack(alignment:.leading) {
                Text(infoTitle ?? assistant.string(forKey: "food_waste_info_why"))
                    .font(properties.font, ofSize: .n,weight:.bold)
                Text(infoDescription ?? assistant.string(forKey: "food_waste_info_why_description"))
                    .font(properties.font, ofSize: .n,weight:.regular)
            }.lineLimit(nil)
        }
        .padding(30)
        .frame(maxWidth:.infinity,alignment: .leading)
        .secondaryContainerBackground()
        .padding([.leading,.trailing,.top])
    }
}

//struct FoodWasteDailyStatisticsView_Previews: PreviewProvider {
//    static var items:[FoodWasteDailyStatisticsView.Item] {
//        let arr = FoodWasteScaleObjects.default
//        
//        return [
//            .init(emoji: arr[0].emoji, scaleFactor: arr[0].scaleFactor, count: 15),
//            .init(emoji: arr[1].emoji, scaleFactor: arr[1].scaleFactor, count: 3),
//            .init(emoji: arr[2].emoji, scaleFactor: arr[2].scaleFactor, count: 10),
//            .init(emoji: arr[3].emoji, scaleFactor: arr[3].scaleFactor, count: 3),
//            .init(emoji: arr[4].emoji, scaleFactor: arr[4].scaleFactor, count: 3),
//            .init(emoji: arr[5].emoji, scaleFactor: arr[5].scaleFactor, count: 3),
//            .init(emoji: arr[6].emoji, scaleFactor: arr[6].scaleFactor, count: 1),
//            .init(emoji: arr[7].emoji, scaleFactor: arr[7].scaleFactor, count: 3),
//            .init(emoji: arr[8].emoji, scaleFactor: arr[8].scaleFactor, count: 3)
//        ]
//    }
//    static var previews: some View {
//        let m = ViewManager(nil)
//        FullscreenBubbleContainer(manager: m) { containerProxy in
//            FoodWasteDailyStatisticsView(manager: m, foodWaste: 1250, items: items,date:Date())
//        }.environmentObject(Localization(.swedish))
//    }
//}
