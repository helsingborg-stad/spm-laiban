//
//  StableDiffusionImageGenerator.swift
//  ml-sd-test
//
//  Created by Kenth Ljung on 2023-10-10.
//

import Foundation
import UIKit
import StableDiffusion
import CoreML

enum SDImageGeneratorError: Error {
    case notWarmedUp
    case warmupFailed
    case generateFailed
}

@available(iOS 16.2, *)
public extension StableDiffusionPipeline {
    /// Create a diffusion pipeline with resources already prewarmed
    ///
    /// Mostly copy-paste from StableDiffusionPipeline+Resources.swift.
    /// Required for more granular prewarm progress feedback since the
    /// individual prewarming resources (text encoder, unet etc.) are internal
    /// after pipeline creation.
    @available(iOS 17.0, *)
    static func initPrewarmed(
        resourcesAt: URL,
        controlNetModelNames: [String],
        config: MLModelConfiguration,
        onProgress: (_ progress: Foundation.Progress) -> Void) throws -> StableDiffusionPipeline {
            print("initPrewarmed")
            
            /// Expect URL of each resource
            let urls = ResourceURLs(resourcesAt: resourcesAt)
            let textEncoder: TextEncoderModel
            
            let tokenizer = try BPETokenizer(mergesAt: urls.mergesURL, vocabularyAt: urls.vocabURL)
            textEncoder = TextEncoder(tokenizer: tokenizer, modelAt: urls.textEncoderURL, configuration: config)
            
            // ControlNet model
            var controlNet: ControlNet? = nil
            let controlNetURLs = controlNetModelNames.map { model in
                let fileName = model + ".mlmodelc"
                return urls.controlNetDirURL.appending(path: fileName)
            }
            if !controlNetURLs.isEmpty {
                controlNet = ControlNet(modelAt: controlNetURLs, configuration: config)
            }
            
            // Unet model
            let unet: Unet
            let unetURL: URL, unetChunk1URL: URL, unetChunk2URL: URL
            
            // if ControlNet available, Unet supports additional inputs from ControlNet
            if controlNet == nil {
                unetURL = urls.unetURL
                unetChunk1URL = urls.unetChunk1URL
                unetChunk2URL = urls.unetChunk2URL
            } else {
                unetURL = urls.controlledUnetURL
                unetChunk1URL = urls.controlledUnetChunk1URL
                unetChunk2URL = urls.controlledUnetChunk2URL
            }
            
            if FileManager.default.fileExists(atPath: unetChunk1URL.path) &&
                FileManager.default.fileExists(atPath: unetChunk2URL.path) {
                unet = Unet(chunksAt: [unetChunk1URL, unetChunk2URL],
                            configuration: config)
            } else {
                unet = Unet(modelAt: unetURL, configuration: config)
            }
            
            // Image Decoder
            let decoder = Decoder(modelAt: urls.decoderURL, configuration: config)
            
            // Optional safety checker
            var safetyChecker: SafetyChecker? = nil
            if FileManager.default.fileExists(atPath: urls.safetyCheckerURL.path) {
                safetyChecker = SafetyChecker(modelAt: urls.safetyCheckerURL, configuration: config)
            }
            
            // Optional Image Encoder
            let encoder: Encoder?
            if FileManager.default.fileExists(atPath: urls.encoderURL.path) {
                encoder = Encoder(modelAt: urls.encoderURL, configuration: config)
            } else {
                encoder = nil
            }
            
            // Begin warmup
            let progress = Foundation.Progress(totalUnitCount: 6)
            onProgress(progress)
            
            print("textEncoder.loadResources")
            try textEncoder.loadResources()
            progress.completedUnitCount = 1
            onProgress(progress)
            
            print("unet.loadResources")
            try unet.loadResources()
            progress.completedUnitCount = 2
            onProgress(progress)
            
            print("decoder.loadResources")
            try decoder.loadResources()
            progress.completedUnitCount = 3
            onProgress(progress)
            
            print("encoder?.loadResources")
            try encoder?.loadResources()
            progress.completedUnitCount = 4
            onProgress(progress)
            
            print("controlNet?.loadResources")
            try controlNet?.loadResources()
            progress.completedUnitCount = 5
            onProgress(progress)
            
            print("safetyChecker?.loadResources")
            try safetyChecker?.loadResources()
            progress.completedUnitCount = 6
            onProgress(progress)
            
            let newPipeline = StableDiffusionPipeline(
                textEncoder: textEncoder,
                unet: unet,
                decoder: decoder,
                encoder: encoder,
                controlNet: controlNet,
                safetyChecker: safetyChecker,
                reduceMemory: true,
                useMultilingualTextEncoder: false,
                script: nil
            )
            
            return newPipeline
        }
}

