//
//  WeatherServiceModel.swift
//  LaibanApp
//
//  Created by Jonatan Hanson on 2022-05-12.
//

import Foundation

public struct WeatherServiceModel: Equatable, Decodable, Encodable {
    public var coordinates: Coordinates? = nil
    public var mlPoweredClothes:Bool = true
}
