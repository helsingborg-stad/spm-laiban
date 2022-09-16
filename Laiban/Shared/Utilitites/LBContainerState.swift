//
//  ViewState.swift
//  LaibanApp
//
//  Created by Tomas Green on 2022-04-25.
//

import SwiftUI
import Combine

public struct AnyEquatable {
    public let value: Any
    private let equals: (Any) -> Bool

    public init<T: Equatable>(_ value: T) {
        self.value = value
        self.equals = { ($0 as? T == value) }
    }
}

extension AnyEquatable: Equatable {
    static public func ==(lhs: AnyEquatable, rhs: AnyEquatable) -> Bool {
        return lhs.equals(rhs.value)
    }
    static public func ==(lhs: AnyEquatable, rhs: String) -> Bool {
        return lhs.equals(rhs)
    }
    static public func ==(lhs: String, rhs: AnyEquatable) -> Bool {
        return rhs.equals(lhs)
    }
    
    static public func !=(lhs: AnyEquatable, rhs: AnyEquatable) -> Bool {
        return lhs.equals(rhs.value) == false
    }
    static public func !=(lhs: AnyEquatable, rhs: String) -> Bool {
        return lhs.equals(rhs) == false
    }
    static public func !=(lhs: String, rhs: AnyEquatable) -> Bool {
        return rhs.equals(lhs) == false
    }
    
}
public typealias LBViewState = LBContainerState<LBViewIdentity>
public extension LBContainerState where T == LBViewIdentity {
    convenience init() {
        self.init(rootValue: .home)
    }
}
public struct LBViewIdentity : Equatable, Hashable, Identifiable {
    public let id:String
    public init(_ id:String) {
        self.id = id
    }
}
public extension LBViewIdentity {
    static var activities     = LBViewIdentity("activities-viewidentity")
    static var rateActivities = LBViewIdentity("rate-activities-viewidentity")
    static var calendar       = LBViewIdentity("calendar-viewidentity")
    static var outdoors       = LBViewIdentity("outdoors-viewidentity")
    static var feedback       = LBViewIdentity("feedback-viewidentity")
    static var time           = LBViewIdentity("time-viewidentity")
    static var food           = LBViewIdentity("food-viewidentity")
    static var foodwaste      = LBViewIdentity("foodwaste-viewidentity")
    static var instagram      = LBViewIdentity("instagram-viewidentity")
    static var languages      = LBViewIdentity("languages-viewidentity")
    static var memory         = LBViewIdentity("memory-viewidentity")
    static var noticeboard    = LBViewIdentity("noticeboard-viewidentity")
    static var recreation     = LBViewIdentity("recreation-viewidentity")
    static var singalong      = LBViewIdentity("singalong-viewidentity")
    static var trashmonster   = LBViewIdentity("trashmonster-viewidentity")
    static var undpinfo       = LBViewIdentity("undpinfo-viewidentity")
    static var home           = LBViewIdentity("home-viewidentity")
}


