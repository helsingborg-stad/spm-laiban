//
//  AIImageGenerator.swift
//  ml-sd-test
//
//  Created by Kenth Ljung on 2023-10-10.
//

import Foundation
import UIKit
import Assistant

public struct ImageGeneratorParameters {
    var positivePrompt: String
    var negativePrompt: String
    var shapeImageId: String?
    var seed: UInt32?
    
    init(positivePrompt: String, negativePrompt: String, shapeImageId: String? = nil, seed: UInt32? = nil) {
        self.positivePrompt = positivePrompt
        self.negativePrompt = negativePrompt
        self.shapeImageId = shapeImageId
        self.seed = seed
    }
}

protocol AIImageGenerator {
    mutating func warmup(onProgress: @escaping (_ progress: Progress) -> Void) async throws
    func generate(params: ImageGeneratorParameters, onProgress: (_ fractionDone: Float, _ partialImage: UIImage?) -> Bool) async throws -> UIImage
}

public protocol AIImageGeneratorManagerProtocol {
    var generatedImage: UIImage? { get }
    var statusMessage: String { get }
    func initialize()
    func generateImage(params: ImageGeneratorParameters, onDone: @escaping (_ success: Bool) -> Void)
    func cancelGenerate()
    func provideAssistant(assistant: Assistant)
}
