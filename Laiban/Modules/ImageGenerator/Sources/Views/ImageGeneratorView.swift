import SwiftUI

enum Step: String {
    case Color = "Välj färg"
    case Shape = "Välj form"
    case Bug = "Välj insekt"
    case Home
    case Render
}

@available(iOS 15.0, *)
struct DefaultButton: ButtonStyle {
    @Environment(\.fullscreenContainerProperties) var properties

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title)
            .padding(properties.spacing[.m])
            .background(Color(.systemPurple))
            .foregroundStyle(.white)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

@available(iOS 15.0, *)
struct SelectionView: View {
    @Environment(\.fullscreenContainerProperties) var properties
    let items: [String: String]
    @Binding var selectedStep: Step
    @Binding var selectedItem: String?

    var body: some View {
        LBGridView(items: items.count, columns: 3, verticalSpacing: 7, horizontalSpacing: 7, verticalAlignment: .top, horizontalAlignment: .center) { i in
            let item = Array(items.keys)[i]
            Button(action: {
                selectedItem = item
            }, label: {
                Image(item, bundle: .module)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .cornerRadius(18.0)
                    .frame(width: (properties.contentSize.width / 3) * 0.6)
                    .padding(10)
                    .shadow(color: selectedItem == item ? Color.gray : Color.clear, radius: 5)
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
            .buttonStyle(DefaultButton())
        }
    }
}

@available(iOS 15.0, *)
struct HomeBugView: View {
    @Environment(\.fullscreenContainerProperties) var properties
    @Binding var selectedStep: Step

    var body: some View {
        Image("intro", bundle: .module)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .cornerRadius(18.0)

        Text("Vill du skapa en bild på en insekt utifrån form och färg? Tryck på knappen för att tala om för en artisifiell intelligens hur insekten ska se ut.")
            .font(properties.font, ofSize: .xl)
            .frame(
                maxWidth: .infinity,
                alignment: .leading)
            .padding(properties.spacing[.m])
            .secondaryContainerBackground(borderColor: .purple)
        Spacer()
            .frame(maxWidth: .infinity,
                   alignment: .center)
        Button("Klicka här för att starta") {
            selectedStep = .Color
        }
        .buttonStyle(DefaultButton())
    }
}

@available(iOS 15.0, *)
struct RenderView: View {
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
                        .cornerRadius(18.0)
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(50)
        }

        if statusText == "Klar 🎉 Så här blev din bild:" {
            Button("Spara bilden till 'Bilder'") {
                guard let image = image else { return }

                let imageSaver = ImageSaver()
                imageSaver.successHandler = {
                    print("Save success!")
                }

                imageSaver.errorHandler = {
                    print("Oops: \($0.localizedDescription)")
                }

                imageSaver.writeToPhotoAlbum(image: image)
            }.buttonStyle(DefaultButton())
            Spacer()
            Button("Börja om från början") {
                selectedStep = .Home
            }
            .buttonStyle(DefaultButton())
        }
    }
}

@available(iOS 17, *)
public protocol ImageGeneratorServiceProtocol {
    var data: ImageGeneratorServiceModel { get }
    var generator: AIImageGeneratorManagerProtocol { get }
}

@available(iOS 17, *)
public struct ImageGeneratorView: View {
    @Environment(\.fullscreenContainerProperties) var properties
    var service: ImageGeneratorServiceProtocol

    let colorImageTextMapping: [String: String] = [
        "splash.red": "red bug, red insect, red thorax",
        "splash.blue": "blue bug, blue insect, blue thorax",
        "splash.yellow": "yellow bug, yellow insect, yellow thorax",
        "splash.pink": "pink bug, pink insect, pink thorax",
        "splash.black": "black bug, black insect, black thorax",
        "splash.brown": "brown bug, brown insect, brown thorax",
        "splash.gray": "gray bug, gray insect, gray thorax",
        "splash.green": "green bug, green insect, green thorax",
        "splash.purple": "purple bug, purple insect, purple thorax",
        "splash.turquoise-blue": "turquoise bug, turquoise insect, turquoise thorax",
    ]

    let shapeImageTextMapping: [String: String] = [
        "shape.square": "square, rounded square",
        "shape.tri": "triangle, a plane figure with three straight sides and three angles",
        "shape.circle": "circle, round",
    ]
    
