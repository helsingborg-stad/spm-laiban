//
//  LaibanString.swift
//
//  Created by Tomas Green on 2020-05-25.
//

import Foundation

public struct LBVoiceString: Identifiable {
    public var display:String
    public var voice:String
    public var id:String
    public var object:AnyHashable? = nil
    public init(_ string:String, id:String = UUID().uuidString, object:AnyHashable? = nil) {
        self.id = id
        self.display = string
        self.voice = string
        self.object = object
    }
    public init(display:String, voice:String, object:AnyHashable? = nil, id:String = UUID().uuidString) {
        self.display = display
        self.voice = voice
        self.id = id
        self.object = object
    }
}
