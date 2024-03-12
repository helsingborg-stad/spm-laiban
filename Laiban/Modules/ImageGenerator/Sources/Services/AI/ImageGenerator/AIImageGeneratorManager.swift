//
//  AIImageGeneratorManager.swift
//  LaibanExample
//
//  Created by Kenth Ljung on 2023-10-19.
//

import Foundation
import UIKit
import Combine
import Assistant

enum GenerateStatus {
    case WaitingForInit
    case Initializing
    case InitializeFailed
    case Idle
    case Generating
    case GenerateSuccess
    case GenerateFailed
}

@available(iOS 17, *)
@Observable
public class AIImageGeneratorManager : AIImageGeneratorManagerProtocol {
    var imageGenerator: AIImageGenerator
    var status: GenerateStatus
    
    public var statusMessage: String
    public var generatedImage: UIImage?
    
    private var assistant: Assistant?
    private var cancellables = Set<AnyCancellable>()
    
    init(service: ImageGeneratorService) {
        imageGenerator = StableDiffusionImageGenerator(
            modelProvider: UrlModelProvider(rawUrl: service.data.downloadUrl),
            steps: service.data.steps,
            scale: service.data.scale,
            size: Float(service.data.size),
            reduceMemory: service.data.reduceMemory,
            useControlNet: service.data.useControlNet
        )
        
//        imageGenerator = MockImageGenerator()
        
        status = .WaitingForInit
        statusMessage = ""
        generatedImage = nil
        
        service.$data.sink() { _ in
            var sdig = self.imageGenerator as? StableDiffusionImageGenerator
            sdig?.updateGenenerationSettings(
                steps: service.data.steps,
                scale: service.data.scale,
                size: Float(service.data.size),
                reduceMemory: service.data.reduceMemory,
                useControlNet: service.data.useControlNet)
        }.store(in: &cancellables)
    }
    
    public func initialize() {
        Task.init(priority: .high) { [self] in
            guard status == .WaitingForInit else { return }
            
            status = .Initializing
            
            do {
                ImageGeneratorUtils.Logger.info("[AIImageGeneratorManager] warming up...")
                statusMessage = self.assistant?.string(forKey: "image_generator_warmup") ?? "image_generator_warmup"
                
                try await ImageGeneratorUtils.withBenchmark("warmup") {
                    try await imageGenerator.warmup { [self] progress in
                        statusMessage = progress.localizedDescription
                    }
                }
                
                ImageGeneratorUtils.Logger.info("[AIImageGeneratorManager] warmup done")
                status = .Idle
                statusMessage = self.assistant?.string(forKey: "image_generator_ready") ?? "image_generator_ready"
            } catch {
                ImageGeneratorUtils.Logger.error("[AIImageGeneratorManager] warmup failed (\(error))")
                status = .InitializeFailed
                statusMessage = self.assistant?.formattedString(forKey: "image_generator_warmup_failed", String(describing: error)) ?? "image_generator_warmup_failed"
            }
        }
    }
    
    public func generateImage(params: ImageGeneratorParameters, onDone: @escaping (Bool) -> Void) {
        Task.init(priority: .high) { [self] in
            do {
                while status == .Initializing { try await Task.sleep(nanoseconds: 1_000_000_000) }
                
                guard status == .Idle || status == .GenerateSuccess || status == .GenerateFailed else {
                    ImageGeneratorUtils.Logger.error("[AIImageGeneratorManager] unexpected status for generate image: \(status)")
                    return
                }
                
                generatedImage = nil
                status = .Generating
                statusMessage = self.assistant?.string(forKey: "image_generator_setting_up") ?? "image_generator_setting_up"
                
                ImageGeneratorUtils.Logger.info("[AIImageGeneratorManager] generating")
                ImageGeneratorUtils.Logger.info("[AIImageGeneratorManager] positive: \(params.positivePrompt)")
                ImageGeneratorUtils.Logger.info("[AIImageGeneratorManager] negative: \(params.negativePrompt)")
                ImageGeneratorUtils.Logger.info("[AIImageGeneratorManager] shape image: \(String(describing: params.shapeImageId))")
                
                try await ImageGeneratorUtils.withBenchmark("generate") {
                    generatedImage = try await imageGenerator.generate(params: params) { fractionDone, partialImage in
                        let percentage = fractionDone * 100
                        let formattedPercentage = String(format: "%.0f%%", percentage)
                        statusMessage = self.assistant?.formattedString(forKey: "image_generator_generating", formattedPercentage) ?? "image_generator_generating"
                        generatedImage = partialImage
                        return status == .Generating
                    }
                }
                
                guard status == .Generating else {
                    ImageGeneratorUtils.Logger.info("[AIImageGeneratorManager] generate cancelled")
                    return
                }
                
                ImageGeneratorUtils.Logger.info("[AIImageGeneratorManager] generate success")
                status = .GenerateSuccess
                statusMessage = self.assistant?.string(forKey: "image_generator_done") ?? "image_generator_done"
                onDone(true)
            } catch {
                ImageGeneratorUtils.Logger.error("[AIImageGeneratorManager] generate failed: \(error)")
                status = .GenerateFailed
                statusMessage = self.assistant?.string(forKey: "image_generator_failed") ?? "image_generator_failed"
                onDone(false)
            }
        }
    }
    
    public func cancelGenerate() {
        if status == .Generating {
            status = .Idle
        }
    }
    
    public func provideAssistant(assistant: Assistant) {
        guard let sdig = imageGenerator as? StableDiffusionImageGenerator else {
            return
        }
        sdig.provideAssistant(assistant: assistant)
        self.assistant = assistant
    }
}
