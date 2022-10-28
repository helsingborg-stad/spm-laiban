//
//  Recreation.swift
//
//  Created by Tomas Green on 2020-09-10.
//

import Foundation
import Combine
import SwiftUI
import Assistant

public struct Recreation : Codable {
    
    var activities:Array<Activity> = []
    var inventories:Array<Inventory> = []
    
    struct Inventory : Codable,Identifiable,Hashable {
       
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        var id:String = UUID().uuidString
        var name:String
        var items:[Item]
       public struct Item : Codable, Identifiable, Hashable {
            
            func hash(into hasher: inout Hasher) {
                hasher.combine(id)
            }
            static let imageStorage = LBImageStorage(folder: "recreationObject")
            var id:String = UUID().uuidString
            var prefix:String
            var name:String
            var imageName:String?
            var emoji:String?
            var isActive:Bool
            init(id:String = UUID().uuidString, prefix: String = "", name:String = "", imageName:String? = nil, emoji:String? = nil, isActive:Bool = true) {
                self.id = id
                self.prefix = prefix
                self.name = name
                self.imageName = imageName
                self.emoji = emoji
                self.isActive = isActive
            }

            func itemDescription() -> String {
                if prefix.count > 0 {
                    return prefix + " " + name
                }
                
                return name
            }
        }
    }
    
    public struct Activity : Codable,Identifiable, Hashable {
        public var id:String = UUID().uuidString
        var name:String
        var sentence:String
        var objectSentence:String?
        var emoji:String
        var inventories:[String] = []{
            willSet{
                if(newValue.count > 0){
                    deleteImage()
                    imageOrEmojiDescription = nil
                }
            }
        }
        var isActive:Bool
        var imageName:String? {
            willSet{
                if newValue != nil {
                    self.activityEmoji = ""
                    self.inventories = []
                }
            }
        }
        var imageOrEmojiDescription: String? = nil
        var activityEmoji:String {
            willSet{
                if newValue != "" {
                    deleteImage()
                }
            }
        }

        static let imageStorage = LBImageStorage(folder: "recreationActivityImages")
        
        func activityDescription(hasObject: Bool, using assistant:Assistant) -> String {
            var result = assistant.string(forKey: sentence)
            if hasObject, let objectSentence = objectSentence {
                result += " " + assistant.string(forKey: objectSentence)
            }
            return result
        }
        
        mutating func deleteImage() {
            Activity.imageStorage.delete(image: self.imageName)
            imageName = nil
        }
    }
}
