//
//  MockImageGenerator.swift
//  ml-sd-test
//
//  Created by Kenth Ljung on 2023-10-10.
//

import Foundation
import UIKit
import SwiftUI

enum MockImageGeneratorError: Error {
    case noPlaceholderImage
}

struct MockImageGenerator: AIImageGenerator {
    func warmup(onProgress: @escaping (_ progress: Progress) -> Void) async throws {
        
        let progress = Progress.init(totalUnitCount: 200)
        
        let dlProgress = Progress.init(totalUnitCount: 100)
        progress.addChild(dlProgress, withPendingUnitCount: 100)
        progress.localizedDescription = "laddar ner..."
        for i in 1...100 {
            dlProgress.completedUnitCount = Int64(i)
            progress.localizedDescription = "laddar ner \(i)/100"
            onProgress(progress)
            try await Task.sleep(nanoseconds: 30_000_000)
        }
        
        let warmupProgress = Progress.init(totalUnitCount: 100)
        progress.addChild(warmupProgress, withPendingUnitCount: 100)
        for i in 1...100 {
            warmupProgress.completedUnitCount = Int64(i)
            progress.localizedDescription = "warmup \(i)/100"
            onProgress(progress)
            try await Task.sleep(nanoseconds: 20_000_000)
        }
        
        
        print("MockImageGenerator warmup done")
    }
    
    func generate(positivePrompt: String, negativePrompt: String, onProgress: (Float, UIImage?) -> Void) async throws -> UIImage {
        guard   let image = UIImage(named: "aiMockGenerate100") else {
            throw MockImageGeneratorError.noPlaceholderImage
        }
        
        for i in 0...5 {
            try await Task.sleep(nanoseconds: 2 * 1_000_000_000)
            
            let imageStep = i * 20
            print("imageStep: \(imageStep)")
            let image = UIImage(named: "aiMockGenerate\(imageStep)")
            onProgress(Float(i) / 5, image)
        }
        
        return image
    }
}
