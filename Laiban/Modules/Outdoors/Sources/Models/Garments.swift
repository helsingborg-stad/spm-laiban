//
//  Garments.swift
//
//  Created by Tomas Green on 2019-12-04.
//

import Foundation
import Weather
import Combine
import SwiftUI

fileprivate func date(month:String,day:String) -> Date!{
    let garmentDF = DateFormatter()
    garmentDF.dateFormat = "yyyy-MM-dd"
    
    return garmentDF.date(from: "\(Date().year)-\(month)-\(day)")
}
public struct GarmentGroup {
    public let name:String
    public let garments:[Garment]
}
public class GarmentStore: ObservableObject {
    public enum RatingTag: String,Codable,Equatable {
        case child
        case teacher
        case system
    }
    public enum Rating: Int,Codable,Equatable {
        case bad = 1
        case good = 4
    }
    public struct DataModel: Codable {
        public var records = [Record]()
        public var feedback = [GarmentFeedback]()
    }
    public struct GarmentFeedback: Codable,Equatable {
        public let id:String
        public let rating:Int
        public let tag:String?
        public let recordId:String?
        public let garments:String
        public let date:Date
        public init(rating:Int, tag:String, recordId:String? = nil, garments:String) {
            self.id = UUID().uuidString
            self.rating = rating
            self.recordId = recordId
            self.garments = garments
            self.tag = tag
            self.date = Date()
        }
    }
    public struct Record: Codable,Identifiable,Equatable {
        public let id:String
        public let date:Date
        public let garments:[Garment]
        public let conditions:WeatherCondition
        public func isValid(for conditions:WeatherCondition) -> Bool {
            self.conditions == conditions
        }
        public init(garments:[Garment], contitions:WeatherCondition, date:Date = Date()) {
            self.id = UUID().uuidString
            self.garments = garments
            self.conditions = contitions
            self.date = date
        }
    }
    @Published public var data:DataModel
    public init() {
        self.data = Self.load() ?? DataModel()
    }
    public func getRecord(for conditions:WeatherCondition) -> Record? {
        guard let first = self.data.records.sorted(by: { $0.date > $1.date }).first,first.conditions == conditions else {
            return nil
        }
        return first
    }
    public func feedback(for record:Record) -> [GarmentFeedback] {
        return data.feedback.filter { $0.recordId == record.id}
    }
    /// Vote for a set of garments
    /// - Parameters:
    ///   - rating: good or bad
    ///   - garments: the garments to rate
    public func rate(_ rating:Rating, tag:RatingTag, garments:[Garment]) {
        self.data.feedback.append(.init(rating:rating.rawValue, tag:tag.rawValue, garments: Garment.string(from: garments)))
        store()
    }
    /// Vote for a change record
    /// - Parameters:
    ///   - rating: good or bad
    ///   - record: the record to rate
    public func rate(_ rating:Rating, tag:RatingTag, record:Record) {
        self.data.feedback.append(.init(rating:rating.rawValue, tag:tag.rawValue, recordId: record.id, garments: Garment.string(from: record.garments)))
        store()
    }
    public func delete(records:[Record]) {
        for r in records {
            data.records.removeAll { $0.id == r.id }
            data.feedback.removeAll { $0.recordId == r.id }
        }
        store()
    }
    public func addRecord(_ record:Record) {
        self.data.records.append(record)
        store()
    }
    public static func purge() {
        let filepath = getFilePath()
        do{
            try FileManager.default.removeItem(at: filepath)
        } catch {
            print("⛔️ [\(#fileID):\(#function):\(#line)] " + String(describing: error))
        }
    }
    private func store() {
        do {
            let filepath = Self.getFilePath()
            let encoded = try JSONEncoder().encode(self.data)
            try encoded.write(to: filepath)
        } catch {
            print("⛔️ [\(#fileID):\(#function):\(#line)] " + String(describing: error))
        }
    }
    private static func getFilePath() -> URL {
        let arrayPaths = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)
        let filepath = arrayPaths[0]
        return filepath.appendingPathComponent("GamrmentStore.json")
    }
    private static func load() -> DataModel? {
        let url = getFilePath()
        guard FileManager.default.fileExists(atPath: url.path) else {
            return nil
        }
        do {
            let decoder = JSONDecoder()
            let data = try Data(contentsOf: url)
            let m = try decoder.decode(DataModel.self, from: data)
            print("ℹ️ [\(#fileID):\(#function):\(#line)] " + String(describing: "GamrmentStore loaded from file"))
            return m
        } catch {
            print("⛔️ [\(#fileID):\(#function):\(#line)] " + String(describing: error))
        }
        return nil
    }
    public func getGarments(_ outdoorsService:OutdoorsService, coremlModel:AttireSuggestionPredictionModel?) -> [Garment] {
        if let data = outdoorsService.weather {
            if let m = getRecord(for: data.conditions), m.isValid(for: data.conditions) {
                return m.garments.sorted { (g1, g2) in g1.sortPriority < g2.sortPriority }
            }
            if outdoorsService.data.mlPoweredClothes == true, let model = coremlModel {
                let input = AttireSuggestionPredictionModelInput(
                    temperature: data.airTemperature,
                    humidity: Double(data.relativeHumidity),
                    dewPoint: Weather.dewPointAdjustedTemperature(humidity: Double(data.relativeHumidity), temperature: data.airTemperature),
                    windSpeed: data.windSpeed,
                    windGustSpeed: data.windGustSpeed,
                    windDirection: data.windDirection,
                    airPressure: data.airPressure,
                    totalPrecipitation: data.maxPrecipitation)
                do {
                    let val = try model.prediction(input: input)
                    return Garment.garments(from: val.clothes).sorted { (g1, g2) in g1.sortPriority < g2.sortPriority }
                } catch {
                    print("⛔️ [\(#fileID):\(#function):\(#line)] " + String(describing: error))
                }
            }
            return data.conditions.garments.sorted { (g1, g2) in g1.sortPriority < g2.sortPriority }
        }
        return []
    }
}
public enum Garment : String, Identifiable, CaseIterable,Codable {
    public var id:String {
        return self.rawValue
    }
    case cap
    case beanie
    case mittens
    case jacket
    case pulloverPants
    case shoes
    case rainPants
    case rainBoots
    case rainCoat
    case rainGloves
    case sweater
    case winterBoots
    case winterOutfit
    case neckwear
    var imageName:String {
        switch self {
            case .shoes:          return "garment_shoes"
            case .cap:            return "garment_cap"
            case .mittens:        return "garment_mittens"
            case .beanie:         return "garment_beanie"
            case .jacket:         return "garment_jacket"
            case .pulloverPants:  return "garment_pulloverPants"
            case .rainPants:      return "garment_rainPants"
            case .rainBoots:      return "garment_rainBoots"
            case .rainCoat:       return "garment_rainCoat"
            case .rainGloves:     return "garment_rainGloves"
            case .sweater:        return "garment_sweater"
            case .winterBoots:    return "garment_winterBoots"
            case .winterOutfit:   return "garment_winterOutfit"
            case .neckwear:       return "garment_neckWear"
        }
    }

