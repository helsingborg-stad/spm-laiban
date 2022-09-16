//
//  LBFullscreenContainerExtensions.swift
//  Testing
//
//  Created by Tomas Green on 2022-04-14.
//

import Foundation
import SwiftUI

public extension LBFullscreenContainer {

    func onContainerAction(_ containerAction: @escaping (LBFullscreenContainerAction)-> Void) -> Self {
        return Self(
            backdrop: backdrop,
            ground: ground,
            containerAction: containerAction,
            actionBarButtons: actionBarButtons,
            characterConfig: characterConfig,
            adminServices:adminServices,
            content: content,
            actionBar: actionBar
        )
    }
    func actionBarButtons(_ containerButtons:[LBFullscreenContainerButton]) -> Self {
        return Self(
            backdrop: backdrop,
            ground: ground,
            containerAction: containerAction,
            actionBarButtons: containerButtons,
            characterConfig: characterConfig,
            adminServices:adminServices,
            content: content,
            actionBar: actionBar
        )
    }
    func character(config characterConfig:LBCharacterConfig) -> Self {
        return Self(
            backdrop: backdrop,
            ground: ground,
            containerAction: containerAction,
            actionBarButtons: actionBarButtons,
            characterConfig: characterConfig,
            adminServices:adminServices,
            content: content,
            actionBar: actionBar
        )
    }
    func character(position:LBCharacterConfig.Position) -> Self {
        return Self(
            backdrop: backdrop,
            ground: ground,
            containerAction: containerAction,
            actionBarButtons: actionBarButtons,
            characterConfig: LBCharacterConfig(hidden: characterConfig.hidden, position: position, image: characterConfig.image),
            adminServices:adminServices,
            content: content,
            actionBar: actionBar
        )
    }
    func character(hidden:Bool) -> Self {
        return Self(
            backdrop: backdrop,
            ground: ground,
            containerAction: containerAction,
            actionBarButtons: actionBarButtons,
            characterConfig: LBCharacterConfig(hidden: hidden, position: characterConfig.position, image: characterConfig.image),
            adminServices:adminServices,
            content: content,
            actionBar: actionBar
        )
    }
    func character(image:Image?) -> Self {
        return Self(
            backdrop: backdrop,
            ground: ground,
            containerAction: containerAction,
            actionBarButtons: actionBarButtons,
            characterConfig: LBCharacterConfig(hidden: characterConfig.hidden, position: characterConfig.position, image: image),
            adminServices:adminServices,
            content: content,
            actionBar: actionBar
        )
    }
    func actionBar<B:View>(@ViewBuilder _ actionBar: @escaping (LBAactionBarProperties) -> B) -> LBFullscreenContainer<Content,B> {
        LBFullscreenContainer<Content,B>(
            backdrop: backdrop,
            ground: ground,
            containerAction: containerAction,
            actionBarButtons: actionBarButtons,
            characterConfig: characterConfig,
            adminServices:adminServices,
            content: content,
            actionBar: actionBar
        )
    }
    func adminServices(adminServices:[LBAdminService]) -> Self{
        LBFullscreenContainer(
            backdrop: backdrop,
            ground: ground,
            containerAction: containerAction,
            actionBarButtons: actionBarButtons,
            characterConfig: characterConfig,
            adminServices:adminServices,
            content: content,
            actionBar: actionBar
        )
    }
}
public extension LBFullscreenContainer where ActionBar == EmptyView {
    init(@ViewBuilder content: @escaping (LBFullscreenContainerProperties) -> Content) {
        self.init(content: content, actionBar: { _ in EmptyView() })
    }
}
