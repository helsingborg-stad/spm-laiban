//
//  ReturnToHomeScreen.swift
//
//  Created by Tomas Green on 2020-06-10.
//

import Foundation
import Combine


public enum ReturnToHomeScreen: String,CaseIterable,Identifiable,Hashable,Codable {
    public var id:String {
        return rawValue
    }
    case never
    case after30seconds
    case after1minutes
    case after2minutes
    case after3minutes
    case after5minutes
    case after10minutes
    case after20minutes
    public var title:String {
        switch self {
        case .never: return "Ej aktiverad"
        case .after30seconds: return "30 sekunder"
        case .after1minutes: return "1 minut"
        case .after2minutes: return "2 minuter"
        case .after3minutes: return "3 minuter"
        case .after5minutes: return "5 minuter"
        case .after10minutes: return "10 minuter"
        case .after20minutes: return "20 minuter"
        }
    }
    public var timeInterval:TimeInterval {
        switch self {
        case .never: return 0
        case .after30seconds: return 30
        case .after1minutes: return 60
        case .after2minutes: return 60 * 2
        case .after3minutes: return 60 * 3
        case .after5minutes: return 60 * 5
        case .after10minutes: return 60 * 10
        case .after20minutes: return 60 * 20
        }
    }
}
