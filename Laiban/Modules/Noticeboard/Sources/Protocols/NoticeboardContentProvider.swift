//
//  NoticeboardContentProvider.swift
//  LaibanApp
//
//  Created by Tomas Green on 2022-04-26.
//

import Foundation
import Combine

public enum NoticeboardWeatherCondition: CaseIterable, Equatable {
    case sunny
    case precipitation
    case conditionAppropriateClothes
}

public protocol NoticeboardContentProvider {
    func noticeboardWeatherConditionsPublisher(from: Date, to: Date) -> AnyPublisher<Set<NoticeboardWeatherCondition>, Never>
    func messagesPublisher() -> AnyPublisher<[Message],Never>
}

public class PreviewNoticeboardContentProvider : NoticeboardContentProvider {
    @Published var messages:[Message]
    public init() {
        self.messages = Self.loadMessages()
    }
    static func loadMessages() -> [Message] {
        guard let url = Bundle.main.url(forResource: "Messages", withExtension: "json") else {
            return []
        }
        do {
            return try JSONDecoder().decode([Message].self, from: try Data(contentsOf: url))
        } catch {
            print(error)
        }
        return []
    }
    public func noticeboardWeatherConditionsPublisher(from: Date, to: Date) -> AnyPublisher<Set<NoticeboardWeatherCondition>, Never> {
        return Just(Set(NoticeboardWeatherCondition.allCases)).eraseToAnyPublisher()
    }
    
    public func messagesPublisher() -> AnyPublisher<[Message], Never> {
        $messages.eraseToAnyPublisher()
    }
}
