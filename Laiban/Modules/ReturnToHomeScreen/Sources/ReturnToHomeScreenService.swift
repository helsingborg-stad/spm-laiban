//
//  ReturnToHomeScreenService.swift
//  LaibanApp
//
//  Created by Tomas Green on 2022-04-29.
//

import Foundation

import SwiftUI

public class ReturnToHomeScreenService : CTS<ReturnToHomeScreen,CodableLocalJSONService<ReturnToHomeScreen>>, LBAdminService {
    public let id: String = "ReturnToHomeScreenService"
    public let listViewSection: LBAdminListViewSection = .content
    public let listOrderPriority: Int = 10
    public func adminView() -> AnyView {
        AnyView(ReturnToHomeScreenAdminView(service: self))
    }
    public convenience init() {
        self.init(emptyValue: .never, storageOptions: CodableLocalJSONService<ReturnToHomeScreen>.StorageOptions.init(filename: "ReturnToHomeScreen", foldername: "ReturnToHomeScreenService"))
    }
}
