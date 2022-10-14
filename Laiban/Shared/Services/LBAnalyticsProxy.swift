//
//  Analytics.swift
//
//  Created by Tomas Green on 2020-04-15.
//

import Foundation
import Combine

public class LBOldAnalyticsProxy {
    public struct PageViewEvent {
        public let page:String
        public let properties:[String:Any]?
    }
    public struct ImpressionEvent {
        public let type:String
        public let piece:String?
        public let properties:[String:Any]?
    }
    public struct ErrorEvent {
        public let error:Error
        public let properties:[String:Any]?
    }
    public struct UserActionEvent {
        public let name:String
        public let action:String
        public let category:String
        public let properties:[String:Any]?
    }
    public struct CustomEvent {
        public let name:String
        public let properties:[String:Any]?
    }
    
    private let pageViewSubject = PassthroughSubject<PageViewEvent,Never>()
    private let impressionSubject = PassthroughSubject<ImpressionEvent,Never>()
    private let errorSubject = PassthroughSubject<ErrorEvent,Never>()
    private let customSubject = PassthroughSubject<CustomEvent,Never>()
    private let userActionSubject = PassthroughSubject<UserActionEvent,Never>()
    
    public let pageViewPublisher:AnyPublisher<PageViewEvent,Never>
    public let impressionPublisher:AnyPublisher<ImpressionEvent,Never>
    public let errorPublisher:AnyPublisher<ErrorEvent,Never>
    public let customPublisher:AnyPublisher<CustomEvent,Never>
    public let userActionPublisher:AnyPublisher<UserActionEvent,Never>
    
    public static var shared = LBOldAnalyticsProxy()
    init() {
        pageViewPublisher = pageViewSubject.eraseToAnyPublisher()
        impressionPublisher = impressionSubject.eraseToAnyPublisher()
        errorPublisher = errorSubject.eraseToAnyPublisher()
        customPublisher = customSubject.eraseToAnyPublisher()
        userActionPublisher = userActionSubject.eraseToAnyPublisher()
    }
    func log(_ event:String, properties:[String:Any]? = nil) {
        customSubject.send(.init(name: event, properties: properties))
    }
    func log(_ event:String, category:String, action:String, properties:[String:Any]? = nil) {
        userActionSubject.send(.init(name: event, action: action, category: category, properties: properties))
    }
    func logContentImpression(_ type:String, piece:String? = nil, properties:[String:Any]? = nil) {
        impressionSubject.send(.init(type: type, piece: piece, properties: properties))
    }
    func logPageView(_ view:String, properties:[String:Any]? = nil) {
        pageViewSubject.send(.init(page: view, properties: properties))
    }
    func logPageView(_ view:Any, properties:[String:Any]? = nil) {
        pageViewSubject.send(.init(page: String(describing: type(of: view)), properties: properties))
    }
    func logError(_ error: Error, properties: [String: AnyHashable]? = nil) {
        errorSubject.send(.init(error: error, properties: properties))
    }
}
