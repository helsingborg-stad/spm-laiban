//
//  MovementManager.swift
//  
//
//  Created by Fredrik Häggbom on 2022-10-27.
//

import Foundation
import Combine

public class MovementManager : ObservableObject {
    
    private static let userDefaultsKey = "MovementStatistics"
    private var reportInProgress = false
    public var delegate: MovementStorage? {
        didSet {
            updateData()
        }
    }
    @Published public private(set) var array:[Movement]
    var settings = MovementSettings()
    
    public init() {
        self.array = [Movement]()
    }
    
    public func updateData(newData: [Movement]? = nil) {
        if let newData = newData {
            self.array = newData
        }
        self.updateArray()
    }
    public func getWeeklyMovement(for date:Date = Date()) -> Int {
        guard var start = date.startOfWeek else {
            return 0
        }
        var totalMinutes:Int = 0
        for _ in 0..<5 {
            let w = array.filter { $0.date == start.laibanFormattedString }
            let minutes = w.map { $0.minutes * $0.numMoving }.reduce(0, +)
            totalMinutes += minutes
            start = start.tomorrow!
        }
        return Int(Double(totalMinutes * settings.stepsPerMinute) * settings.stepLength)
    }

    public func movement(for date:Date = Date()) -> [Movement]? {
        return array.filter { $0.date == date.laibanFormattedString }
    }
    
    public func movementMinutes(for date: Date = Date()) -> Int {
        if let w = movement(for: date) {
            return w.map { $0.minutes * $0.numMoving }.reduce(0, +)
        } else {
            return 0
        }
    }
    
    public func movementSteps(for date: Date = Date()) -> Int {
        let minutes = movementMinutes(for: date)
        return minutes * settings.stepsPerMinute
    }
    
    public func movementMeters(for date: Date = Date()) -> Int {
        let steps = movementSteps(for: date)
        // 100 steps a minute, 3 steps a meter
        return Int(Double(steps) * settings.stepLength)
    }
    
    public func meters(from minutes: Int) -> Int {
        Int(round(Double(minutes * settings.stepsPerMinute) * settings.stepLength))
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
