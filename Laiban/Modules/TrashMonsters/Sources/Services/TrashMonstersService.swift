//
//  Created by Tomas Green on 2022-06-07.
//

import Foundation

import Combine

public class TrashMonstersService: ObservableObject, LBDashboardItem {
    public let viewIdentity: LBViewIdentity = .trashmonster
    public var isAvailablePublisher: AnyPublisher<Bool, Never> {
        $isAvailable.eraseToAnyPublisher()
    }
    @Published public private(set) var isAvailable: Bool = true
    public init() {
        
    }
}
