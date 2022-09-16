//
//  NoticeboardService.swift
//  LaibanApp
//
//  Created by Tomas Green on 2022-04-27.
//

import Foundation
import Shout
import SwiftUI

import Combine

public typealias NoticeboardServiceType = [Message]
public typealias NoticeboardStorageService = CodableLocalJSONService<NoticeboardServiceType>

public class NoticeboardService : CTS<NoticeboardServiceType,NoticeboardStorageService>, LBAdminService, LBTranslatableContentProvider,LBDashboardItem {
    public let viewIdentity: LBViewIdentity = .noticeboard
    public var isAvailablePublisher: AnyPublisher<Bool, Never> {
        $isAvailable.eraseToAnyPublisher()
    }
    @Published public private(set) var isAvailable: Bool = true
    public var stringsToTranslatePublisher: AnyPublisher<[String], Never> {
        $stringsToTranslate.eraseToAnyPublisher()
    }
    @Published public private(set) var stringsToTranslate: [String] = []
    public var id: String = "NoticeboardService"
    public var listViewSection: LBAdminListViewSection = .content
    public var listOrderPriority: Int = 10
    public var logger = Shout("NoticeboardService")
    public func adminView() -> AnyView {
        AnyView(NoticeboardAdminView(service: self))
    }
    private var changesSubscriber:AnyCancellable?
    public convenience init() {
        self.init(
            emptyValue: [],
            storageOptions: .init(filename: "Messages", foldername: "NoticeboardService", bundleFilename:"Messages", bundle:.module))
        changesSubscriber = $data.sink { [weak self] messages in
            var strings = [String]()
            for message in messages {
                strings.append(message.text)
                strings.append(message.title)
            }
            self?.stringsToTranslate = strings
        }
    }
}

