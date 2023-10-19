//
//  MyCustomService.swift
//  LaibanExample
//
//  Created by Tomas Green on 2022-09-19.
//

import Foundation
import Combine

public extension LBViewIdentity {
    static let imageGenerator = LBViewIdentity("ImageGeneratorService")
}

public class ImageGeneratorService : ObservableObject,LBDashboardItem {
    public var isAvailablePublisher: AnyPublisher<Bool, Never> {
        $isAvailable.eraseToAnyPublisher()
    }
    @Published public var isAvailable: Bool = true
    public var viewIdentity: LBViewIdentity = .imageGenerator
    
    public init() {
        
    }
}