    public var sortPriority : Int {
        switch self {
        case .sweater: return 1
        case .pulloverPants: return 2
        case .neckwear: return 3
        case .jacket: return 4
        case .winterOutfit: return 5
        case .rainCoat: return 6
        case .rainPants: return 7
        case .beanie: return 8
        case .shoes,.rainBoots,.winterBoots: return 11
        case .mittens, .rainGloves: return 20
        default: return 10;
        }
    }
    public var localizationKey:String {
        switch self {
            case .shoes:          return "garment_shoes"
            case .cap:            return "garment_cap"
            case .mittens:        return "garment_mittens"
            case .beanie:         return "garment_beanie"
            case .jacket:         return "garment_jacket"
            case .pulloverPants:  return "garment_pulloverPants"
            case .rainPants:      return "garment_rainPants"
            case .rainBoots:      return "garment_rainBoots"
            case .rainCoat:       return "garment_rainCoat"
            case .rainGloves:     return "garment_rainGloves"
            case .sweater:        return "garment_sweater"
            case .winterBoots:    return "garment_winterBoots"
            case .winterOutfit:   return "garment_winterOutfit"
            case .neckwear:       return "garment_neckWear"
        }
    }
    public var incompatibles:[Garment] {
        switch self {
        case .cap:           return [.beanie]
        case .mittens:       return [.rainGloves]
        case .beanie:        return [.cap]
        case .jacket:        return [.winterOutfit]
        case .pulloverPants: return [.winterOutfit]
        case .rainPants:     return []
        case .rainBoots:     return [.winterBoots,.shoes]
        case .rainCoat:      return []
        case .rainGloves:    return [.mittens]
        case .shoes:         return [.winterBoots,.rainBoots]
        case .sweater:       return []
        case .winterBoots:   return [.shoes,.rainBoots]
        case .winterOutfit:  return [.jacket,.pulloverPants]
        case .neckwear:      return []
        }
    }
    public static var groups:[GarmentGroup] {
        return [
            .init(name:"grupp1", garments:[.sweater,.neckwear]),
            .init(name:"grupp2", garments:[.rainPants,.pulloverPants,.winterOutfit]),
            .init(name:"grupp3", garments:[.rainCoat,.jacket]),
            .init(name:"grupp4", garments:[.cap,.beanie]),
            .init(name:"grupp5", garments:[.rainBoots,.shoes,.winterBoots]),
            .init(name:"grupp6", garments:[.rainGloves,.mittens]),
        ]
    }
    public static func garments(from string:String) -> [Garment] {
        var arr = [Garment]()
        let all = Garment.allCases
        guard string.count == all.count else {
            debugPrint("not correct amount of clothes")
            return []
        }
        for (index,s) in string.enumerated() {
            if s == "t" {
                arr.append(all[index])
            }
        }
        return arr.sorted { (g1, g2) in g1.sortPriority < g2.sortPriority }
    }
    public static func string(from garments:[Garment]) -> String {
        var s = ""
        for g in allCases {
            s += garments.contains(g) ? "t" : "f"
        }
        return s
    }
}
