//
//  AIImageGeneratorManager.swift
//  LaibanExample
//
//  Created by Kenth Ljung on 2023-10-19.
//

import Foundation
import UIKit

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
class AIImageGeneratorManager {
    var imageGenerator: AIImageGenerator
    var status: GenerateStatus
    
    public var statusMessage: String
    public var generatedImage: UIImage?
    
    init() {
        imageGenerator = StableDiffusionImageGenerator(modelProvider: UrlModelProvider())
//        imageGenerator = MockImageGenerator()
        status = .WaitingForInit
        statusMessage = ""
        generatedImage = nil
    }
    
    func initialize() {
        Task.detached(priority: .high) { [self] in
            guard status == .WaitingForInit else { return }
            
            status = .Initializing
            
            do {
                print("[AIImageGeneratorManager] warming up...")
                statusMessage = "Laddar..."
                
                try await imageGenerator.warmup { [self] progress in
                    print("[AIImageGeneratorManager] warmup: \(progress.fractionCompleted)")
//                    let percentage = progress.fractionCompleted * 100
//                    let formattedPercentage = String(format: "%.0f%%", percentage)
                    statusMessage = progress.localizedDescription //"\(formattedPercentage) \(progress.localizedDescription!)"
                }
                
                print("[AIImageGeneratorManager] warmup done")
                status = .Idle
                statusMessage = "Redo för att skapa bilder 🖼️"
            } catch {
                print("[AIImageGeneratorManager] warmup failed (\(error))")
                status = .InitializeFailed
                statusMessage = "Hoppsan, kunde inte starta upp ordentligt ☔️"
            }
        }
    }
    
    func generateImage(positivePrompt: String, negativePrompt: String) {
        Task.detached(priority: .high) { [self] in
            do {
                while status == .Initializing { try await Task.sleep(nanoseconds: 1_000_000_000) }
                
                guard status == .Idle || status == .GenerateSuccess || status == .GenerateFailed else {
                    print("[AIImageGeneratorManager] unexpected status for generate image: \(status)")
                    return
                }
                
                generatedImage = nil
                status = .Generating
                statusMessage = "Vänta lite..."
                
                print("[AIImageGeneratorManager] generating")
                print("[AIImageGeneratorManager] positive: \(positivePrompt)")
                print("[AIImageGeneratorManager] negative: \(negativePrompt)")
                
                generatedImage = try await imageGenerator.generate(
                    positivePrompt: positivePrompt,
                    negativePrompt: negativePrompt) { fractionDone, partialImage in
                    let percentage = fractionDone * 100
                    let formattedPercentage = String(format: "%.0f%%", percentage)
                    statusMessage = "\(formattedPercentage) färdig 🚀"
                    generatedImage = partialImage
                    return status == .Generating
                }
                
                guard status == .Generating else {
                    print("[AIImageGeneratorManager] generate cancelled")
                    return
                }
                
                print("[AIImageGeneratorManager] generate success")
                status = .GenerateSuccess
                statusMessage = "Klar 🎉 Så här blev din bild:"
            } catch {
                print("[AIImageGeneratorManager] generate failed: \(error)")
                status = .GenerateFailed
                statusMessage = "Hoppsan, något gick snett 😞"
            }
        }
    }
    
    func cancelGenerate() {
        if status == .Generating {
            status = .Idle
        }
    }
}
