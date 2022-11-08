//
//  MovementActivity.swift
//  
//
//  Created by Fredrik Häggbom on 2022-11-01.
//

import Foundation
import SwiftUI

public struct MovementActivity: Codable, Identifiable, Equatable {
    public let id: String
    let colorString: String
    let title: String
    let emoji: String
    let localizationKey: String?
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
