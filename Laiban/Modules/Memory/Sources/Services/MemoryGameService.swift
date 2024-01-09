//
//  MemoryGameService.swift
//  LaibanApp
//
//  Created by Tomas Green on 2022-04-29.
//


import SwiftUI
import Combine

public class MemoryGameService : CTS<MemoryGameServiceModel,CodableLocalJSONService<MemoryGameServiceModel>>, LBAdminService,LBDashboardItem {
    public let viewIdentity: LBViewIdentity = .memory
    public var isAvailablePublisher: AnyPublisher<Bool, Never> {
        $isAvailable.eraseToAnyPublisher()
    }
    @Published public private(set) var isAvailable: Bool = false
    public var id: String = "MemoryGameService"
    public var listOrderPriority: Int = 1
    private var cancellabled = Set<AnyCancellable>()
    public var listViewSection = LBAdminListViewSection(id: "MemoryGameServiceSection", title: "Memoryspel", listOrderPriority: .content.after)
    public func adminView() -> AnyView {
        AnyView(MemoryGameServiceAdminView(service: self))
    }
    public convenience init() {
        self.init(emptyValue: MemoryGameServiceModel(), storageOptions: .init(filename: "MemoryGameData", foldername: "MemoryGameService"))
        self.$data.sink { model in
            self.isAvailable = !model.defaultMemoryGames.isEmpty && model.showOnDashboard
        }.store(in: &cancellabled)
    }
}
