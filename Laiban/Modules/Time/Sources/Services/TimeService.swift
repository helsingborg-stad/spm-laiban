//
//  TimeService.swift
//  LaibanApp
//
//  Created by Tomas Green on 2022-05-17.
//

import Combine
import Foundation

import SwiftUI

public class TimeService: CTS<TimeServiceModel, CodableLocalJSONService<TimeServiceModel>>, LBAdminService, LBDashboardItem,LBTranslatableContentProvider {
    public var stringsToTranslatePublisher: AnyPublisher<[String], Never> {
        return $stringsToTranslate.eraseToAnyPublisher()
    }
    public var cancellables = Set<AnyCancellable>()
    @Published public var stringsToTranslate: [String] = []
    
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
            emptyValue: TimeServiceModel(events:Self.defaultValues),
            storageOptions: .init(filename: "TimeData", foldername: "TimeService")
        )
        $data.sink { [weak self] val in
            var strings = [String]()
            for e in val.events {
                if let text = e.text {
                    strings.append(text)
                } else {
                    strings.append(e.title)
                }
            }
            self?.stringsToTranslate = strings
        }.store(in: &cancellables)
    }
    /// move to service
    static var defaultValues:[ClockEvent] {
        var arr = [ClockEvent]()
        arr.append(ClockEvent(time: "07:00", emoji: "🥣", title: "Frukost"))
        arr.append(ClockEvent(time: "09:00", emoji: "🍎", title: "Fruktstund"))
        arr.append(ClockEvent(time: "11:30", emoji: "🍽", title: "Lunch"))
        arr.append(ClockEvent(time: "14:30", emoji: "🥪", title: "Mellanmål"))
        return arr
    }
}
