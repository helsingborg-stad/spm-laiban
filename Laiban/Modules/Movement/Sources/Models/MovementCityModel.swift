//
//  MovementCityModel.swift
//  
//
//  Created by Fredrik Häggbom on 2022-11-18.
//

import Foundation

public struct MovementCityModel: Codable {
    let cities: [City]
    
    enum CodingKeys: String, CodingKey {
        case cities = "geonames"
    }
}

public struct City: Codable {
    let lng, distance: String
    let geonameID: Int
    let countryCode, name, toponymName, lat: String?
    let fcl, fcode: String?
    var start: Bool = false
    var destination: Bool = false

    enum CodingKeys: String, CodingKey {
        case lng, distance
        case geonameID = "geonameId"
        case countryCode, name, toponymName, lat, fcl, fcode
    }
}
