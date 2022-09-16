//
//  RotationModifier.swift
//  trafikar
//
//  Created by Tomas Green on 2022-03-30.
//

import SwiftUI


public struct DeviceRotationViewModifier: ViewModifier {
    public let action: (UIDeviceOrientation) -> Void

    public func body(content: Content) -> some View {
        content
            .onAppear {
                action(UIDevice.current.orientation)
            }
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.15) {
                    action(UIDevice.current.orientation)
                }
            }
    }
}

public extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}
