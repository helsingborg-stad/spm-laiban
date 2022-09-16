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
    var title:String {
        switch self {
        case .lunch: return "Lunch"
        case .activity: return "Aktiviteter"
        }
    }
    var timeVisibleAfterReported:TimeInterval {
        switch self {
        case .lunch: return 8
        case .activity: return 8
        }
    }
    var timeHiddenAfterReported:TimeInterval {
        switch self {
        case .lunch: return 8
        case .activity: return 8
        }
    }
    var rimColor:Color {
        switch self {
        case .lunch: return Color("RimColorFood",bundle:LBBundle)
        case .activity: return Color("RimColorActivities",bundle:LBBundle)
        }
    }
}

public struct FeedbackDataPoint: Codable {
    var id:String = UUID().uuidString
    var date:Date = Date()
    var reaction:Int
    var reported:Bool = false
    public init(id:String = UUID().uuidString, date:Date = Date(), reaction:Int, reported:Bool = false) {
        self.id = id
        self.date = date
        self.reaction = reaction
        self.reported = reported
    }
}

public struct FeedbackValue: Codable, Identifiable {
    public var id: String = UUID().uuidString
    var date: Date = Date()
    var value: String
    var category: FeedbackCategory
    var data: [FeedbackDataPoint] = []
    
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
    
    static func string(for date:Date) -> String {
        let f = DateFormatter()
        f.doesRelativeDateFormatting = true
        f.dateStyle = .medium
        f.timeStyle = .none
        return f.string(from: date)
    }
    
    func sum(_ reaction: LBFeedbackReaction) -> Int {
        self.data.filter { d in d.reaction == reaction.rawValue }.count
    }
    
    static func numbers(for value: FeedbackValue, reaction: LBFeedbackReaction) -> CGFloat {
        let s = CGFloat(value.sum(reaction))
        return s/CGFloat(value.data.count)
    }
    
    static func graphData(from value: FeedbackValue) -> [LBGraphItem] {
        var arr = [LBGraphItem]()
        for reaction in LBFeedbackReaction.allCases.reversed() {
            arr.append(LBGraphItem(color: Color("FeedbackColor\(reaction.rawValue)"), emoji: reaction.emoji, percentage: self.numbers(for: value, reaction: reaction)))
        }
        return arr
    }
}
