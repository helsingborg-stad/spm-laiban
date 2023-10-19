import SwiftUI

enum Step: String {
    case Color = "Välj färg"
    case Shape = "Välj form"
    case Bug = "Välj insekt"
    case Home
    case Render
}

enum GenerateStatus {
    case ShouldGenerate
    case IsGenerating
    case DoneGenerating(error: Error?)
}

struct SelectionView: View {
    @Environment(\.fullscreenContainerProperties) var properties
    let items: [String: String]
    @Binding var selectedStep: Step
    @Binding var selectedItem: String?

    var body: some View {
        LBGridView(items: items.count, columns: 3, verticalSpacing: 7, horizontalSpacing: 7, verticalAlignment: .top, horizontalAlignment: .center) { i in
            let item = Array(items.keys)[i]
            Button(action: {
                selectedItem = items[item]
            }, label: {
                Image(item)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: (properties.contentSize.width / 3) * 0.8)
                    .padding(10)
                    .shadow(color: selectedItem == items[item] ? Color.gray : Color.clear, radius: 5)
                    
            })
        }
        .frame(maxWidth: .infinity)

        let displayText: String = selectedItem != nil ? "Prompt: \(selectedItem!)" : selectedStep.rawValue

        Text(displayText)
            .font(properties.font, ofSize: .xxl)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

        if selectedItem != nil {
            Button("Gå vidare") {
                switch selectedStep {
                    case .Color:
                        selectedStep = .Shape
                    case .Shape:
                        selectedStep = .Bug
                    case .Bug:
                        selectedStep = .Render
                    default:
                        break
                }
            }
        }
    }
}

struct HomeBugView: View {
    @Environment(\.fullscreenContainerProperties) var properties
    @Binding var selectedStep: Step

    var body: some View {
        Image("intro")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .cornerRadius(18.0)

        Text("Vill du skapa en bild på en insekt utifrån form och färg? Tryck på insekten för att tala om för en artisifiell intelligens hur insekten ska se ut.")
            .font(properties.font, ofSize: .xl)
            .frame(
                maxWidth: .infinity,
                alignment: .leading)
            .padding(properties.spacing[.s])
            .secondaryContainerBackground(borderColor: .purple)

        Spacer()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

        Button("Starta") {
            selectedStep = .Color
        }
    }
}

struct RenderBugView: View {
    @Environment(\.fullscreenContainerProperties) var properties
    @Binding var selectedStep: Step
    
    var image: UIImage?
    var statusText: String
    
    var body: some View {
        VStack {
            Text(statusText)
                .font(properties.font, ofSize: .xl)
            
            ZStack {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: 512)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(50)
        }

        Button("Börja om från början") {
            selectedStep = .Home
        }
    }
}

public struct ImageGeneratorView: View {
    @Environment(\.fullscreenContainerProperties) var properties
    
    let colorImageTextMapping: [String: String] = [
        "splash.red": "color red",
        "splash.blue": "color blue",
        "splash.yellow": "color yellow",
    ]

    let shapeImageTextMapping: [String: String] = [
        "shape.square": "square shape",
        "shape.tri": "triangle shape",
        "shape.circle": "circle shape",
    ]

    let bugImageTextMapping: [String: String] = [
        "bug.beatle": "bug beatle",
        "bug.butterfly": "bug butterfly",
        "bug.wasp": "bug wasp",
    ]
    
    @State var selectedStep: Step = .Home
    @State var selectedColorImageName: String?
    @State var selectedShapeImageName: String?
    @State var selectedBugImageName: String?
    
    @State var generateStatus: GenerateStatus = .ShouldGenerate
    @State var generatedImage: UIImage?
    @State var generateStatusText: String = ""

    public init() {}

    public var body: some View {
        VStack {
            if selectedStep == .Home {
                HomeBugView(selectedStep: $selectedStep)
                    .onAppear {
                        generateStatus = .ShouldGenerate
                    }
            }
            
            if selectedStep == .Color {
                SelectionView(items: colorImageTextMapping,
                              selectedStep: $selectedStep,
                              selectedItem: $selectedColorImageName)
            }

            if selectedStep == .Shape {
                SelectionView(items: shapeImageTextMapping,
                              selectedStep: $selectedStep,
                              selectedItem: $selectedShapeImageName)
            }

            if selectedStep == .Bug {
                SelectionView(items: bugImageTextMapping,
                              selectedStep: $selectedStep,
                              selectedItem: $selectedBugImageName)
            }

            if selectedStep == .Render {
                RenderBugView(selectedStep: $selectedStep,
                              image: generatedImage,
                              statusText: generateStatusText
                )
                .onAppear {
                    print("Render view! \(generateStatus)")
                    switch(generateStatus) {
                    case .ShouldGenerate:
                        generateImage()
                    default:
                        break
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(properties.spacing[.m])
        .primaryContainerBackground()
    }
    
    func getPrompts() -> (positive: String, negative: String) {
        let userPrompt = [
            selectedColorImageName!,
            selectedShapeImageName!,
            selectedBugImageName!
        ].joined(separator: ", ")
        
        return (
            positive: userPrompt + ", bug, insect, beetle, ant, bee, single, solo, masterpiece, highres, photorealistic, realistic, photography, soft lighting, Nikon RAW Photo, Fujifilm XT3, best quality",
            negative: "low quality, worst quality, bad hands, human, people, person, man, woman, blurry, motion blur, close up, watermark, camouflage"
        )
    }
    
    func generateImage() {
        Task.detached(priority: .high) {
            do {
                generateStatus = .IsGenerating
                
//                var imageGenerator = StableDiffusionImageGenerator(modelProvider: UrlModelProvider())
                let imageGenerator = MockImageGenerator()
                
                print("Warming up 🔥...")
                generateStatusText = "Värmer upp 🔥..."
                try await imageGenerator.warmup() { progress in
                    let percentage = progress.fractionCompleted * 100
                    let formattedPercentage = String(format: "%.0f%%", percentage)
                    generateStatusText = "\(formattedPercentage) \(progress.localizedDescription!)"
                }
                
                let (positive, negative) = getPrompts()
                
                print("positive: \(positive)")
                print("negative: \(negative)")
                
                print("Generating 📸...")
                generatedImage = try await imageGenerator.generate(positivePrompt: positive, negativePrompt: negative) { fractionDone, partialImage in
                    let percentage = fractionDone * 100
                    let formattedPercentage = String(format: "%.0f%%", percentage)
                    generateStatusText = "\(formattedPercentage) färdig 🚀"
                    generatedImage = partialImage
                }
                
                generateStatusText = "Klar! Så här blev din bild 🪲"
                generateStatus = .DoneGenerating(error: nil)
                print("image generation done")
            } catch {
                print("image generation failed: \(error)")
                generateStatus = .DoneGenerating(error: error)
                generateStatusText = "Hoppsan, något gick snett 😞"
            }
        }
    }
}

struct ImageGeneratorView_Preview: PreviewProvider {
    static var previews: some View {
        LBFullscreenContainer { _ in
            ImageGeneratorView()
        }.attachPreviewEnvironmentObjects()
    }
}
