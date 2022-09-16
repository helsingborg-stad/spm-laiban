//
//  WeatherService.swift
//  LaibanApp
//
//  Created by Jonatan Hanson on 2022-05-12.
//

import Combine
import Foundation

import SwiftUI
import Weather

public class OutdoorsService: CTS<WeatherServiceModel, CodableLocalJSONService<WeatherServiceModel>>, LBAdminService, LBDashboardItem {
    public let viewIdentity: LBViewIdentity = .outdoors
    public var isAvailablePublisher: AnyPublisher<Bool, Never> {
        $isAvailable.eraseToAnyPublisher()
    }
    @Published public private(set) var isAvailable: Bool = false
    public var id: String = "OutdoorsService"
    public var listOrderPriority: Int = 1
    public var listViewSection = LBAdminListViewSection(id: "WeatherServiceSection", title: "Väder och kläder", listOrderPriority: .content)

    @Published public var weather: WeatherData? = nil
    public var dataService = Weather(service: SMHIForecastService(), previewData: LBDevice.isPreview)
    public var garmentStore = GarmentStore()
    public var dataCancellable: AnyCancellable?
    public var cancellables = Set<AnyCancellable>()
    public func adminView() -> AnyView {
        AnyView(WeatherAdminView(service: self))
    }

    public convenience init() {
        self.init(
            emptyValue: WeatherServiceModel(),
            storageOptions: .init(filename: "WeatherData", foldername: "WeatherService")
        )

        dataCancellable = $data.sink { [dataService] model in
            if let coordinates = model.coordinates {
                dataService.coordinates = .init(latitude: coordinates.latitude, longitude: coordinates.longitude)
                self.isAvailable = true
            } else {
                dataService.coordinates = nil
                self.isAvailable = false
            }
        }

        dataService.closest().sink { data in
            self.weather = data
        }.store(in: &cancellables)
    }
}
