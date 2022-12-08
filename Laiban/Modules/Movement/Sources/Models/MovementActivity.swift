//
//  MovementActivity.swift
//  
//
//  Created by Fredrik Häggbom on 2022-11-01.
//

import Foundation
import SwiftUI

public struct MovementActivity: Codable, Identifiable, Equatable, Hashable {
    public var id: String
    var colorString: String
    var title: String
    var emoji: String
    var isActive: Bool = true
    var localizationKey: String?
}

extension MovementActivity {
    var color: Color {
        Color(colorString, bundle: .module)
    }
    
    static var colorStrings: [String] {
        ["RimColorActivities",
         "RimColorCalendar",
         "RimColorClock",
         "RimColorClothes",
         "RimColorFood",
         "RimColorGames",
         "RimColorInstagram",
         "RimColorNoticeboard",
         "RimColorSingalong",
         "RimColorTrashMonsters",
         "RimColorWeather"]
    }
}
