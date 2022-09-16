//
//  FoodWasteService.swift
//  LaibanApp
//
//  Created by Tomas Green on 2022-05-19.
//


import Foundation

import Shout
import SwiftUI
import Combine

public typealias FoodWasteStorageService = CodableLocalJSONService<FoodWasteServiceModel>

public class FoodWasteService: CTS<FoodWasteServiceModel, FoodWasteStorageService>, LBAdminService,LBDashboardItem {
    public let viewIdentity: LBViewIdentity = .foodwaste
    public var isAvailablePublisher: AnyPublisher<Bool, Never> {
        $isAvailable.eraseToAnyPublisher()
    }
    @Published public private(set) var isAvailable: Bool = true
    public var id: String = "FoodWasteService"
    public var listViewSection: LBAdminListViewSection = .init(id: "FoodWaste", title: "Matsvinn", listOrderPriority: .content.after)
    public var listOrderPriority: Int = 1
    public var cancellables = Set<AnyCancellable>()

    @Published public var wasteManager = FoodWasteManager()
    @Published public private(set) var stringsToTranslate: [String] = []
    @Published public var food:[String]? = nil
    @Published public var backendStorageEnabled = false
    public func adminView() -> AnyView {
        AnyView(FoodWasteAdminView(service: self))
    }
    
    public convenience init() {
        self.init(
            emptyValue: FoodWasteServiceModel(),
            storageOptions: .init(filename: "FoodWasteServiceModel", foldername: "FoodWaste")
        )
    }
}
