//
//  UNDPGoals.swift
//  Laiban
//
//  Created by Tomas Green on 2021-09-02.
//

import Foundation
import SwiftUI

public enum UNDPGoal: Int, Identifiable, CaseIterable {
    public var id:String {
        switch self {
        case .goal1 : return "B88B6E23-4903-4DD6-981B-FE1665332CCF"
        case .goal2 : return "6051819B-A470-4222-99EE-E2EA455167EC"
        case .goal3 : return "54B4F354-6F1C-4AD9-A9EE-F3CA8AB127D6"
        case .goal4 : return "1005DCF1-18B3-447A-8913-75507CE03F89"
        case .goal5 : return "77A96442-A88B-4A5E-844C-8ED1DE356313"
        case .goal6 : return "F0FE718A-EA7B-4927-9B7B-5A963CC8CC8E"
        case .goal7 : return "F3AF26E7-E989-41EC-9E53-F67989022C9A"
        case .goal8 : return "3DF05014-174E-4D68-B525-AA254E43CAF8"
        case .goal9 : return "EA810BF5-F352-43FF-A17D-F6E3E66F9B27"
        case .goal10:  return "2C27FB23-BF8C-4918-91F2-39E4C8F76F98"
        case .goal11:  return "7BCC8744-D1CA-4A72-AA80-FC72BD96F967"
        case .goal12:  return "89D1D109-6D2A-498F-B3F2-214DB6037732"
        case .goal13:  return "9DAF5482-7E29-40C1-B00D-4AD2D2F945AF"
        case .goal14:  return "B5BF5247-4A98-4D66-97BE-18BEEFDE9A8E"
        case .goal15:  return "357B3586-6146-475B-B62C-8010FB4C076C"
        case .goal16:  return "E5F06133-842F-4D79-B8DC-17343167F4AC"
        case .goal17:  return "073DA153-398B-48DD-8DD2-1342DE3A4B91"
        }
    }
    case goal1 = 1
    case goal2 = 2
    case goal3 = 3
    case goal4 = 4
    case goal5 = 5
    case goal6 = 6
    case goal7 = 7
    case goal8 = 8
    case goal9 = 9
    case goal10 = 10
    case goal11 = 11
    case goal12 = 12
    case goal13 = 13
    case goal14 = 14
    case goal15 = 15
    case goal16 = 16
    case goal17 = 17
    public var icon:Image {
        Image("undp-goal-notext-\(self.rawValue)",bundle: .module)
    }
    public var backgroundColor:Color {
        Color("undp-goal-\(self.rawValue)",bundle: .module)
    }
    public var titleKey:String {
        "undp_goal_\(self.rawValue)_title"
    }
    public var memoryTitleKey:String {
        "undp_you_found_goal_\(self.rawValue)"
    }
    public var descriptionKey:String {
        "undp_goal_\(self.rawValue)_description"
    }
    public static func goalFrom(sharedActivityTag tag: String) -> Self? {
        switch tag {
        case "undpGoal1":  return .goal1
        case "undpGoal2":  return .goal2
        case "undpGoal3":  return .goal3
        case "undpGoal4":  return .goal4
        case "undpGoal5":  return .goal5
        case "undpGoal6":  return .goal6
        case "undpGoal7":  return .goal7
        case "undpGoal8":  return .goal8
        case "undpGoal9":  return .goal9
        case "undpGoal10": return .goal10
        case "undpGoal11": return .goal11
        case "undpGoal12": return .goal12
        case "undpGoal13": return .goal13
        case "undpGoal14": return .goal14
        case "undpGoal15": return .goal15
        case "undpGoal16": return .goal16
        case "undpGoal17": return .goal17
        default: return nil
        }
    }
    public static let logotype = Image("undp17globalgoals_logo", bundle: .module)
}
