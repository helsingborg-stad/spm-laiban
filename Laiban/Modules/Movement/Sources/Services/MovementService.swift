//
//  MovementService.swift
//  
//
//  Created by Fredrik Häggbom on 2022-10-25.
//


import Foundation

import Shout
import SwiftUI
import Combine

public typealias MovementStorageService = CodableLocalJSONService<MovementModel>

public protocol MovementStorage {
    func remove(_ item: Movement)
    func update(_ item: Movement)
    func add(_ item: Movement)
    func getData() -> MovementModel
    func save(movements: [Movement])
}

public class MovementService: CTS<MovementModel, MovementStorageService>, LBAdminService, LBDashboardItem, MovementStorage {
    public let viewIdentity: LBViewIdentity = .movement
    public var isAvailablePublisher: AnyPublisher<Bool, Never> {
        $isAvailable.eraseToAnyPublisher()
    }
    @Published public private(set) var isAvailable: Bool = true
    public var id: String = "MovementService"
    public var listViewSection: LBAdminListViewSection = .init(id: "Movement", title: "Rörelse", listOrderPriority: .content.after)
    public var listOrderPriority: Int = 1
    public var cancellables = Set<AnyCancellable>()
    @ObservedObject var viewModel = MovementViewModel()

    @Published public var movementManager = MovementManager()
    @Published public private(set) var stringsToTranslate: [String] = []
    @Published public var backendStorageEnabled = false
    public func adminView() -> AnyView {
        AnyView(MovementAdminView(service: self))
    }
    
    public convenience init() {
        self.init(
            emptyValue: Self.getDefaultModel(),
            storageOptions: .init(filename: "MovementData", foldername: "MovementService", bundleFilename:"MovementData", bundle:.module)
        )

        $data.sink { [weak self] values in
            if let self = self {
                self.movementManager.delegate = self
                self.movementManager.settings = values.settings
                self.movementManager.updateData(newData: values.movement)
                Task {
                    await self.save()
                }
            }
        }.store(in: &cancellables)
    }
    
    public func remove(_ item: Movement) {
        data.movement.removeAll(where: { $0.id == item.id })
    }
    
    public func update(_ item: Movement) {
        if let index = data.movement.firstIndex(where: { $0.id == item.id }) {
            data.movement[index] = item
        } else {
            add(item)
        }
    }
    
    public func add(_ item: Movement) {
        if data.movement.contains(where: {$0.id == item.id}) {
            return
        }
        data.movement.append(item)
    }

    public func getData() -> MovementModel {
        print("Data: \(data)")
        return data
    }
    
    func saveActivity(activity:MovementActivity, callback: @escaping () -> Void = {}) {
        if let index = data.activities.firstIndex(where: {$0.id == activity.id} ) {
            data.activities[index] = activity
            Task {
                await self.save()
                callback()
            }
        } else {
            addActivity(newActivity: activity, callback: {
                callback()
            })
        }
    }

    func addActivity(newActivity:MovementActivity, callback: () -> Void) {
        data.activities.append(newActivity)
        Task {
            await self.save()
        }
        callback()
    }


    func deleteActivity(activity:MovementActivity, callback: () -> Void){
        if let index = data.activities.firstIndex(where: {$0.id == activity.id}){
            data.activities.remove(at: index)
            Task {
                await self.save()
            }
            callback()
        }
    }
    
    func deleteActivity(at offsets: IndexSet) {
        data.activities.remove(atOffsets: offsets)
        Task {
            await self.save()
        }
    }
    
    func toggleEnabled(activity: MovementActivity) {
        if let index = data.activities.firstIndex(where: {$0.id == activity.id}) {
            data.activities[index].isActive.toggle()
        }

        Task{
            await self.save()
        }
    }
    
    @MainActor public func save(movements: [Movement]) {
        data.movement = movements
        print("Data: \(data)")
        save()
    }
    
    private static func getDefaultModel() -> MovementModel {
        MovementModel(
            settings: MovementSettings(maxMetersPerDay: 250000, stepsPerMinute: 100),
            movement: [],
            activities: [
                MovementActivity(id: "1", colorString: "RimColorClock", title: "Springa", emoji: "🏃‍♀️"),
                MovementActivity(id: "2", colorString: "RimColorInstagram", title: "Klättra", emoji: "🧗"),
                MovementActivity(id: "3", colorString: "RimColorActivities", title: "Cykla", emoji: "🚴"),
                MovementActivity(id: "4", colorString: "RimColorInstagram", title: "Jogga", emoji: "🚶"),
                MovementActivity(id: "5", colorString: "RimColorWeather", title: "Dansa", emoji: "💃"),
            ])
    }
}
