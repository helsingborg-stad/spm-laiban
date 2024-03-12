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
import Assistant

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
        reduceMemory: Bool,
        onProgress: (_ progress: Foundation.Progress) -> Void) throws -> StableDiffusionPipeline {
            ImageGeneratorUtils.Logger.info("initPrewarmed")
            
            let progress = Foundation.Progress(totalUnitCount: 6)
            onProgress(progress)
            
            /// Expect URL of each resource
            let urls = ResourceURLs(resourcesAt: resourcesAt)
            let textEncoder: TextEncoderModel
            
            let tokenizer = try BPETokenizer(mergesAt: urls.mergesURL, vocabularyAt: urls.vocabURL)
            textEncoder = TextEncoder(tokenizer: tokenizer, modelAt: urls.textEncoderURL, configuration: config)
            
            // ControlNet model
            ImageGeneratorUtils.Logger.info("control net model name(s): \(controlNetModelNames)")
            var controlNet: ControlNet? = nil
            let controlNetURLs = controlNetModelNames.map { model in
                let fileName = model + ".mlmodelc"
                return urls.controlNetDirURL.appending(path: fileName)
            }
            if !controlNetURLs.isEmpty {
                ImageGeneratorUtils.Logger.info("Loading controlnet(s): \(controlNetURLs)")
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
            let encoder: Encoder? = nil
//            if FileManager.default.fileExists(atPath: urls.encoderURL.path) {
//                encoder = Encoder(modelAt: urls.encoderURL, configuration: config)
//            } else {
//                encoder = nil
//            }
            
            // Begin warmup
            ImageGeneratorUtils.Logger.info("textEncoder.loadResources")
            try textEncoder.loadResources()
            try textEncoder.unloadResources()
            progress.completedUnitCount = 1
            onProgress(progress)
            
            ImageGeneratorUtils.Logger.info("unet.loadResources")
            try unet.loadResources()
            try unet.unloadResources()
            progress.completedUnitCount = 2
            onProgress(progress)
            
            ImageGeneratorUtils.Logger.info("decoder.loadResources")
            try decoder.loadResources()
            try decoder.unloadResources()
            progress.completedUnitCount = 3
            onProgress(progress)
            
            ImageGeneratorUtils.Logger.info("encoder?.loadResources \(encoder != nil)")
            try encoder?.loadResources()
            try encoder?.unloadResources()
            progress.completedUnitCount = 4
            onProgress(progress)
            
            ImageGeneratorUtils.Logger.info("controlNet?.loadResources \(controlNet != nil)")
            try controlNet?.loadResources()
            try controlNet?.unloadResources()
            progress.completedUnitCount = 5
            onProgress(progress)
            
            ImageGeneratorUtils.Logger.info("safetyChecker?.loadResources \(safetyChecker != nil)")
            try safetyChecker?.loadResources()
            try safetyChecker?.unloadResources()
            progress.completedUnitCount = 6
            onProgress(progress)
            
            let newPipeline = StableDiffusionPipeline(
                textEncoder: textEncoder,
                unet: unet,
                decoder: decoder,
                encoder: encoder,
                controlNet: controlNet,
                safetyChecker: safetyChecker,
                reduceMemory: reduceMemory,
                useMultilingualTextEncoder: false,
                script: nil
            )
            
            return newPipeline
        }
}

@available(iOS 17, *)
class StableDiffusionImageGenerator: AIImageGenerator {
    var modelProvider: AIModelProvider
    var pipeline: StableDiffusionPipeline?
    
    var steps: Int
    var scale: Float
    var size: Float
    var reduceMemory: Bool
    var useControlNet: Bool
    
    var assistant: Assistant?
    
    init(modelProvider: AIModelProvider, steps: Int, scale: Float, size: Float, reduceMemory: Bool, useControlNet: Bool) {
        self.modelProvider = modelProvider
        self.steps = steps
        self.scale = scale
        self.size = size
        self.reduceMemory = reduceMemory
        self.useControlNet = useControlNet
        ImageGeneratorUtils.Logger.info("[StableDiffusionImageGenerator] init")
    }
    
    public func updateGenenerationSettings(steps: Int, scale: Float, size: Float, reduceMemory: Bool, useControlNet: Bool) {
        self.steps = steps
        self.scale = scale
        self.size = size
        self.reduceMemory = reduceMemory
        self.useControlNet = useControlNet
    }
    
