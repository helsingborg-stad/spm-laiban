//
//  SetExtensions.swift
//  Laiban
//
//  Created by Tomas Green on 2021-12-13.
//

import Foundation
import Combine


//public extension Set where Element == AnyCancellable {
//    /// Remove a cancellable from the cancellables storage
//    /// - Parameter cancellable: the cancellable to remove
//    ///
//    @available(*, deprecated, message: "Use Set<AnyCancellable?> if possible")
//    mutating func add(_ cancellable:AnyCancellable?) {
//        guard let cancellable = cancellable else {
//            return
//        }
//        self.insert(cancellable)
//    }
//    /// Remove a cancellable from the cancellables storage
//    /// - Parameter cancellable: the cancellable to remove
//
//    @available(*, deprecated, message: "Use Set<AnyCancellable?> if possible")
//    mutating func remove(_ cancellable:AnyCancellable?) {
//        guard let cancellable = cancellable else {
//            return
//        }
//        self.remove(cancellable)
//    }
//}
//
