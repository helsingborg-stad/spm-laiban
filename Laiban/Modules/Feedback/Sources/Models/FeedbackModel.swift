//
//  FeedbackModel.swift
//  
//
//  Created by Ehsan Zilaei on 2022-07-07.
//

import SwiftUI

public enum FeedbackCategory: String, Codable, CaseIterable, Identifiable {
    case lunch
    case activity
    public var id:String {
        return self.rawValue
    }
    public var title:String {
        switch self {
        case .lunch: return "Lunch"
        case .activity: return "Aktiviteter"
        }
    }
    public var timeVisibleAfterReported:TimeInterval {
        switch self {
        case .lunch: return 8
        case .activity: return 8
        }
    }
    public var timeHiddenAfterReported:TimeInterval {
        switch self {
        case .lunch: return 8
        case .activity: return 8
        }
    }
    public var rimColor:Color {
        switch self {
        case .lunch: return Color("RimColorFood",bundle:LBBundle)
        case .activity: return Color("RimColorActivities",bundle:LBBundle)
        }
    }
}

public struct FeedbackDataPoint: Codable {
    public private(set) var id:String = UUID().uuidString
    public private(set) var date:Date = Date()
    public private(set) var reaction:Int
    public private(set) var reported:Bool = false
    public init(id:String = UUID().uuidString, date:Date = Date(), reaction:Int, reported:Bool = false) {
        self.id = id
        self.date = date
        self.reaction = reaction
        self.reported = reported
    }
}

public struct FeedbackValue: Codable, Identifiable {
    public var id: String = UUID().uuidString
    public private(set) var date: Date = Date()
    public private(set) var value: String
    public private(set) var category: FeedbackCategory
    public private(set) var data: [FeedbackDataPoint] = []
    
    public init(id:String, date:Date,value:String,category:FeedbackCategory, data:[FeedbackDataPoint]) {
        self.id = id
        self.date = date
        self.value = value
        self.category = category
        self.data = data
    }
    init(value: String, category: FeedbackCategory) {
        self.value = value
        self.category = category        
    }
    
    mutating func add(reaction: LBFeedbackReaction) {
        self.data.append(FeedbackDataPoint(reaction: reaction.rawValue))
    }
    
    public static func string(for date:Date) -> String {
        let f = DateFormatter()
        f.doesRelativeDateFormatting = true
        f.dateStyle = .medium
        f.timeStyle = .none
        return f.string(from: date)
    }
    
    public func sum(_ reaction: LBFeedbackReaction) -> Int {
        self.data.filter { d in d.reaction == reaction.rawValue }.count
    }
    
    public static func numbers(for value: FeedbackValue, reaction: LBFeedbackReaction) -> CGFloat {
        let s = CGFloat(value.sum(reaction))
        return s/CGFloat(value.data.count)
    }
    
    public static func graphData(from value: FeedbackValue) -> [LBGraphItem] {
        var arr = [LBGraphItem]()
        for reaction in LBFeedbackReaction.allCases.reversed() {
            arr.append(LBGraphItem(color: Color("FeedbackColor\(reaction.rawValue)" , bundle:.module), emoji: reaction.emoji, percentage: self.numbers(for: value, reaction: reaction)))
        }
        return arr
    }
}
