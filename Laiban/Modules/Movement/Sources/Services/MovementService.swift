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

public typealias MovementData = [MovementManager.Movement]
public typealias MovementStorageService = CodableLocalJSONService<MovementData>


public protocol MovementStorage {
    func remove(_ item: MovementManager.Movement)
    func update(_ item: MovementManager.Movement)
    func add(_ item: MovementManager.Movement)
    func getData() -> MovementData
    func save(movements: MovementData)
}

public class MovementService: CTS<MovementData, MovementStorageService>, LBAdminService, LBDashboardItem, MovementStorage {
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
    // @Published public var food:[String]? = nil
    @Published public var backendStorageEnabled = false
    public func adminView() -> AnyView {
        AnyView(MovementAdminView(service: self))
    }
    
    public convenience init() {
        self.init(
            emptyValue: [],
            storageOptions: .init(filename: "MovementData", foldername: "MovementService", bundleFilename:"MovementData", bundle:.module)
        )
        movementManager.delegate = self
        
        $data.sink { [weak self] values in
            self?.movementManager.updateData(newData: values)
        }.store(in: &cancellables)
    }
    
    public func remove(_ item: MovementManager.Movement) {
        data.removeAll(where: { $0.id == item.id })
    }
    
    public func update(_ item: MovementManager.Movement) {
        if let index = data.firstIndex(where: { $0.id == item.id }) {
            data[index] = item
        } else {
            add(item)
        }
    }
    
    public func add(_ item: MovementManager.Movement) {
        if data.contains(where: {$0.id == item.id}) {
            return
        }
        data.append(item)
    }
    
    public func getData() -> MovementData {
        print("Data: \(data.count)")
        return data
    }
    
    @MainActor public func save(movements: MovementData) {
        data = movements
        save()
    }
}

