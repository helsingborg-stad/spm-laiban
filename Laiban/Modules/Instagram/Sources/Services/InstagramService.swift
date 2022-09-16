//
//  InstagramService.swift
//  LaibanApp
//
//  Created by Jonatan Hanson on 2022-05-04.
//

import Foundation
import Instagram

import SwiftUI
import Combine

public class InstagramService: ObservableObject, LBAdminService, LBTranslatableContentProvider,LBDashboardItem {
    public let viewIdentity: LBViewIdentity = .instagram
    public var isAvailablePublisher: AnyPublisher<Bool, Never> {
        $isAvailable.eraseToAnyPublisher()
    }
    @Published public private(set) var isAvailable: Bool = false
    public var stringsToTranslatePublisher: AnyPublisher<[String], Never> {
        $stringsToTranslate.eraseToAnyPublisher()
    }
    @Published public private(set) var stringsToTranslate: [String] = []
    public var id: String = "InstagramService"
    public var listOrderPriority: Int = 1
    public var instagram = Instagram(config: nil)
    private var cancellabled = Set<AnyCancellable>()
    public var listViewSection = LBAdminListViewSection(id: "InstagramServiceSection", title: "Instagram", listOrderPriority: .information.before)
    public func adminView() -> AnyView {
        AnyView(InstagramAdminView(service: self))
    }
    public init() {
        instagram.$isAuthenticated.sink(receiveValue: { bool in
            self.isAvailable = bool
        }).store(in: &cancellabled)
       instagram.latest.sink { [weak self] items in
            guard let items = items else {
                return
            }
            var translatableStrings = [String]()
            func addString(_ media:Instagram.Media) {
                guard let c = media.caption else { return }
                translatableStrings.append(c)
            }
            for i in items {
                if i.mediaType == .album {
                    i.children.forEach { c in
                        addString(c)
                    }
                }
                addString(i)
            }
            self?.stringsToTranslate = translatableStrings
        }.store(in: &cancellabled)
    }
    public func resetToDefaults() {
        instagram.logout()
    }

    public func delete() {
        instagram.logout()
    }
}
