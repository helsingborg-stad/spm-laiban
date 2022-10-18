//
//  TrashMonster.swift
//  Laiban
//
//  Created by Tomas Green on 2021-06-07.
//

import Foundation
import Combine
import SwiftUI
import Analytics

public enum LoadMonsterError : Error {
    case filemissing
}

public struct Monster : Codable, Equatable {
    public let name:String
    public init(name:String) {
        self.name = name
    }
    public var descriptionKey:String {
        return "trashmonster_\(name.lowercased())_description"
    }
    public var avatar:Image {
        return Image("Monster-\(name)-Avatar", bundle: .module)
    }
    public var image:Image {
        return Image("Monster-\(name)", bundle: .module)
    }
    public var memoryImage:Image {
        return Image("Monster-\(name)-Memory", bundle: .module)
    }
    public static func load() -> AnyPublisher<[Monster],Error> {
        guard let url = Bundle.module.url(forResource: "TrashMonsters", withExtension: ".json") else {
            return Fail(error: LoadMonsterError.filemissing).eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [Monster].self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    public static func loadSync() -> [Monster] {
        guard let url = Bundle.module.url(forResource: "TrashMonsters", withExtension: ".json") else {
            return []
        }
        do {
            return try JSONDecoder().decode([Monster].self, from: try Data(contentsOf: url))
        } catch {
            AnalyticsService.shared.logError(error)
            print(error)
        }
        return []

    }
}
