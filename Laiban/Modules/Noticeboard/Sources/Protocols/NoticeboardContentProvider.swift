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
    func otherMessagesPublisher() -> AnyPublisher<[Message],Never>
}

public class PreviewNoticeboardContentProvider : NoticeboardContentProvider {
    @Published var messages:[Message]
    public init() {
        self.messages = [.init(category:.info,name:"Party", title:"Festligheter",text: "Idag är det fest", emoji: "🎉",active: true)]
    }
    public func noticeboardWeatherConditionsPublisher(from: Date, to: Date) -> AnyPublisher<Set<NoticeboardWeatherCondition>, Never> {
        return Just(Set(NoticeboardWeatherCondition.allCases)).eraseToAnyPublisher()
    }
    
    public func otherMessagesPublisher() -> AnyPublisher<[Message], Never> {
        $messages.eraseToAnyPublisher()
    }
}
