//
//  Disease.swift
//  Laiban
//
//  Created by Tomas Green on 2021-06-09.
//

import Foundation
import Analytics

public enum MessageCategory : String, Codable, Identifiable, CaseIterable {
    public var id:String {
        switch self {
        case .info: return "0B0C5CC0-E989-4341-A280-9531585C2232"
        case .disease: return "74E56F58-F4A3-41F1-AC8E-4405DA42BF14"
        case .reminder: return "49509419-C081-46DD-826A-66413B072EA1"
        }
    }
    case disease
    case info
    case reminder
    public var name:String {
        switch self {
        case .disease: return "Sjukdom"
        case .info: return "Information"
        case .reminder: return "Påminnelse"
        }
    }
    var localizedKey:String {
        return "message_category_\(self.rawValue)_title"
    }
}
public struct Message : Identifiable, Codable,Equatable {
    public var id:String
    public var tag:String?
    public var category:MessageCategory
    public var name:String
    public var title:String
    public var text:String
    public var link:String
    public var emoji:String
    public var active:Bool
    public var automatable:Bool
    public var automated:Bool
    public let systemDefault:Bool
    public init(id:String = UUID().uuidString, category:MessageCategory = .info, name:String = "", title:String = "", text:String = "", emoji:String = "", active:Bool = true) {
        self.id = id
        self.tag = nil
        self.category = category
        self.title = title
        self.name = name
        self.text = text
        self.emoji = emoji
        self.active = active
        self.systemDefault = false
        self.automatable = false
        self.automated = false
        self.link = ""
    }
    public init(_ message:Message) {
        self.id = message.id
        self.tag = message.tag
        self.category = message.category
        self.title = message.title
        self.name = message.name
        self.text = message.text
        self.emoji = message.emoji
        self.active = message.active
        self.systemDefault = message.systemDefault
        self.automatable = message.automatable
        self.automated = message.automated
        self.link = message.link
    }
    @available(*, deprecated, message: "Use NoticeboardService instead")
    static func loadSync() -> [Message] {
        guard let url = Bundle.main.url(forResource: "Messages", withExtension: "json") else {
            return []
        }
        do {
            return try JSONDecoder().decode([Message].self, from: try Data(contentsOf: url))
        } catch {
            AnalyticsService.shared.logError(error)
            print(error)
        }
        return []
    }
}
