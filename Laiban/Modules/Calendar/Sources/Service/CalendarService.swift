//
//  CalendarService.swift
//  LaibanApp
//
//  Created by Ehsan Zilaei on 2022-05-12.
//

import Foundation

import SwiftUI
import PublicCalendar
import Combine

public typealias CalendarServiceType = [CalendarEvent]
public typealias CalendarStorageService = CodableLocalJSONService<CalendarServiceType>

public class CalendarService: CTS<CalendarServiceType, CalendarStorageService>, LBAdminService,LBDashboardItem,LBTranslatableContentProvider {
    public let viewIdentity: LBViewIdentity = .calendar
    public var isAvailablePublisher: AnyPublisher<Bool, Never> {
        $isAvailable.eraseToAnyPublisher()
    }
    @Published public private(set) var isAvailable: Bool = true
    
    public var id: String = "CalendarService"
    public var listOrderPriority: Int = 1
    public var listViewSection: LBAdminListViewSection = .content
    
    public var stringsToTranslatePublisher: AnyPublisher<[String], Never> {
        return $stringsToTranslate.eraseToAnyPublisher()
    }
    
    @Published public var stringsToTranslate: [String] = []
    
    
    public convenience init() {
        self.init(
            emptyValue: [],
            storageOptions: .init(filename: "CalendarEvents", foldername: "CalendarService", bundleFilename:"CalendarEvents")
        )
        
        $data.sink { [weak self] data in
            var strings = [String]()
            for e in data {
                strings.append(e.content)
            }
            self?.stringsToTranslate = strings
        }.store(in: &cancellables)
    }
    
    public func adminView() -> AnyView {
        AnyView(CalendarAdminView(service: self))
    }
    
    public func contains(_ item: CalendarEvent) -> Bool {
        data.contains(where: { i in i.id == item.id })
    }
    
    public func remove(_ item: CalendarEvent) {
        data.removeAll { i in item.id == i.id }
    }
    
    public func update(_ item:CalendarEvent) {
        guard let index = data.firstIndex(where: { e in e.id == item.id }) else {
            self.add(item)
            return
        }
        data[index] = item
    }
    
    public func add(_ item:CalendarEvent){
        if contains(item) {
            return
        }
        data.append(item)
        sortCalendarEvents()
    }
    
    public func calendarEvents(on date:Date) -> [CalendarEvent] {
        data.filter { event in event.date.isSameDay(as: date)}
    }
    
    public func sortCalendarEvents() {
        data.sort { (a1, a2) in a1.date > a2.date }
    }
    public var todaysCalendarEvents:[CalendarEvent] {
        Task {
            await load()
        }
        return data.filter { event  in event.date.today == true }
    }
    public func data(on date:Date) -> [CalendarEvent] {
        data.filter { event in event.date.isSameDay(as: date)}
    }
}
