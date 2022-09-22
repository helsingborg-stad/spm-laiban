//
//  TimeService.swift
//  LaibanApp
//
//  Created by Tomas Green on 2022-05-17.
//

import Foundation

public struct TimeServiceModel : Codable, Equatable, Hashable {
    public var dayStarts = "07:00"
    public var dayEnds = "17:00"
    public var events:[ClockEvent] = []
}
