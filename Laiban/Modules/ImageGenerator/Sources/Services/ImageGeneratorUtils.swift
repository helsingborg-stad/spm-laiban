//
//  File.swift
//  
//
//  Created by Kenth Ljung on 2023-11-28.
//

import Foundation
import Shout

class ImageGeneratorUtils {
    static var Logger = Shout("ImageGenerator")
    
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
        
        Logger.info("'\(tag)' done. Took \(formattedString ?? "?")")
    }
    
    static func getSavedImagesDirectoryUrl() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("imageGenerator/_lastGenerated")
    }
    
    static func getSavedImageIndex(filename: String?) -> Int32 {
        guard let filename = filename else {
            return -1
        }
        
        guard filename.count > 0 else {
            return -1
        }
        
        do {
            let regex = try NSRegularExpression(pattern: "_(\\d+)\\.png$", options: [])
            let matches = regex.matches(in: filename, options: [], range: NSRange(location: 0, length: filename.utf16.count))
            
            guard matches.count > 0 else {
                return -1
            }
            
            let match = matches[0]
            let captureRange = match.range(at: 1)
            let range = Range(captureRange, in: filename)!
            let matchedString = filename[range]
            
            guard let index = Int32(matchedString, radix: 10) else {
                return -1
            }
            
            return index
        } catch {
            return -1
        }
    }
    
    static func sortBySavedIndex(a: String, b: String) -> Bool {
        let ia = getSavedImageIndex(filename: a)
        let ib = getSavedImageIndex(filename: b)
        return ia < ib
    }
    
    static func getSavedImageFilenames() -> [String] {
        do {
            if #available(iOS 16.0, *) {
                let baseUrl = getSavedImagesDirectoryUrl()
                let fileManager = FileManager()
                let allFilenames = try fileManager.contentsOfDirectory(atPath: baseUrl.path())
                
                return allFilenames
                    .filter { filename in
                        return filename.contains(".png") && getSavedImageIndex(filename: filename) >= 0
                    }
                    .sorted(by: sortBySavedIndex)
            }
        } catch {}
            
        return []
    }
    
    static func clearSavedImages() {
        if #available(iOS 16.0, *) {
            do {
                let baseUrl = getSavedImagesDirectoryUrl()
                let fileManager = FileManager()
                try fileManager.removeItem(at: baseUrl)
            } catch {}
        }
    }
}
