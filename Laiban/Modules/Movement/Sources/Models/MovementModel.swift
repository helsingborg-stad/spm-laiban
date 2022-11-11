//
//  File.swift
//  
//
//  Created by Fredrik Häggbom on 2022-11-01.
//

import Foundation
import SwiftUI

public struct MovementModel: Codable, Equatable {
    var settings: MovementSettings
    var movement: [Movement]
    var activities: [MovementActivity]
}

public struct Movement: Codable,Hashable,Identifiable {
    public var id:String
    public var date:String
    public var minutes:Int
    public var reported:Bool = false
    public var numMoving:Int = 0
    public var emojis:String = ""
    public init(minutes:Int,date:Date = Date(), numMoving:Int) {
        self.id = UUID().uuidString
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        self.date = f.string(from: date)
        self.numMoving = numMoving
        self.minutes = minutes
    }
    public init(minutes:Int,date:String, numMoving:Int, emojis:String = "") {
        self.id = UUID().uuidString
        self.date = date
        self.minutes = minutes
        self.numMoving = numMoving
        self.emojis = emojis
    }
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decode(String.self, forKey: .id) ?? UUID().uuidString
        self.date = try values.decode(String.self, forKey: .date)
        self.minutes = try values.decode(Int.self, forKey: .minutes)
        self.reported = (try? values.decode(Bool.self, forKey: .reported)) ?? false
        self.numMoving = (try? values.decode(Int.self, forKey: .numMoving)) ?? 0
        self.emojis = try values.decode(String.self, forKey: .emojis)
    }
}
