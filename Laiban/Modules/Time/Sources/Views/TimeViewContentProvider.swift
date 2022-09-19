//
//  TimeViewContentProvider.swift
//  LaibanApp
//
//  Created by Tomas Green on 2022-05-18.
//

import Foundation
import Combine

public protocol TimeViewContentProvider {
    func childrenPublisher() -> AnyPublisher<[TimeViewChildInfo]?,Never>
    func otherClockItemsPublisher() -> AnyPublisher<[ClockItem]?,Never>
}
public extension TimeViewContentProvider {
    func childrenPublisher() -> AnyPublisher<[TimeViewChildInfo]?,Never> {
        return Just<[TimeViewChildInfo]?>(nil).eraseToAnyPublisher()
    }
    func otherClockItemsPublisher() -> AnyPublisher<[ClockItem]?,Never> {
        return Just<[ClockItem]?>(nil).eraseToAnyPublisher()
    }
}