public class LBContainerState<T:Equatable & Hashable>: ObservableObject {
    struct Config  {
        var characterHidden:Bool = false
        var characterImage:Image? = nil
        var characterPosition:LBCharacterConfig.Position = .center
        var actionButtons:[LBFullscreenContainerButton] = [.languages,.home]
        var options:AnyEquatable?
        var inactivityTimerDisabled:Bool = false
    }
    private var cancellables = Set<AnyCancellable>()
    private var inactivityTimer:Timer? = nil
    private let inactivitySubject = PassthroughSubject<Void,Never>()
    public var inactivityTimeInterval:TimeInterval = 60
    public let inactivityPublisher:AnyPublisher<Void,Never>
    public let interactionSubject = PassthroughSubject<Void,Never>()
    @Published public private(set) var previousValue:T? = nil
    @Published public private(set) var value:T
    @Published public private(set) var rootValue:T
    @Published public private(set) var characterHidden:Bool = false
    @Published public private(set) var characterImage:Image? = nil
    @Published public private(set) var characterPosition:LBCharacterConfig.Position = .right
    @Published public private(set) var actionButtons:[LBFullscreenContainerButton] = [.languages,.admin]
    @Published public private(set) var options:AnyEquatable?
    @Published public private(set) var inactivityTimerDisabled:Bool = true
    public init(rootValue:T) {
        self.rootValue = rootValue
        self.value = rootValue
        inactivityPublisher = inactivitySubject.eraseToAnyPublisher()
        inactivitySubject.sink { [weak self] in
            self?.resetInactivityTimer()
        }.store(in: &cancellables)
    }
    private var states:[T:Config] = [:]
    private var rootState = Config(characterPosition: .right, actionButtons: [.languages,.admin],inactivityTimerDisabled: true)
    private var defaultState = Config(characterPosition: .center, actionButtons: [.home,.languages])
    private func update(using state:Config) {
        if characterHidden != state.characterHidden {
            characterHidden = state.characterHidden
        }
        if characterImage != state.characterImage {
            characterImage = state.characterImage
        }
        if characterPosition != state.characterPosition {
            characterPosition = state.characterPosition
        }
        if actionButtons != state.actionButtons {
            actionButtons = state.actionButtons
        }
        if options != state.options {
            options = state.options
        }
        
        inactivityTimerDisabled = state.inactivityTimerDisabled
        resetInactivityTimer()
    }
    private func set(_ state:Config, for value:T?) {
        if let value = value {
            self.states[value] = state
            if self.value == value {
                update(using: state)
            }
        } else {
            self.rootState = state
            if self.value == rootValue {
                update(using: state)
            }
        }
    }
    private func state(for value:T?) -> Config {
        guard let value = value else {
            return rootState
        }
        guard let state = states[value] else {
            return defaultState
        }
        return state
    }
    public func inactivityTimerDisabled(_ disabled:Bool, for value:T) {
        var state = state(for: value)
        state.inactivityTimerDisabled = disabled
        set(state, for: value)
    }
    public func characterHidden(_ hidden:Bool, for value:T) {
        var state = state(for: value)
        state.characterHidden = hidden
        set(state, for: value)
    }
    public func characterImage(_ image:Image?, for value:T) {
        var state = state(for: value)
        state.characterImage = image
        set(state, for: value)
    }
    public func characterPosition(_ position:LBCharacterConfig.Position, for value:T) {
        var state = state(for: value)
        state.characterPosition = position
        set(state, for: value)
    }
    public func clearOptions(for value:T){
        var state = state(for: value)
        state.options = nil
        set(state, for: value)
    }
    public func options<V>(_ options:V, for value:T) where V: Equatable {
        var state = state(for: value)
        state.options = .init(options)
        set(state, for: value)
    }
    public func actionButtons(_ actionButtons:[LBFullscreenContainerButton], for value:T) {
        var state = state(for: value)
        state.actionButtons = actionButtons
        set(state, for: value)
    }
    public func clear() {
        if self.value == rootValue {
            return
        }
        self.value = rootValue
        update(using: rootState)
    }
    public func dismiss() {
        guard let value = previousValue else {
            clear()
            return
        }
        navigate(to: value)
    }
    public func present(_ value: T) {
        previousValue = self.value
        self.navigate(to: value)
    }
    public func navigate(to value: T) {
        if self.value == value {
            return
        }
        self.value = value
        update(using: state(for: value))
    }
    public func registerInteraction() {
        interactionSubject.send()
    }
    private func resetInactivityTimer() {
        inactivityTimer?.invalidate()
        inactivityTimer = nil
        if inactivityTimeInterval < 1 || inactivityTimerDisabled {
            return
        }
        inactivityTimer = Timer.scheduledTimer(withTimeInterval: inactivityTimeInterval, repeats: true, block: { [weak self] timer in
            self?.inactivitySubject.send()
            withAnimation(.spring()) {
                self?.clear()
            }
        })
    }
}

