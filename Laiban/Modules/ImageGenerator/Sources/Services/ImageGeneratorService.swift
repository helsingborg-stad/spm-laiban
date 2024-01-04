//
//  MyCustomService.swift
//  LaibanExample
//
//  Created by Tomas Green on 2022-09-19.
//

import Foundation
import Combine
import SwiftUI

public extension LBViewIdentity {
    static let imageGenerator = LBViewIdentity("ImageGeneratorService")
}

public typealias ImageGeneratorStorageService = CodableLocalJSONService<ImageGeneratorServiceModel>

@available(iOS 17, *)
public class ImageGeneratorService : CTS<ImageGeneratorServiceModel, ImageGeneratorStorageService>, LBAdminService, LBDashboardItem {
    lazy var manager: AIImageGeneratorManager = AIImageGeneratorManager(service: self)
    
    public convenience init() {
        self.init(
            emptyValue: ImageGeneratorServiceModel(),
            storageOptions: .init(filename: "ImagGeneratorServiceModel", foldername: "ImageGenerator")
        )
    }
    
    ///----------------------------------------
    /// begin LBDashboardItem
    ///----------------------------------------
    public var viewIdentity: LBViewIdentity = .imageGenerator
    
    public var isAvailablePublisher: AnyPublisher<Bool, Never> {
        $isAvailable.eraseToAnyPublisher()
    }
    
    @Published public var isAvailable: Bool = true
    ///----------------------------------------
    /// end LBDashboardItem
    ///----------------------------------------
    
    ///----------------------------------------
    /// begin LBAdminService
    ///----------------------------------------
    public var id: String = "ImageGeneratorService"
    
    public var listOrderPriority: Int = 1
    
    public var listViewSection: LBAdminListViewSection = .init(id: "ImageGenerator", title: "Bildgenerering", listOrderPriority: .content.after)
    
    public func adminView() -> AnyView {
        AnyView(ImageGeneratorAdminView(service: self))
    }
    ///----------------------------------------
    /// end LBAdminService
    ///----------------------------------------

    public func initStartupCheck() {
        if(data.initOnStartup && manager.status == .WaitingForInit) {
            manager.initialize()
        }
    }
}
