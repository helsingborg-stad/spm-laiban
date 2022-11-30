//
//  MovementSettings.swift
//  
//
//  Created by Fredrik Häggbom on 2022-11-07.
//

import Foundation

public struct MovementSettings: Codable, Identifiable, Equatable {
    public var id: String = UUID().uuidString
    var maxMetersPerDay: Int = 250000
    var stepsPerMinute: Int = 100
    var stepLength: Double = 0.33
}