    func warmup(onProgress: @escaping (_ progress: Progress) -> Void) async throws {
        let modelName = "ai-sd-model"
        
        guard pipeline == nil else {
            ImageGeneratorUtils.Logger.info("already warmed up")
            return
        }
        ImageGeneratorUtils.Logger.info("warming up")
        
        let progress = Progress(totalUnitCount: 200)
        
        if !modelProvider.isModelAvailable(modelName) {
            ImageGeneratorUtils.Logger.info("downloading model")
            let downloadProgress = Progress(totalUnitCount: 100)
            progress.addChild(downloadProgress, withPendingUnitCount: 100)
            try await modelProvider.fetchModel(modelName) { fractionDone in
                downloadProgress.completedUnitCount = Int64(floor(fractionDone * 100.0))
                let percentage = fractionDone * 100
                let formattedPercentage = String(format: "%.0f%%", percentage)
                progress.localizedDescription = self.assistant?.formattedString(forKey: "image_generator_downloading", formattedPercentage)
                onProgress(progress)
            }
            ImageGeneratorUtils.Logger.info("download done")
        } else {
            ImageGeneratorUtils.Logger.info("model '\(modelName)' already available")
            progress.completedUnitCount = 100
            progress.localizedDescription = self.assistant?.string(forKey: "image_generator_setting_up")
            onProgress(progress)
        }
        
        let modelResourceUrl = try modelProvider.getStoredModelURL(modelName)
        
        let config = MLModelConfiguration()
        config.computeUnits = .cpuAndNeuralEngine
        
        do {
            pipeline = try StableDiffusionPipeline.initPrewarmed(
                            resourcesAt: modelResourceUrl,
                            controlNetModelNames: self.useControlNet ? ["LllyasvielSdControlnetScribble"] : [],
                            config: config,
                            reduceMemory: self.reduceMemory,
                            onProgress: { warmupProgress in
                                let count = Int64(floor(warmupProgress.fractionCompleted * 100))
                                let percentage = warmupProgress.fractionCompleted * 100
                                let formattedPercentage = String(format: "%.0f%%", percentage)
                                progress.completedUnitCount = 100 + count
                                progress.localizedDescription = self.assistant?.formattedString(forKey: "image_generator_loading", formattedPercentage)
                                onProgress(progress)
                            })
        } catch {
            ImageGeneratorUtils.Logger.error("warmup failed: \(error)")
            throw SDImageGeneratorError.warmupFailed
        }
        
        progress.completedUnitCount = 200
        progress.localizedDescription = ""
        onProgress(progress)
    }
    
    func generate(params: ImageGeneratorParameters, onProgress: (Float, UIImage?) -> Bool) async throws -> UIImage {
        guard pipeline != nil else {
            throw SDImageGeneratorError.notWarmedUp
        }
        
        var configuration = StableDiffusionPipeline.Configuration(prompt: params.positivePrompt)
        configuration.negativePrompt = params.negativePrompt
        configuration.imageCount = 1
        configuration.seed = params.seed ?? UInt32.random(in: 0...1_000_000)
        configuration.stepCount = steps
        configuration.guidanceScale = scale
        configuration.disableSafety = false
        configuration.schedulerType = .dpmSolverMultistepScheduler
        configuration.schedulerTimestepSpacing = .karras
        configuration.targetSize = size
        configuration.useDenoisedIntermediates = true
        ImageGeneratorUtils.Logger.info("generate seed: \(configuration.seed), steps: \(configuration.stepCount), size: \(configuration.targetSize)")
        
        if(self.useControlNet) {
            guard let controlNetImage = UIImage(named: params.shapeImageId ?? "cn_scribble_triangle_1", in: .module, with: nil) else {
                ImageGeneratorUtils.Logger.error("controlNetImage not found")
                throw SDImageGeneratorError.generateFailed
            }
            
            guard let cnCgImage = controlNetImage.cgImage else {
                ImageGeneratorUtils.Logger.error("cnCgImage not valid")
                throw SDImageGeneratorError.generateFailed
            }
            configuration.controlNetInputs = [cnCgImage]
        }
        
        let images = try pipeline!.generateImages(configuration: configuration, progressHandler: { progress in
            let fraction = Float(progress.step) / Float(progress.stepCount)
            
            let firstImage = progress.currentImages.first!
            return onProgress(fraction, firstImage != nil ? UIImage(cgImage: firstImage!) : nil)
        })
        
        pipeline!.unloadResources()
        
        guard let firstEntry = images.first, let firstImage = firstEntry else {
            ImageGeneratorUtils.Logger.error("No image generated (unknown error)")
            throw SDImageGeneratorError.generateFailed
        }
        
        return UIImage(cgImage: firstImage)
    }
    
    func provideAssistant(assistant: Assistant) {
        self.assistant = assistant
    }
}
