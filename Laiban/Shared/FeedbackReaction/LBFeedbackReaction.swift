//
//  FeedbackCategory.swift
//
//  Created by Tomas Green on 2020-05-27.
//

import Foundation
import SwiftUI

public enum LBFeedbackReaction : Int, CaseIterable, Identifiable, Codable, Equatable,Hashable {
    public var id:String {
        return "FeedbackReaction-\(self.rawValue)"
    }
    case sad = 1
    case neutral = 2
    case happy = 3
    case veryHappy = 4
    public var emoji:String {
        switch self {
        case .veryHappy: return "😀"
        case .happy:     return "🙂"
        case .neutral:   return "😐"
        case .sad:       return "🙁"
        }
    }
    public var color:Color {
        switch self {
        case .veryHappy: return Color("FeedbackReactionColor4", bundle:.module)
        case .happy:     return Color("FeedbackReactionColor3", bundle:.module)
        case .neutral:   return Color("FeedbackReactionColor2", bundle:.module)
        case .sad:       return Color("FeedbackReactionColor1", bundle:.module)
        }
    }
}
