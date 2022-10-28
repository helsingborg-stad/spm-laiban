//
//  Created by Tomas Green on 2022-06-07.
//

import Foundation
import SwiftUI
import Combine

public typealias RecreationServiceType = [Recreation]
public typealias RecreationStorageService = CodableLocalJSONService<RecreationServiceType>


public enum InventoryType: String, CaseIterable, Identifiable {
    case misc = "misc", animals = "animals", songs = "songs"
    public var id: Self { self }
}


public struct InventoryCategory {
    private let misc:InventoryCategoryType = InventoryCategoryType(id: "misc", displayName: "Diverse")
    private let animals:InventoryCategoryType = InventoryCategoryType(id: "animals", displayName: "Djur")
    private let songs:InventoryCategoryType = InventoryCategoryType(id: "songs", displayName: "Sånger")
    let all:[InventoryCategoryType]
    
    init() {
        all = [misc,animals,songs]
    }
}


public struct InventoryCategoryType:Identifiable {
    public let id:String
    let displayName:String
}


enum RecreationType {
    case Inventory
    case Activity
}

public class RecreationService: CTS<RecreationServiceType,RecreationStorageService>, LBDashboardItem, LBAdminService {
    
    private let defaultIndexForRecreationObject = 0
    
    public var id: String = "RecreationService"
    public var listOrderPriority: Int = 15
    public var listViewSection: LBAdminListViewSection = .content
    
    public let viewIdentity: LBViewIdentity = .recreation
    public var isAvailablePublisher: AnyPublisher<Bool, Never> {
        $isAvailable.eraseToAnyPublisher()
    }
    @Published public private(set) var isAvailable: Bool = true
    
    public func adminView() -> AnyView {
        AnyView(RecreationAdminView(service: self))
    }
    
    public var cancellables = Set<AnyCancellable>()
    
    
    public convenience init() {
        self.init(
            emptyValue: [],
            storageOptions: .init(filename: "Recreation", foldername: "RecreationService", bundleFilename:"Recreation", bundle:.module)
        )
        
        Task {
            await self.load()
        }
       
    }
    
    public var recreation:Recreation {
        
        return data[0]
    }
    
    func getRecreation() -> Recreation {
        
        guard var recreation = self.data.first else {
            return Recreation()
        }
        
        recreation.activities = recreation.activities.filter({$0.isActive})
        
        recreation.inventories.forEach({ inventory in
            if let index = recreation.inventories.firstIndex(where: {$0.id == inventory.id}) {
                recreation.inventories[index].items = recreation.inventories[index].items.filter({$0.isActive})
            }
        })
        
        return recreation
    }
    
    func addActivity(newActivity:Recreation.Activity, callback: () -> Void) {
        
        data[defaultIndexForRecreationObject].activities.append(newActivity)
        
        Task {
            await self.save()
        }
        
        callback()
    }
    
    
    func deleteActivity(at offsets: IndexSet) {
        data[0].activities.remove(atOffsets: offsets)
        
        Task {
            await self.save()
        }
    }
    
    func toggleEnabledFlag(type: RecreationType, inventoryType: String? = nil, id: String){
    
        switch type {
        case .Inventory:
            
            if let inventoryType = inventoryType,
               let inventoryIndex = data[defaultIndexForRecreationObject].inventories.firstIndex(where: {$0.name == inventoryType}),
               let index = data[defaultIndexForRecreationObject].inventories[inventoryIndex].items.firstIndex(where: {$0.id == id}) {
               
                data[defaultIndexForRecreationObject].inventories[inventoryIndex].items[index].isActive = data[defaultIndexForRecreationObject].inventories[inventoryIndex].items[index].isActive ? false : true
            }
        case .Activity:
            if let index = data[defaultIndexForRecreationObject].activities.firstIndex(where: {$0.id == id}) {
                data[defaultIndexForRecreationObject].activities[index].isActive = data[defaultIndexForRecreationObject].activities[index].isActive ? false : true
            }
        }
        
        Task{
            await self.save()
        }
    }
    
    
    func addInventoryItem(type:InventoryType, inventoryItem:Recreation.Inventory.Item, callback: () -> Void){
        
        switch type {
        case .misc:
            if let index = data[defaultIndexForRecreationObject].inventories.firstIndex(where: {$0.id == InventoryType.misc.rawValue }) {
                data[defaultIndexForRecreationObject].inventories[index].items.append(inventoryItem)
            }
        case .animals:
            if let index = data[defaultIndexForRecreationObject].inventories.firstIndex(where: {$0.id == InventoryType.animals.rawValue }) {
                data[defaultIndexForRecreationObject].inventories[index].items.append(inventoryItem)
            }
        case .songs:
            if let index = data[defaultIndexForRecreationObject].inventories.firstIndex(where: {$0.id == InventoryType.songs.rawValue }) {
                data[defaultIndexForRecreationObject].inventories[index].items.append(inventoryItem)
            }
        }
        
        Task {
            await self.save()
        }
        
        callback()
    }
    
    func deleteInventoryItem(at offsets: IndexSet, inventoryType:InventoryType) {
        
        switch inventoryType {
        case .misc:
            if let index = data[defaultIndexForRecreationObject].inventories.firstIndex(where: {$0.id == InventoryType.misc.rawValue }) {
                data[defaultIndexForRecreationObject].inventories[index].items.remove(atOffsets: offsets)
            }
        case .animals:
            if let index = data[defaultIndexForRecreationObject].inventories.firstIndex(where: {$0.id == InventoryType.animals.rawValue }) {
                data[defaultIndexForRecreationObject].inventories[index].items.remove(atOffsets: offsets)
            }
        case .songs:
            if let index = data[defaultIndexForRecreationObject].inventories.firstIndex(where: {$0.id == InventoryType.songs.rawValue }) {
                data[defaultIndexForRecreationObject].inventories[index].items.remove(atOffsets: offsets)
            }
        }
        
        Task {
            await self.save()
        }
    }
    
    func randomInventoryItemFor(inventoryType:InventoryType) -> Recreation.Inventory.Item? {
        
        var item:Recreation.Inventory.Item? = nil
        
        switch inventoryType {
        case .misc:
            if let index = recreation.inventories.firstIndex(where: {$0.id == InventoryType.misc.rawValue }) {
                 item = recreation.inventories[index].items.randomElement()
            }
            
        case .animals:
            if let index = recreation.inventories.firstIndex(where: {$0.id == InventoryType.animals.rawValue }) {
                item =  recreation.inventories[index].items.randomElement()
            }
        case .songs:
            if let index = recreation.inventories.firstIndex(where: {$0.id == InventoryType.songs.rawValue }) {
                item =  recreation.inventories[index].items.randomElement()
            }
        }
        
        return item
    }
    
}
