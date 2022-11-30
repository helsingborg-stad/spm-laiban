//
//  Device.swift
//
//  Created by Tomas Green on 2020-08-27.
//

import Foundation
import UIKit

public class LBDevice {
    public static var isSimulator:Bool {
        let f:Bool
        #if targetEnvironment(simulator)
        f = true
        #else
        f = false
        #endif
        return f
    }
    // "Does not work from a build copy of an SPM package"
    public static var isDebug:Bool {
        return ProcessInfo.processInfo.environment["DEBUG"] != nil
    }
    public static var isPreview:Bool {
        return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil
    }
    public static var isIpad:Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
}
