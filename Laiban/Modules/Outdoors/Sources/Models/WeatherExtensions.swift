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
    public enum SeasonalBreakPoint {
        case winterStarts
        case winterEnds
        case autumnStarts
        case springEnds
        func dateString(year:Int) -> String {
            switch self {
            case .winterStarts: return "\(year)-11-01"
            case .winterEnds: return "\(year)-03-31"
            case .autumnStarts: return "\(year)-09-15"
            case .springEnds: return "\(year)-05-15"
            }
        }
    }
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
    public static func condition(for temperature:Double, precipitation:Double) -> Self {
        let c1 = condition(for: temperature)
        if precipitation > 0 {
            switch c1 {
            case .cold: return .coldAndRainy
            case .cool: return .coolAndRainy
            default: return .rainy
            }
        }
        return c1
    }
    public var garments:[Garment] {
        let date = Date()
        let year = date.year
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let winterStarts   = dateFormatter.date(from: SeasonalBreakPoint.winterStarts.dateString(year: year))!
        let winterEnds     = dateFormatter.date(from: SeasonalBreakPoint.winterEnds.dateString(year: year))!
        let autumnStarts   = dateFormatter.date(from: SeasonalBreakPoint.autumnStarts.dateString(year: year))!
        let springEnds     = dateFormatter.date(from: SeasonalBreakPoint.springEnds.dateString(year: year))!
        return garments(date: date, winterStarts: winterStarts, winterEnds: winterEnds, autumnStarts: autumnStarts, springEnds: springEnds)
    }
    func garments(date:Date, winterStarts:Date,winterEnds:Date,autumnStarts:Date,springEnds:Date) -> [Garment] {
        var arr = Set(baseGarments)
        if date > winterStarts  || date < winterEnds {
            arr.remove(.pulloverPants)
            arr.remove(.jacket)
            arr.remove(.cap)
            arr.remove(.rainGloves)
            arr.insert(.winterOutfit)
            arr.insert(.neckwear)
            arr.insert(.beanie)
            arr.insert(.mittens)
        } else if isCold && (date > autumnStarts || date < springEnds) {
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
