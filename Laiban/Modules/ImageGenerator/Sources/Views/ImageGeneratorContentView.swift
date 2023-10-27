//
//  ContentView.swift
//  ml-sd-test
//
//  Created by Kenth Ljung on 2023-10-03.
//

import SwiftUI
import StableDiffusion
import CoreML

@available(iOS 17.0, *)
struct ImageGeneratorContentView: View {
    @State private var statusText: String = ""
    @State private var positivePrompt: String = "HEPP bug, insect, beetle, ant, bee, masterpiece, highres, photorealistic, realistic, photography, soft lighting, Nikon RAW Photo, Fujifilm XT3, best quality, simple background, solid color background, white background, bright background, sharp, focus, centered, full view, sfw"
    @State private var negativePrompt: String = "low quality, worst quality, bad hands, human, people, person, man, woman, blurry, motion blur, close up, watermark, camouflage, nsfw"
    @State private var seed: UInt32 = 0
    @State private var steps: Int = 20
    @State private var scale: Float = 10.0
    @State private var generatedImage: UIImage?
    
    var body: some View {
        VStack {
            VStack {
                Text("👍 Prompt")
                TextEditor(text: $positivePrompt)
                    .frame(height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
            }
            
            VStack {
                Text("👎 Prompt")
                TextEditor(text: $negativePrompt)
                    .frame(height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
            }
            
            HStack {
                Stepper(value: $seed, in: 0...1_000_000, step: 1) {
                    Text("Seed: \(seed)")
                }
                
                Button("R") {
                    seed = UInt32.random(in: 0...1_000_000)
                }
                .buttonStyle(.bordered)
            }
            
            Stepper(value: $steps, in: 1...50, step: 1) {
                Text("Steps: \(steps)")
            }
            
            HStack {
                Text("Scale:" + String(format: "%.1f%", scale))
                Slider(value: $scale, in: 1...20, step: 0.5)
            }
            
            HStack {
                Button("Skapa!", action: generate)
                    .buttonStyle(.borderedProminent)
            }
            
            Text(statusText)
                .padding(10)
            
            if let generatedImage {
                Image(uiImage: generatedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(EdgeInsets(top: 0, leading: 50, bottom: 0, trailing: 50))
            } else {
                Image("placeholder")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(EdgeInsets(top: 0, leading: 50, bottom: 0, trailing: 50))
            }
        }
        .padding(50)
    }
    
    func benchmark(_ tag: String, _ block: () throws -> Void) throws {
        print("Start bench '\(tag)'")
        let start = Date()
        try block()
        let end = Date()
        let time = end.timeIntervalSince(start)
        print("Benched '\(tag)' took \(String(format: "%.0f%", time))")
    }
    
    func generate() {
        Task.detached(priority: .high) {
            do {
                guard let path = Bundle.main.path(forResource: "SD2_1_palettized_split_einsum_v2", ofType: nil, inDirectory: nil) else {
                    statusText = "Hittade inte AI-modellerna 😔"
                    print("No models found 😔")
                    return
                }
                
                let resourceURL = URL(fileURLWithPath: path)
                let config = MLModelConfiguration()
                config.modelDisplayName = "Laiban_SD_Model"
                config.computeUnits = .cpuAndNeuralEngine
                
                let sdPipeline:StableDiffusionPipeline
                if let pipeline = try? StableDiffusionPipeline(resourcesAt: resourceURL,
                                                               controlNet: [],
                                                               configuration: config,
                                                               reduceMemory: false) {
                    sdPipeline = pipeline
                }
                else {
                    statusText = "Oops kunde inte starta 😭"
                    print("Pipeline creation failed")
                    return
                }
                
                print("Pipeline loaded")
                var configuration = StableDiffusionPipeline.Configuration(prompt: positivePrompt)
                configuration.negativePrompt = negativePrompt
                configuration.imageCount = 1
                configuration.stepCount = steps
                configuration.seed = seed
                configuration.guidanceScale = scale
                configuration.disableSafety = false
                configuration.schedulerType = .dpmSolverMultistepScheduler
                
                statusText = "Värmer upp motorn 🔥..."
                try benchmark("prewarm") {
                    try sdPipeline.prewarmResources()
                }
                
                statusText = "Skapar pixlar 📸..."
                print("Generating...")
                
                try benchmark("generate") {
                    let cgImages = try sdPipeline.generateImages(configuration: configuration, progressHandler: { progress in
                        let percentage = Double(progress.step) / Double(progress.stepCount) * 100
                        let formattedPercentage = String(format: "%.0f%%", percentage)
                        statusText = "\(formattedPercentage) färdig 🚀"
                        
                        if let cgImage = progress.currentImages.first {
                            generatedImage = UIImage(cgImage: cgImage!)
                        }
                        
                        print("progress \(progress.step) / \(progress.stepCount) \(formattedPercentage) currentImages: \(progress.currentImages.count)")
                        return true
                    })
                    let uiImages = cgImages.compactMap { image in
                        if let cgImage = image { return UIImage(cgImage: cgImage)
                        } else { return nil }
                    }
                    generatedImage = uiImages[0]
                }
                statusText = "Klar 🎉"
                print("Done ig?")
            } catch {
                statusText = "Hoppsan, nu gick något snett ☔️"
                print("Error generating images")
            }
        }
    }
}

#Preview {
    if #available(iOS 17.0, *) {
        return ImageGeneratorContentView()
    } else {
        // Fallback on earlier versions
        return Text("")
    }
}
