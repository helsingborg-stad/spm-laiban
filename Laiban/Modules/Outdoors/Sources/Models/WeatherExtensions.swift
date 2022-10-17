//
//  WeatherExtensions.swift
//  Daisy
//
//  Created by Tomas Green on 2021-09-15.
//

import Foundation
import Weather


public extension WeatherPrecipitation {
    var titleKey:String {
        switch self {
        case .none: return "weather_precipitation_noPrecipitation"
        case .snow: return "weather_precipitation_snow"
        case .snowAndRain: return "weather_precipitation_snowAndRain"
        case .rain: return "weather_precipitation_rain"
        case .drizzle: return "weather_precipitation_drizzle"
        case .freezingRain: return "weather_precipitation_freezingRain"
        case .freezingDrizzle: return "weather_precipitation_freezingDrizzle"
        }
    }
}
public extension WeatherData {
    var conditions:WeatherCondition {
        let c = WeatherCondition.condition(for: airTemperatureFeelsLike)
        if precipitationCategory != .none {
            switch c {
            case .cold: return .coldAndRainy
            case .cool: return .coolAndRainy
            default: return .rainy
            }
        }
        return c
    }
}
public extension Weather {
    func conditions(for data:WeatherData) -> WeatherCondition {
        return data.conditions
    }
}
public enum WeatherCondition:String, CaseIterable, Codable {
    case unknown
    case rainy
    case cold
    case coldAndRainy
    case cool
    case coolAndRainy
    case warmish
    case warm
    case hot
    public var localizationKey:String {
        return "weather_\(self.rawValue)"
    }
    public static func condition(for temperature:Double) -> Self {
        if (Double(Int.min)...10).contains(temperature) { return .cold}
        if (10...12).contains(temperature) { return .cool}
        if (12...16).contains(temperature) { return .warmish}
        if (16...20).contains(temperature) { return .warm}
        if (20...Double(Int.max)).contains(temperature) { return .hot}
        return .unknown
    }
    public var garments:[Garment] {
        var arr = Set(baseGarments)
        let now = Date()
        if now > date(month: "11", day: "01")  || now < date(month: "03", day: "31") {
            arr.remove(.pulloverPants)
            arr.remove(.jacket)
            arr.remove(.cap)
            arr.remove(.rainGloves)
            arr.insert(.winterOutfit)
            arr.insert(.neckwear)
            arr.insert(.beanie)
            arr.insert(.mittens)
        } else if isCold && (now > date(month: "09", day: "15") || now < date(month: "05", day: "15")) {
            arr.insert(.beanie)
            arr.insert(.mittens)
            arr.remove(.cap)
        }
        return Array(arr).sorted { (g1, g2) in g1.sortPriority < g2.sortPriority }
    }
    public var baseGarments:[Garment] {
        switch self {
        case .unknown: return []
        case .rainy: return [.rainPants,.rainCoat,.rainBoots]
        case .cold: return [.sweater,.pulloverPants,.jacket,.winterBoots]
        case .coldAndRainy: return [.sweater,.pulloverPants,.jacket,.rainBoots,.rainGloves]
        case .cool: return [.sweater,.jacket,.pulloverPants,.shoes]
        case .coolAndRainy: return [.sweater,.rainPants,.rainCoat,.rainBoots]
        case .warmish: return [.sweater,.cap,.shoes]
        case .warm: return [.cap,.shoes]
        case .hot: return [.cap,.shoes]
        }
    }
    public var isCold:Bool {
        [Self.cold, Self.coldAndRainy].contains(self)
    }
}
/// Creates a date object based on the given data
/// - Parameters:
///   - year: the year
///   - month: the month (leading 0)
///   - day: the day (leading 0)
/// - Returns: a date object based on the given parameters
fileprivate func date(month:String,day:String) -> Date!{
    let garmentDF = DateFormatter()
    garmentDF.dateFormat = "yyyy-MM-dd"
    
    return garmentDF.date(from: "\(Date().year)-\(month)-\(day)")
}
