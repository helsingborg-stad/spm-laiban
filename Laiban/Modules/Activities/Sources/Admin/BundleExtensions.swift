//
//  BundleExtensions.swift
//  Laiban
//
//  Created by Tomas Green on 2021-09-22.
//

import Foundation

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
    var versionString: String {
        guard let releaseVersionNumber = releaseVersionNumber else {
            return "okänd"
        }
        guard let buildVersionNumber = buildVersionNumber else {
            return "okänd"
        }
        return "\(releaseVersionNumber) (\(buildVersionNumber))"
    }
    var laibanVersion: String {
        guard let configuration = (Bundle.main.infoDictionary?["AppSettingsConfig"] as? String) else {
            return versionString
        }
        return configuration + " " + versionString
    }
}
