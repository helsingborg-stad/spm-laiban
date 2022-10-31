//
//  MovementManager.swift
//  
//
//  Created by Fredrik Häggbom on 2022-10-27.
//

import Foundation
import Combine

public class MovementManager : ObservableObject {
    public struct Movement: Codable,Hashable,Identifiable {
        public var id:String {
            return date
        }
        public var date:String
        public var minutes:Int
        public var reported:Bool = false
        public var numMoving:Int = 0
        public var emojis:String = ""
        public init(minutes:Int,date:Date = Date(), numMoving:Int) {
            let f = DateFormatter()
            f.dateFormat = "yyyy-MM-dd"
            self.date = f.string(from: date)
            self.numMoving = numMoving
            self.minutes = minutes
        }
        public init(minutes:Int,date:String, numMoving:Int, emojis:String = "") {
            self.date = date
            self.minutes = minutes
            self.numMoving = numMoving
            self.emojis = emojis
        }
        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            self.date = try values.decode(String.self, forKey: .date)
            self.minutes = try values.decode(Int.self, forKey: .minutes)
            self.reported = (try? values.decode(Bool.self, forKey: .reported)) ?? false
            self.numMoving = (try? values.decode(Int.self, forKey: .numMoving)) ?? 0
            self.emojis = try values.decode(String.self, forKey: .emojis)
        }
    }
    private static let userDefaultsKey = "MovementStatistics"
    private var reportInProgress = false
    public var delegate: MovementStorage? {
        didSet {
            updateData()
        }
    }
    @Published public private(set) var array:[Movement]
    public init() {
        self.array = [Movement]()
    }
    
    public func updateData(newData: [Movement]? = nil) {
        if let newData = newData {
            self.array = newData
        } else if let vals = delegate?.getData() {
            self.array = vals
        }
        self.updateArray()
    }
    public func getWeeklyMovement(for date:Date = Date()) -> Int {
        guard var start = date.startOfWeek else {
            return 0
        }
        var minutes:Int = 0
        for _ in 0..<5 {
            if let w = array.first { $0.date == start.laibanFormattedString }?.minutes {
                minutes += w
            }
            start = start.tomorrow!
        }
        return minutes
    }
    public func getWeeklyAverage(for date:Date = Date()) -> Double {
        guard var start = date.startOfWeek else {
            return 0
        }
        var minutes:Int = 0
        var num = 0
        for _ in 0..<5 {
            if let w = array.first { $0.date == start.laibanFormattedString }?.minutes {
                num += 1
                minutes += w
            }
            start = start.tomorrow!
        }
        if num > 0 {
            return Double(minutes)/Double(num)
        }
        return Double(minutes)
    }
    public func getWeeklyHigh(for date:Date = Date()) -> Int {
        guard var start = date.startOfWeek else {
            return 0
        }
        var most:Int = 0
        for _ in 0..<5 {
            if let w = movement(for: date) {
                let total = w.map { $0.minutes }.reduce(0, +)
                if total > most {
                    most = total
                }
            }
            start = start.tomorrow!
        }
        
        return most
    }
    
    public func movement(for date:Date = Date()) -> [Movement]? {
        print("arr dates: \(array.map {$0.date}.joined(separator: ", "))")
        print("date: \(date.laibanFormattedString)")
        print("arr: \(array)")
        return array.filter { $0.date == date.laibanFormattedString }
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
            array.removeAll(where: {$0.id == a.id})
        }
        updateArray()
    }
    public func add(value:Int,numMoving:Int = 0 ,for date:Date = Date()) {
        let w = Movement(minutes: value, date:date, numMoving: numMoving)
        self.array.append(w)
        updateArray()
        save()
    }
    private func updateArray() {
        self.array = self.array.sorted(by: { $0.date > $1.date })
    }
    public func update(movement:Movement) {
        self.array.removeAll { $0.id ==  movement.id }
        self.array.append(movement)
        updateArray()
        save()
    }
    public func update(movement:[Movement]) {
        for w in movement {
            self.array.removeAll { $0.id ==  w.id }
            self.array.append(w)
        }
        updateArray()
        clean()
        save()
    }
    public func remove(atOffsets offsets: IndexSet) {
        array.remove(atOffsets: offsets)
        save()
    }
    public func save() {
        delegate?.save(movements: self.array)
    }
    public static var dummyData:[Movement] {
        var array = [Movement]()
        array.append(Movement(minutes: 143, date: "2021-03-08", numMoving: 10, emojis: "🏃‍♀️"))
        array.append(Movement(minutes: 195, date: "2021-03-09", numMoving: 10, emojis: "🏃‍♀️"))
        array.append(Movement(minutes: 521, date: "2021-03-10", numMoving: 10, emojis: "🏃‍♀️"))
        array.append(Movement(minutes: 120, date: "2021-03-11", numMoving: 10, emojis: "🏃‍♀️"))
        array.append(Movement(minutes: 110, date: "2021-03-12", numMoving: 10, emojis: "🏃‍♀️"))

        array.append(Movement(minutes: 120, date: "2021-03-15", numMoving: 10, emojis: "🏃‍♀️"))
        array.append(Movement(minutes: 234, date: "2021-03-16", numMoving: 10, emojis: "🏃‍♀️"))
        array.append(Movement(minutes: 111, date: "2021-03-17", numMoving: 10, emojis: "🏃‍♀️"))
        return array
    }
    public static func delete() {
        UserDefaults.standard.removeObject(forKey: Self.userDefaultsKey)
        print("ℹ️ [\(#fileID):\(#function):\(#line)] " + String(describing: "Movement deleted"))
    }
    public static func load() -> [String:Movement] {
        if let data = UserDefaults.standard.object(forKey: Self.userDefaultsKey) as? Data {
            let decoder = JSONDecoder()
            do {
                return try decoder.decode([String:Movement].self, from: data)
            } catch {
                print("⛔️ [\(#fileID):\(#function):\(#line)] " + String(describing: error))
            }
        }
        return [:]
    }
}

extension Date {
    var laibanFormattedString: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: self)
    }
}
