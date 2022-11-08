//
//  MovementService.swift
//  
//
//  Created by Fredrik Häggbom on 2022-10-25.
//


import Foundation

import Shout
import SwiftUI
import Combine

public typealias MovementStorageService = CodableLocalJSONService<MovementModel>

public protocol MovementStorage {
    func remove(_ item: Movement)
    func update(_ item: Movement)
    func add(_ item: Movement)
    func getData() -> MovementModel
    func save(movements: [Movement])
}

public class MovementService: CTS<MovementModel, MovementStorageService>, LBAdminService, LBDashboardItem, MovementStorage {
    public let viewIdentity: LBViewIdentity = .movement
    public var isAvailablePublisher: AnyPublisher<Bool, Never> {
        $isAvailable.eraseToAnyPublisher()
    }
    @Published public private(set) var isAvailable: Bool = true
    public var id: String = "MovementService"
    public var listViewSection: LBAdminListViewSection = .init(id: "Movement", title: "Rörelse", listOrderPriority: .content.after)
    public var listOrderPriority: Int = 1
    public var cancellables = Set<AnyCancellable>()

    @Published public var movementManager = MovementManager()
    @Published public private(set) var stringsToTranslate: [String] = []
    @Published public var backendStorageEnabled = false
    public func adminView() -> AnyView {
        AnyView(MovementAdminView(service: self))
    }
    
    public convenience init() {
        self.init(
            emptyValue: MovementModel(settings: MovementSettings(maxMetersPerDay: 250000, stepsPerMinute: 100), movement: [], activities: []),
            storageOptions: .init(filename: "MovementData", foldername: "MovementService", bundleFilename:"MovementData", bundle:.module)
        )
        
        movementManager.delegate = self
        
        $data.sink { [weak self] values in
            if let self = self {
                self.movementManager.settings = self.data.settings
                self.movementManager.updateData(newData: values.movement)
            }
            
        }.store(in: &cancellables)
    }
    
    public func remove(_ item: Movement) {
        data.movement.removeAll(where: { $0.id == item.id })
    }
    
    public func update(_ item: Movement) {
        if let index = data.movement.firstIndex(where: { $0.id == item.id }) {
            data.movement[index] = item
        } else {
            add(item)
        }
    }
    
    public func add(_ item: Movement) {
        if data.movement.contains(where: {$0.id == item.id}) {
            return
        }
        data.movement.append(item)
    }

    public func getData() -> MovementModel {
        return data
    }
    
    @MainActor public func save(movements: [Movement]) {
        data.movement = movements
        save()
    }
}