    let shapeImageIdMapping: [String: [String]] = [
        "shape.square": ["cn_scribble_square_1", "cn_scribble_square_2", "cn_scribble_square_3"],
        "shape.tri": ["cn_scribble_triangle_1", "cn_scribble_triangle_2", "cn_scribble_triangle_3"],
        "shape.circle": ["cn_scribble_circle_3"],
    ]

    let bugImageTextMapping: [String: String] = [
        "bug.ant": "ant, antennas, six legs, insect, bug, EdobBugs",
        "bug.beetle": "beetle, wings, legs, hard shell, insect, bug, EdobBugs",
        "bug.butterfly": "butterfly, moth, insect, bug, EdobBugs",
        "bug.cockroach": "cockroach, roach, insect, bug, EdobBugs",
        "bug.dragonfly": "dragonfly, damselfly, anisoptera, insect, bug, EdobBugs",
        "bug.grasshopper": "grasshopper, cricket, katydid, insect, bug, EdobBugs",
        "bug.spider": "spider, eight legs, arachnid, insect, bug, EdobBugs",
        "bug.ladybug": "ladybug, wings, dotted, spots, insect, bug, EdobBugs",
        "bug.wasp": "wasp, hornet, bee, wings, insect, bug, EdobBugs",
    ]

    @State var selectedStep: Step = .Home
    @State var selectedColorImageName: String? = ""
    @State var selectedShapeImageName: String? = ""
    @State var selectedBugImageName: String? = ""

    public init(service: ImageGeneratorServiceProtocol) {
        self.service = service
    }

    public var body: some View {
        VStack {
            if selectedStep == .Home {
                HomeBugView(selectedStep: $selectedStep)
                    .onAppear {
                        self.service.generator.initialize()
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
                RenderView(selectedStep: $selectedStep,
                           image: self.service.generator.generatedImage,
                           statusText: self.service.generator.statusMessage
                )
                .onAppear {
                    generateImage()
                }
                .onDisappear {
                    self.service.generator.cancelGenerate()
                }
            }
        }
        .frame(maxWidth: .infinity,
               maxHeight: .infinity)
        .padding(properties.spacing[.m])
        .primaryContainerBackground()
    }
    
    func getPrompts() -> (positive: String, negative: String) {
        let userPrompt = [
            bugImageTextMapping[selectedBugImageName!]!,
            colorImageTextMapping[selectedColorImageName!]!,
            shapeImageTextMapping[selectedShapeImageName!]!
        ].joined(separator: ", ")
        
        return (
            positive: userPrompt + ", " + service.data.positivePrompt,
            negative: service.data.negativePrompt
        )
    }
    
    func getRandomShapeImageId() -> String {
        let possibilities = shapeImageIdMapping[selectedShapeImageName!]
        let randomIndex = Int.random(in: 0...(possibilities!.count - 1))
        return possibilities![randomIndex]
    }
    
    func generateImage() {
        let (positive, negative) = getPrompts()
        self.service.generator.generateImage(params: ImageGeneratorParameters(
            positivePrompt: positive,
            negativePrompt: negative,
            shapeImageId: getRandomShapeImageId()))
    }
}

@available(iOS 17, *)
class MockDeps : ImageGeneratorServiceProtocol {
    class MockManager : AIImageGeneratorManagerProtocol {
        var generatedImage: UIImage? {
            get {
                return UIImage(named: "aiMockGenerate100", in: .module, with: nil)
            }
        }
        var statusMessage: String = "Klar 🎉 Så här blev din bild:"
        func initialize() { }
        func generateImage(params: ImageGeneratorParameters) { }
        func cancelGenerate() { }
    }
    
    var data: ImageGeneratorServiceModel
    
    var generator: AIImageGeneratorManagerProtocol
    
    init() {
        data = ImageGeneratorServiceModel()
        generator = MockManager()
    }
}

@available(iOS 17, *)
struct ImageGeneratorView_Preview: PreviewProvider {
    static var service: ImageGeneratorService? = nil
    static var previews: some View {
        LBFullscreenContainer { _ in
            ImageGeneratorView(service: MockDeps())
        }.attachPreviewEnvironmentObjects()
    }
}
