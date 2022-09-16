//
//  LanguageService.swift
//  LaibanApp
//
//  Created by Tomas Green on 2022-05-20.
//

import Foundation

import SwiftUI
import Combine

public typealias LanguageStorageService = CodableLocalJSONService<LanguageServiceModel>

public class LanguageService: CTS<LanguageServiceModel, LanguageStorageService>, LBAdminService {
    public var id: String = "LanguageService"
    public var listViewSection: LBAdminListViewSection = .init(id: "Language", title: "Språk, tal och uppläsning", listOrderPriority: .content.after)
    public var listOrderPriority: Int = 1
    public var cancellables = Set<AnyCancellable>()
    @Published public var selectedLanguage:Locale = .current
    public func adminView() -> AnyView {
        AnyView(LanguageAdminView(service: self))
    }
    
    public convenience init() {
        self.init(
            emptyValue: LanguageServiceModel(),
            storageOptions: .init(filename: "LanguageServiceModel", foldername: "LanguageService")
        )
        
    }
}

