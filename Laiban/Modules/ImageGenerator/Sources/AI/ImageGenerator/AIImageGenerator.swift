//
//  AIImageGenerator.swift
//  ml-sd-test
//
//  Created by Kenth Ljung on 2023-10-10.
//

import Foundation
import UIKit

struct ImageGeneratorParameters {
    var positivePrompt: String
    var negativePrompt: String
    var seed: UInt32
    var scale: Float
    
    init(positivePrompt: String, negativePrompt: String, seed: UInt32, scale: Float) {
        self.positivePrompt = positivePrompt
        self.negativePrompt = negativePrompt
        self.seed = seed
        self.scale = scale
    }
}

protocol AIImageGenerator {
    mutating func warmup(onProgress: @escaping (_ progress: Progress) -> Void) async throws
    func generate(positivePrompt: String, negativePrompt: String, onProgress: (_ fractionDone: Float, _ partialImage: UIImage?) -> Void) async throws -> UIImage
}
