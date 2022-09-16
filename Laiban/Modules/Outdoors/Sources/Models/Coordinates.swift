//
//  Coordinates.swift
//
//  Created by Tomas Green on 2019-12-04.
//

import CoreLocation
import Foundation

public struct Coordinates: Codable, Equatable {
    public let address: String?
    public let latitude: Double
    public let longitude: Double
    public init(address: String?, latitude: Double, longitude: Double) {
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
    }

    public var location: CLLocation {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
}
