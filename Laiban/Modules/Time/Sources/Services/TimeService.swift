//
//  TimeService.swift
//  LaibanApp
//
//  Created by Tomas Green on 2022-05-17.
//

import Combine
import Foundation

import SwiftUI

public class TimeService: CTS<TimeServiceModel, CodableLocalJSONService<TimeServiceModel>>, LBAdminService,LBDashboardItem {
    public let viewIdentity: LBViewIdentity = .time
    public var isAvailablePublisher: AnyPublisher<Bool, Never> {
        $isAvailable.eraseToAnyPublisher()
    }
    @Published public private(set) var isAvailable: Bool = true
    public var id: String = "TimeService"
    public var listOrderPriority: Int = 1
    public var listViewSection = LBAdminListViewSection(id: "TimeServiceSection", title: "Klockan", listOrderPriority: .basic.after)
    public func adminView() -> AnyView {
        AnyView(TimeAdminView(service: self))
    }

    public convenience init() {
        self.init(
            emptyValue: TimeServiceModel(),
            storageOptions: .init(filename: "TimeData", foldername: "TimeService")
        )
    }
}
