//
//  Activity.swift
//
//  Created by Tomas Green on 2019-12-04.
//

import Foundation
import UIKit
import SwiftUI

import SharedActivities

public struct Activity: Codable, Identifiable, Equatable {
    enum TimeFrame {
        case now
        case past
        case future
    }
    public internal(set) var participants: Set<String>
    public let id:String
    public internal(set) var date: Date
    public internal(set) var emoji:String?
    public internal(set) var content:String
    public internal(set) var contentPast:String?
    public internal(set) var contentFuture:String?
    public internal(set) var image:String?
    public internal(set) var imageURL:URL?
    public internal(set) var starts:Date?
    public internal(set) var ends:Date?
    public internal(set) var sharedActivity:SharedActivity? = nil
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        date = try values.decode(Date.self, forKey: .date)
        content = try values.decode(String.self, forKey: .content)
        contentPast = try? values.decode(String.self, forKey: .contentPast)
        contentFuture = try? values.decode(String.self, forKey: .contentFuture)
        emoji = try? values.decode(String.self, forKey: .emoji)
        image = try? values.decode(String.self, forKey: .image)
        starts = try? values.decode(Date.self, forKey: .starts)
        ends = try? values.decode(Date.self, forKey: .ends)
        /// required for backwards compatibility
        imageURL = try? values.decode(URL.self, forKey: .imageURL)
        participants = try values.decode(Set<String>.self, forKey: .participants)
        
        self.sharedActivity = try? values.decode(SharedActivity.self, forKey: .sharedActivity)
    }
    public func formattedContent() -> String {
        Self.string(participants: participants.sorted(), content: content, timeFrame: .now)
    }
    public func formattedContentPast() -> String {
        guard let contentPast = contentPast else {
            return formattedContent()
        }
        return Self.string(participants: participants.sorted(), content: contentPast, timeFrame: .past)
    }
    public func formattedContentFuture() -> String {
        guard let contentFuture = contentFuture else {
            return formattedContent()
        }
        return Self.string(participants: participants.sorted(), content: contentFuture, timeFrame: .future)
    }
    public var canReview:Bool {
        guard let starts = starts, let ends = ends else {
            return false
        }
        let diff = max(starts.timeIntervalSinceNow - ends.timeIntervalSinceNow, 60 * -30)
        return starts.timeIntervalSinceNow < diff && ends.timeIntervalSinceNow > 60 * -40
    }
    public func nowRelativeFormattedContent() -> String {
        let now = Date()
        guard let starts = starts, let ends = ends else {
            if date > now {
        return formattedContentFuture()
            }
            return formattedContentPast()
        }
        if starts >= now && ends <= now {
            return formattedContent()
        }
        if starts > now {
            return formattedContentFuture()
        }
        return formattedContentPast()
    }
    static let imageStorage = LBImageStorage(folder: "activityImages")
    static func string(participants:[String], content:String,timeFrame: TimeFrame = .now) -> String {
        var participantsCopy = participants
        var arr = [String]()
        arr.append(content)
        arr.append(" - ")
        if participantsCopy.count == 0 {
            return content
        } else if participantsCopy.count == 1{
            arr.append(participantsCopy[0])
        } else if participantsCopy.count > 1, let last = participantsCopy.popLast() {
            arr.append(participantsCopy.joined(separator: ", "))
            arr.append(NSLocalizedString("word_and", comment:"world_and").lowercased())
            arr.append(last)
        }
        switch timeFrame {
        case .now: arr.append(NSLocalizedString("activities_participants", bundle: Bundle.module, comment: "activities_participants").lowercased())
        case .past: arr.append(NSLocalizedString("activities_participants_past", bundle: Bundle.module, comment: "activities_participants_past").lowercased())
        case .future: arr.append(NSLocalizedString("activities_participants_future", bundle: Bundle.module, comment: "activities_participants_future").lowercased())
        }
    
        return arr.joined(separator: " ")
    }
    init() {
        self.id = UUID().uuidString
        self.content = ""
        self.image = nil
        self.date = Date()
        self.participants = []
    }
    
    init(date: Date, content:String, image:String?) {
        self.id = UUID().uuidString
        self.date = date
        self.content = content
        self.image = image
        self.participants = []
    }
    init(id: String = UUID().uuidString, date: Date, content:String, image:String? = nil, emoji:String? = nil, activityParticipants: Set<String> = [], starts:Date? = nil, ends:Date? = nil) {
        self.id = id
        self.date = date
        self.content = content
        self.image = image
        self.emoji = emoji
        self.participants = activityParticipants
        if let starts = starts, let ends = ends {
            let s = timeStringfrom(date: starts)
            let e = timeStringfrom(date: ends)
            self.starts = relativeDateFrom(time: s, date: date)
            self.ends = relativeDateFrom(time: e, date: date)
        }
    }
    init(_ sharedActivity:SharedActivity,imageId:String?) {
        self.id = UUID().uuidString
        self.date = Date()
        self.content = sharedActivity.title
        self.image = imageId
        self.sharedActivity = sharedActivity
        self.participants = []
    }
    init(id: String, date: Date, content:String, image:String?) {
        self.id = id
        self.date = date
        self.content = content
        self.image = image
        self.participants = []
    }
    init(activity: Activity) {
        var imageCopy:String? = UUID().uuidString + ".jpeg"
        if let url = Self.imageStorage.url(for: activity.image), let url2 = Self.imageStorage.url(for: imageCopy) {
            do {
                try FileManager.default.copyItem(at: url, to: url2)
            } catch {
                print("⛔️ [\(#fileID):\(#function):\(#line)] " + String(describing: error))
            }
        } else {
            imageCopy = nil
        }
        let date = Date()
        self.id = UUID().uuidString
        self.date = date
        self.emoji = activity.emoji
        self.content = activity.content
        self.contentPast = activity.contentPast
        self.contentFuture = activity.contentFuture
        self.image = imageCopy
        self.participants = []
        if let starts = starts, let ends = ends {
            let s = timeStringfrom(date: starts)
            let e = timeStringfrom(date: ends)
            self.starts = relativeDateFrom(time: s, date: date)
            self.ends = relativeDateFrom(time: e, date: date)
        }
    }
    var copy:Activity {
        return Activity(activity: self)
    }
    public init(
        id: String,
        participants: [String],
        date: Date,
        emoji:String?,
        content:String,
        contentPast:String?,
        contentFuture:String?,
        image:String?,
        imageURL:URL?,
        starts:Date?,
        ends:Date?,
        sharedActivity:SharedActivity? = nil
    ) {
        self.id = id
        self.participants = Set(participants)
        self.date = date
        self.emoji = emoji
        self.content = content
        self.contentPast = contentPast
        self.contentFuture = contentFuture
        self.image = image
        self.imageURL = imageURL
        self.starts = starts
        self.ends = ends
        self.sharedActivity = sharedActivity
    }
}
