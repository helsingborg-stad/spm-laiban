//
//  FoodWasteManager.swift
//
//  Created by Tomas Green on 2021-03-04.
//

import Foundation
import Combine

public class FoodWasteManager : ObservableObject {
    public struct FoodWaste: Codable,Hashable,Identifiable {
        public var id:String {
            return date
        }
        public var date:String
        public var waste:Double
        public var reported:Bool = false
        public var numEating:Int = 0
        public var emojis:String = ""
        public init(waste:Double,date:Date = Date(), numEating:Int) {
            let f = DateFormatter()
            f.dateFormat = "yyyy-MM-dd"
            self.date = f.string(from: date)
            self.numEating = numEating
            self.waste = waste
        }
        public init(waste:Double,date:String, numEating:Int, emojis:String = "") {
            self.date = date
            self.waste = waste
            self.numEating = numEating
            self.emojis = emojis
        }
        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            self.date = try values.decode(String.self, forKey: .date)
            self.waste = try values.decode(Double.self, forKey: .waste)
            self.reported = (try? values.decode(Bool.self, forKey: .reported)) ?? false
            self.numEating = (try? values.decode(Int.self, forKey: .numEating)) ?? 0
            self.emojis = try values.decode(String.self, forKey: .emojis)
        }
    }
    private static let userDefaultsKey = "FoodWasteStatistics"
    private var values:[String:FoodWaste]
    private var reportInProgress = false
    @Published public private(set) var array:[FoodWaste]
    public init() {
        let vals = Self.load()
        self.values = vals
        var arr = [FoodWaste]()
        vals.forEach { key, value in
            arr.append(value)
        }
        self.array = arr.sorted(by: { $0.date > $1.date })
    }
    public func getWeeklyWaste(for date:Date = Date()) -> Double {
        guard var start = date.startOfWeek else {
            return 0
        }
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        var waste:Double = 0
        for _ in 0..<5 {
            if let w = values[f.string(from: start)]?.waste {
                waste += w
            }
            start = start.tomorrow!
        }
        return waste
    }
    public func getWeeklyAverage(for date:Date = Date()) -> Double {
        guard var start = date.startOfWeek else {
            return 0
        }
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        var waste:Double = 0
        var num = 0
        for _ in 0..<5 {
            if let w = values[f.string(from: start)]?.waste {
                num += 1
                waste += w
            }
            start = start.tomorrow!
        }
        if num > 0 {
            return waste/Double(num)
        }
        return waste
    }
    public func getWeeklyHigh(for date:Date = Date()) -> Double {
        guard var start = date.startOfWeek else {
            return 0
        }
        var most:Double = 0
        for _ in 0..<5 {
            if let w = waste(for: date) {
                if w.waste > most {
                    most = w.waste
                }
            }
            start = start.tomorrow!
        }
        
        return most
    }
    public func wasteCompared(to date:Date = Date()) -> ComparisonResult? {
        guard let y = date.yesterDay, let yesterday = waste(for: y) else {
            return nil
        }
        guard let today = waste(for: date) else {
            return nil
        }
        if today.waste == yesterday.waste {
            return ComparisonResult.orderedSame
        }
        if today.waste < yesterday.waste {
            return ComparisonResult.orderedDescending
        }
        return ComparisonResult.orderedAscending
    }
    public func waste(for date:Date = Date()) -> FoodWaste? {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        let key = f.string(from: date)
        return values[key]
    }
    public func isBalanced(for date:Date = Date()) -> Bool {
        guard  let w = waste(for: date) else {
            return false
        }
        return w.waste > 0 && w.emojis.count > 0
    }
    public func clean() {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        for a in array {
            guard a.reported else {
                continue
            }
            guard let d = f.date(from: a.date) else {
                continue
            }
            guard d < Date().addingTimeInterval(60 * 60 * 24 * -14) else {
                continue
            }
            values.removeValue(forKey: a.date)
        }
        updateArray()
    }
    public func add(value:Double,numEating:Int = 0 ,for date:Date = Date()) {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        let key = f.string(from: date)
        let w = FoodWaste(waste: value, date:date, numEating: numEating)
        values[key] = w
        updateArray()
        save()
    }
    private func updateArray() {
        var arr = [FoodWaste]()
        values.forEach { _, value in
            arr.append(value)
        }
        self.array = arr.sorted(by: { $0.date > $1.date })
    }
    public func update(waste:FoodWaste) {
        values[waste.date] = waste
        updateArray()
        save()
    }
    public func update(waste:[FoodWaste]) {
        for w in waste {
            values[w.date] = w
        }
        updateArray()
        clean()
        save()
    }
    public func remove(atOffsets offsets: IndexSet) {
        offsets.forEach { i in
            values.removeValue(forKey: array[i].date)
        }
        array.remove(atOffsets: offsets)
        self.save()
    }
    public func save() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(values) {
            UserDefaults.standard.set(encoded, forKey: Self.userDefaultsKey)
            print("ℹ️ [\(#fileID):\(#function):\(#line)] " + String(describing: "FoodWaste saved"))
        }
    }
    public static var dummyData:[String:FoodWaste] {
        var dict = [String:FoodWaste]()
        dict["2021-03-08"] = FoodWaste(waste: 143, date: "2021-03-08", numEating: 10, emojis: "🍏🍏")
        dict["2021-03-09"] = FoodWaste(waste: 195, date: "2021-03-09", numEating: 10, emojis: "🍏🍏🍊")
        dict["2021-03-10"] = FoodWaste(waste: 521, date: "2021-03-10", numEating: 10, emojis: "🍈")
        dict["2021-03-11"] = FoodWaste(waste: 120, date: "2021-03-11", numEating: 10, emojis: "🍏🍏")
        dict["2021-03-12"] = FoodWaste(waste: 110, date: "2021-03-12", numEating: 10, emojis: "🍏🍏")

        dict["2021-03-15"] = FoodWaste(waste: 120, date: "2021-03-15", numEating: 10, emojis: "🍏🍏")
        dict["2021-03-16"] = FoodWaste(waste: 234, date: "2021-03-16", numEating: 10, emojis: "🍏🍏🍏🍊")
        dict["2021-03-17"] = FoodWaste(waste: 111, date: "2021-03-17", numEating: 10, emojis: "🍏🍏")
        return dict
    }
    public static func delete() {
        UserDefaults.standard.removeObject(forKey: Self.userDefaultsKey)
        print("ℹ️ [\(#fileID):\(#function):\(#line)] " + String(describing: "FoodWaste deleted"))
    }
    public static func load() -> [String:FoodWaste] {
        if let data = UserDefaults.standard.object(forKey: Self.userDefaultsKey) as? Data {
            let decoder = JSONDecoder()
            do {
                return try decoder.decode([String:FoodWaste].self, from: data)
            } catch {
                print("⛔️ [\(#fileID):\(#function):\(#line)] " + String(describing: error))
            }
        }
        return [:]
    }
}
