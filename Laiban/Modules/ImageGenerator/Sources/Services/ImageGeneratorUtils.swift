//
//  File.swift
//  
//
//  Created by Kenth Ljung on 2023-11-28.
//

import Foundation

class ImageGeneratorUtils {
    static func withBenchmark(_ tag: String, _ block: () async throws -> Void) async throws {
        let start = Date()
        try await block()
        let end = Date()
        let time = end.timeIntervalSince(start)
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        let formattedString = formatter.string(from: time)
        
        print("'\(tag)' done. Took \(formattedString ?? "?")")
    }
}
