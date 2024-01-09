//
//  DefaultMemoryGames.swift
//  Laiban
//
//  Created by Tomas Green on 2021-06-14.
//

import Foundation

public struct MemoryGameServiceModel: LBServiceModel, Codable, Equatable {
    public var defaultMemoryGames:[DefaultMemoryGame] = []
    public var memoryGamesAtRandomEnabled:Bool = false
    public var showOnDashboard: Bool = false
}


public enum DefaultMemoryGame : String, Codable, CaseIterable, Identifiable {
    public var id:String {
        return "DefaultMemoryGame-\(rawValue)"
    }
    case undp
    case trashmonsters
    public var title:String {
        switch self {
        case .undp: return "De 17 globala målen"
        case .trashmonsters: return "Sopsamlarmonster"
        }
    }
    public static var standard:[DefaultMemoryGame] = []
}
