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

enum ActivityContentSelection: String, CaseIterable, Hashable {
    case image = "Bild", emoji = "Emoji", objects = "Objekt/Föremål"
    public var id: Self { self }
}

public struct InventoryCategory {
    let misc:InventoryCategoryType = InventoryCategoryType(id: "misc", displayName: "Diverse")
    let animals:InventoryCategoryType = InventoryCategoryType(id: "animals", displayName: "Djur")
    let songs:InventoryCategoryType = InventoryCategoryType(id: "songs", displayName: "Sånger")
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

public class RecreationService: CTS<RecreationServiceType,RecreationStorageService>,LBTranslatableContentProvider, LBDashboardItem, LBAdminService {
    
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
    
    public var stringsToTranslatePublisher: AnyPublisher<[String], Never> {
        return $stringsToTranslate.eraseToAnyPublisher()
    }
    
    @Published public var stringsToTranslate: [String] = []
    
    
    public convenience init() {
        self.init(
            emptyValue: [],
            storageOptions: .init(filename: "Recreation", foldername: "RecreationService", bundleFilename:"Recreation", bundle:.module)
        )
        
        Task{
            await self.load()
        }
        
        $data.sink { [weak self] data in
            var strings = [String]()
            
            guard let _ = self else {
                return
            }
            
            for recreation in data {
                recreation.activities.forEach({ activity in
                    strings.append(activity.name)
                    if let imageOrEmojiDescription = activity.imageOrEmojiDescription {
                        strings.append(imageOrEmojiDescription)
                    }
                    strings.append(activity.sentence)
                    if let _ = activity.objectSentence {
                        strings.append(activity.objectSentence!)
                    }
                    
                    activity.inventories.forEach({inventory in
                        strings.append(inventory.description)
                    })
                })
                recreation.inventories.forEach({inventory in
                    inventory.items.forEach({inventoryItem in
                        strings.append(inventoryItem.name)
                        strings.append(inventoryItem.prefix)
                        strings.append(inventoryItem.itemDescription())
                    })
                })
            }
            
            strings.forEach({string in
                if !self!.stringsToTranslate.contains(string){
                    self?.stringsToTranslate.append(string)
                }
            })
            
        }.store(in: &cancellables)
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
    
    
    func toggleEnabledFlag(type: RecreationType, inventoryType: String? = nil, id: String){

        switch type {
        case .Inventory:
            
            if let inventoryType = inventoryType,
               let inventoryIndex = data[defaultIndexForRecreationObject].inventories.firstIndex(where: {$0.id == inventoryType}),
               let index = data[defaultIndexForRecreationObject].inventories[inventoryIndex].items.firstIndex(where: {$0.id == id}) {
               
                data[defaultIndexForRecreationObject].inventories[inventoryIndex].items[index].isActive.toggle()
            }
        case .Activity:
            if let index = data[defaultIndexForRecreationObject].activities.firstIndex(where: {$0.id == id}) {
                
                data[defaultIndexForRecreationObject].activities[index].isActive.toggle()
            }
        }
     
        Task{
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
    
    //MANAGE ACTIVITIES
    func update(_ activity:Recreation.Activity){
        guard let index = recreation.activities.firstIndex(where: { $0.id == activity.id }) else {
            data[0].activities.append(activity)
            return
        }
        data[0].activities[index] = activity
    }
    
    func delete(_ activity:Recreation.Activity) {
        guard let index = recreation.activities.firstIndex(where: { $0.id == activity.id }) else {
            data[0].activities.append(activity)
            return
        }
        data[0].activities.remove(at: index)
    }
    
    func deleteActivity(at offsets: IndexSet) {
        data[0].activities.remove(atOffsets: offsets)
        
        Task {
            await self.save()
        }
    }
    
    
    
    // MANAGE ITEMS
    func update(_ item:Recreation.Inventory.Item, type:InventoryType){
       
        switch type {
        case .misc:
            if let index = data[defaultIndexForRecreationObject].inventories.firstIndex(where: {$0.id == InventoryType.misc.rawValue }){
              
                if let itemIndex = data[defaultIndexForRecreationObject].inventories[index].items.firstIndex(where: {$0.id == item.id})  {
                    
                    data[defaultIndexForRecreationObject].inventories[index].items[itemIndex] = item
                }else{
                    data[defaultIndexForRecreationObject].inventories[index].items.append(item)
                }
            }
        case .animals:
            if let index = data[defaultIndexForRecreationObject].inventories.firstIndex(where: {$0.id == InventoryType.animals.rawValue }){
              
                if let itemIndex = data[defaultIndexForRecreationObject].inventories[index].items.firstIndex(where: {$0.id == item.id})  {
                    
                    data[defaultIndexForRecreationObject].inventories[index].items[itemIndex] = item
                }else{
                    data[defaultIndexForRecreationObject].inventories[index].items.append(item)
                }
            }
        case .songs:
            if let index = data[defaultIndexForRecreationObject].inventories.firstIndex(where: {$0.id == InventoryType.songs.rawValue }){
              
                if let itemIndex = data[defaultIndexForRecreationObject].inventories[index].items.firstIndex(where: {$0.id == item.id})  {
                    
                    data[defaultIndexForRecreationObject].inventories[index].items[itemIndex] = item
                }else{
                    data[defaultIndexForRecreationObject].inventories[index].items.append(item)
                }
            }
        }
    }
    
    func deleteInventoryItem(itemId:String? = nil, at offsets: IndexSet? = nil, inventoryType:InventoryType, callback: (() -> Void)? = nil) {
        
        var inventoryTypeIndex:Int?
        switch inventoryType {
        case .misc:
            if let index = data[defaultIndexForRecreationObject].inventories.firstIndex(where: {$0.id == InventoryType.misc.rawValue }) {
                
                inventoryTypeIndex = index
                
            }
        case .animals:
            if let index = data[defaultIndexForRecreationObject].inventories.firstIndex(where: {$0.id == InventoryType.animals.rawValue }) {
                
                inventoryTypeIndex = index
            }
        case .songs:
            if let index = data[defaultIndexForRecreationObject].inventories.firstIndex(where: {$0.id == InventoryType.songs.rawValue }) {
                
                inventoryTypeIndex = index
            }
        }
        
        
        if let index = inventoryTypeIndex {
            if let offset = offsets {
                data[defaultIndexForRecreationObject].inventories[index].items.remove(atOffsets: offset)
            
            }else if let id = itemId {
                data[defaultIndexForRecreationObject].inventories[index].items.removeAll(where: {$0.id == id})
            }
        }
    }
}
