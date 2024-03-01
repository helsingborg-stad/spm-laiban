//
//  File.swift
//  
//
//  Created by Kenth Ljung on 2024-02-29.
//

import Foundation
import SwiftUI
import Combine

public typealias ManagedDashboardItem = LBDashboardItem

@available(iOS 15.0, *)
public class DashboardItemVisibilityService: CTS<DashboardItemVisibilityModel, CodableLocalJSONService<DashboardItemVisibilityModel>>, LBAdminService {
    // begin LBAdminService
    public var id: String = "DashboardItemVisibilityService"
    public var listOrderPriority: Int = 1
    public var listViewSection: LBAdminListViewSection = LBAdminListViewSection(id: "DashboardItemVisibilityServiceSection", title: "Hemskärmen", listOrderPriority: .custom(0))
    public func adminView() -> AnyView {
        AnyView(DashboardItemVisibilityServiceAdminView(service: self))
    }
    // end LBAdminService
    
    public var managedServices: [ManagedDashboardItem] = []
    
    public var onVisibilityChanged = PassthroughSubject<(id: LBViewIdentity, visible: Bool), Never>()
    
    public var dashboardItemView: ((_ item: ManagedDashboardItem) -> any View)?
    
    public convenience init() {
        self.init(emptyValue: DashboardItemVisibilityModel(), storageOptions: .init(filename: "DashboardItemVisibilityManagerData", foldername: "DashboardItemVisibilityManager"))
    }
    
    @MainActor public func setVisibility(id: LBViewIdentity, visible: Bool) -> Void {
        data.visibilityMap[id.id] = visible
        onVisibilityChanged.send((id, visible))
        self.save()
    }
    
    public func isVisible(id: LBViewIdentity) -> Bool {
        guard let item = data.visibilityMap.first(where: { $0.key == id.id }) else {
            return true
        }
        return item.value
    }
}