@available(iOS 17, *)
struct StableDiffusionImageGenerator: AIImageGenerator {
    var modelProvider: AIModelProvider
    var pipeline: StableDiffusionPipeline?
    
    init(modelProvider: AIModelProvider) {
        self.modelProvider = modelProvider
    }
    
    mutating func warmup(onProgress: @escaping (_ progress: Progress) -> Void) async throws {
        let modelName = "apple_coreml-stable-diffusion-2-1-base_einsum"
        
        guard pipeline == nil else {
            print("already warmed up")
            return
        }
        print("warming up")
        
        let progress = Progress(totalUnitCount: 200)
        
        if !modelProvider.isModelAvailable(modelName) {
            print("downloading model '\(modelName)'")
            let downloadProgress = Progress(totalUnitCount: 100)
            progress.addChild(downloadProgress, withPendingUnitCount: 100)
            progress.localizedDescription = "laddar ner AI model"
            try await modelProvider.fetchModel(modelName) { fractionDone in
                downloadProgress.completedUnitCount = Int64(floor(fractionDone * 100.0))
                onProgress(progress)
                print("fetch progress: \(fractionDone)")
            }
        } else {
            print("model '\(modelName)' already available")
            progress.completedUnitCount = 100
            progress.localizedDescription = "Sätter upp bildgenerering"
            onProgress(progress)
        }
        
        let modelResourceUrl = try modelProvider.getStoredModelURL(modelName)
        
        let config = MLModelConfiguration()
        config.computeUnits = .all
        
        if let newPipeline = try? StableDiffusionPipeline.initPrewarmed(resourcesAt: modelResourceUrl, controlNetModelNames: [], config: config, onProgress: { warmupProgress in
            let count = Int64(floor(warmupProgress.fractionCompleted * 100))
            print("count = \(count)")
            progress.completedUnitCount = 100 + count
            progress.localizedDescription = "Laddar in data"
            onProgress(progress)
        }) {
            pipeline = newPipeline
        } else {
            throw SDImageGeneratorError.warmupFailed
        }
        
        progress.completedUnitCount = 200
        progress.localizedDescription = "Redo att generera bilder!"
        onProgress(progress)
    }
    
    func generate(positivePrompt: String, negativePrompt: String, onProgress: (Float, UIImage?) -> Void) async throws -> UIImage {
        guard pipeline != nil else {
            throw SDImageGeneratorError.notWarmedUp
        }
        
        var configuration = StableDiffusionPipeline.Configuration(prompt: positivePrompt)
        configuration.negativePrompt = negativePrompt
        configuration.imageCount = 1
        configuration.seed = UInt32.random(in: 0...1_000_000)
        configuration.stepCount = 15
        configuration.guidanceScale = 7.0
        configuration.disableSafety = false
        configuration.schedulerType = .pndmScheduler
        
        print("generate seed: \(configuration.seed)")
        
        let images = try pipeline!.generateImages(configuration: configuration, progressHandler: { progress in
            let fraction = Float(progress.step) / Float(progress.stepCount)
            
            let firstImage = progress.currentImages.first!
            onProgress(fraction, firstImage != nil ? UIImage(cgImage: firstImage!) : nil)
            return true
        })
        
        guard let firstEntry = images.first, let firstImage = firstEntry else {
            throw SDImageGeneratorError.generateFailed
        }
        
        return UIImage(cgImage: firstImage)
    }
}

