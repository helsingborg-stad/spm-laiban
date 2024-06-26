import SwiftUI
import Assistant

enum Step: UInt8 {
    case Home = 0
    case Color
    case Shape
    case Bug
    case Render
    case Result
}

@available(iOS 15.0, *)
struct ImageGeneratorOptions {
    public enum Colorization: UInt8 {
        case Red = 0
        case Blue
        case Green
        case Yellow
        case Pink
        case Purple
        case Cyan
        case Brown
        case Gray
        case Black
        case White
    }
    
    public enum Shape: UInt8 {
        case Square = 0
        case Triangle
        case Circle
    }
    
    public enum Bug: UInt8 {
        case Beetle = 0
        case Butterfly
        case Spider
        case Ladybug
        case Ant
        case Wasp
    }
    
    static let ColorizationColorMap: [Colorization: Color] = [
        Colorization.Red: Color.red,
        Colorization.Blue: Color.blue,
        Colorization.Green: Color.green,
        Colorization.Yellow: Color.yellow,
        Colorization.Pink: Color.pink,
        Colorization.Purple: Color.purple,
        Colorization.Cyan: Color.cyan,
        Colorization.Brown: Color.brown,
        Colorization.Gray: Color.gray,
        Colorization.Black: Color.black,
        Colorization.White: Color.white,
    ]
    
    static public func GetColor(color: Colorization) -> Color {
        return ColorizationColorMap[color]!
    }
    
    static let ColorPromptMap: [Colorization: String] = [
        Colorization.Red: "red bug, red insect",
        Colorization.Blue: "blue bug, blue insect",
        Colorization.Green: "green bug, green insect",
        Colorization.Yellow: "yellow bug, yellow insect",
        Colorization.Pink: "pink bug, pink insect",
        Colorization.Purple: "purple bug, purple insect",
        Colorization.Cyan: "cyan bug, cyan insect",
        Colorization.Brown: "brown bug, brown insect",
        Colorization.Gray: "gray bug, gray insect",
        Colorization.Black: "black bug, black insect",
        Colorization.White: "white bug, white insect",
    ]
    
    static let ColorImageMap: [Colorization: String] = [
        Colorization.Red: "mask.splat",
        Colorization.Blue: "mask.splat",
        Colorization.Green: "mask.splat",
        Colorization.Yellow: "mask.splat",
        Colorization.Pink: "mask.splat",
        Colorization.Purple: "mask.splat",
        Colorization.Cyan: "mask.splat",
        Colorization.Brown: "mask.splat",
        Colorization.Gray: "mask.splat",
        Colorization.Black: "mask.splat",
        Colorization.White: "mask.splat.outline",
    ]
    
    static let ShapeImageMap: [Shape: [String]] = [
        Shape.Square: ["mask.square", "mask.square.outline"],
        Shape.Triangle: ["mask.triangle", "mask.triangle.outline"],
        Shape.Circle: ["mask.circle", "mask.circle.outline"],
    ]
    
    static let ShapeImageCNMap: [Shape: [String]] = [
        Shape.Square: ["cn_scribble_square_1", "cn_scribble_square_2", "cn_scribble_square_3"],
        Shape.Triangle: ["cn_scribble_triangle_1", "cn_scribble_triangle_2", "cn_scribble_triangle_3"],
        Shape.Circle: ["cn_scribble_circle_3"],
    ]
    
    static let ShapePromptMap: [Shape: String] = [
        Shape.Square: "square, rounded square",
        Shape.Triangle: "triangle, a plane figure with three straight sides and three angles",
        Shape.Circle: "circle, round",
    ]
    
    static let BugImageMap: [Bug: [String]] = [
        Bug.Beetle: ["mask.beetle", "mask.beetle.outline"],
        Bug.Butterfly: ["mask.butterfly", "mask.butterfly.outline"],
        Bug.Spider: ["mask.spider", "mask.spider.outline"],
        Bug.Ladybug: ["mask.ladybug", "mask.ladybug.outline"],
        Bug.Ant: ["mask.ant", "mask.ant.outline"],
        Bug.Wasp: ["mask.wasp", "mask.wasp.outline"],
    ]
    
    static let BugPromptMap: [Bug: String] = [
        Bug.Beetle: "beetle, wings, legs, hard shell, insect, bug, EdobBugs",
        Bug.Butterfly: "butterfly, moth, insect, bug, EdobBugs",
        Bug.Spider: "spider, eight legs, arachnid, insect, bug, EdobBugs",
        Bug.Ladybug: "ladybug, wings, dotted, spots, insect, bug, EdobBugs",
        Bug.Ant: "ant, antennas, six legs, insect, bug, EdobBugs",
        Bug.Wasp: "wasp, hornet, bee, wings, insect, bug, EdobBugs",
    ]
}



@available(iOS 15.0, *)
struct DefaultButton: ButtonStyle {
    @Environment(\.fullscreenContainerProperties) var properties
    var color: UIColor? = nil
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title)
            .padding(properties.spacing[.m])
            .background(Color(color ?? .systemPurple))
            .foregroundStyle(.white)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

@available(iOS 15.0, *)
struct SelectionView<T: Hashable>: View {
    @Environment(\.fullscreenContainerProperties) var properties
    @EnvironmentObject var assistant:Assistant
    let text: String
    let items: [T: String]
    let tintSelector: ((T) -> Color)?
    @Binding var selectedStep: Step
    @Binding var selectedItem: T
    @State var clicked = false
    
    var body: some View {
        LBGridView(items: items.count, columns: 3, verticalSpacing: 7, horizontalSpacing: 7, verticalAlignment: .top, horizontalAlignment: .center) { i in
            let item = Array(items.keys)[i]
            Button(action: {
                selectedItem = item
                selectedStep = Step(rawValue: selectedStep.rawValue + 1) ?? .Home
                clicked = true
            }, label: {
                Image(items[item]!, bundle: .module)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .cornerRadius(18.0)
                    .frame(width: (properties.contentSize.width / 3) * 0.6)
                    .padding(10)
                    .colorMultiply((tintSelector != nil) ? tintSelector!(item) : Color.white)
            })
            .disabled(clicked)
        }
        .frame(maxWidth: .infinity)
        
        Spacer()
        
        Text(LocalizedStringKey(text), bundle: LBBundle)
            .font(properties.font, ofSize: .xl)
            .multilineTextAlignment(.center)
            .frame(
                maxWidth: .infinity,
                alignment: .center)
            .padding(properties.spacing[.m])
            .onAppear {
                assistant.speak(text)
            }
    }
}

@available(iOS 15.0, *)
struct HomeBugView: View {
    @Environment(\.fullscreenContainerProperties) var properties
    @EnvironmentObject var assistant:Assistant
    @Binding var selectedStep: Step
    @State var savedImages: [UIImage] = []
    
    var textKey = "image_generator_intro"
    
    var body: some View {
        VStack {
            if self.savedImages.count > 0 {
                LBGridView(items: savedImages.count, columns: 4, verticalSpacing: 0, horizontalSpacing: 0, verticalAlignment: .top, horizontalAlignment: .center) { i in
                    Image(uiImage: self.savedImages[i])
                        .resizable(resizingMode: .stretch)
                        .aspectRatio(contentMode: .fit)
                }
                .frame(height: 600)
                .cornerRadius(18)
            } else {
                Image("intro", bundle: .module)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .cornerRadius(18.0)
            }
            
            Text(LocalizedStringKey(textKey),bundle:LBBundle)
                .font(properties.font, ofSize: .xl)
                .multilineTextAlignment(.center)
                .frame(
                    maxWidth: .infinity,
                    alignment: .center)
                .padding(properties.spacing[.m])
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(nil)
                .minimumScaleFactor(0.8)
                .secondaryContainerBackground(borderColor: .purple)
                .onAppear {
                    assistant.speak(textKey)
                }
            Spacer()
                .frame(maxWidth: .infinity,
                       alignment: .center)
            Button(action: {
                selectedStep = .Color
            }, label: {
                Text(LocalizedStringKey("image_generator_start"),bundle:LBBundle)
            })
            .buttonStyle(DefaultButton())
        }
        .onAppear {
            if #available(iOS 16.0, *) {
                do {
                    var images: [UIImage] = []
                    let fileManager = FileManager()
                    let filenames = ImageGeneratorUtils.getSavedImageFilenames()
                    print("files \(filenames)")
                    
                    for filename in filenames {
                        guard filename.contains(".png") else {
                            continue
                        }
                        
                        let pathURL = ImageGeneratorUtils.getSavedImagesDirectoryUrl().appendingPathComponent(filename)
                        let imageData = try Data(contentsOf: pathURL)
                        images.append(UIImage(data: imageData)!)
                    }
                    
                    self.savedImages = images
                } catch {
                    print("Failed to read saved images: \(error)")
                }
            }
        }
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
                        .animation(.easeInOut(duration: 0.5))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(50)
        }
    }
}

@available(iOS 15.0, *)
struct ResultView: View {
    @Environment(\.fullscreenContainerProperties) var properties
    @EnvironmentObject var assistant:Assistant
    @Binding var selectedStep: Step
    
    var image: UIImage?
    var statusText: String
    
    @State var imageSaved = false
    
    var body: some View {
        VStack {
            Text(statusText)
                .font(properties.font, ofSize: .xl)
                .onAppear {
                    assistant.speak(statusText)
                }
            
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
        
        Button(action: {
            guard !imageSaved else { return }
            guard let image = image else { return }
            
            let imageSaver = ImageSaver()
            imageSaver.successHandler = {
                print("Save success!")
                imageSaved = true
            }
            
            imageSaver.errorHandler = {
                print("Oops: \($0.localizedDescription)")
            }
            
            imageSaver.writeToPhotoAlbum(image: image)
        }, label: {
            imageSaved
            ? Text("✓")
            : Text(LocalizedStringKey("image_generator_save"), bundle: LBBundle)
        })
        .buttonStyle(DefaultButton(color: imageSaved ? .systemGreen : nil))
        .onAppear {
            imageSaved = false
        }
        
        Spacer()
        Button(action: {
            selectedStep = .Home
        }, label: {
            Text(LocalizedStringKey("image_generator_restart"), bundle: LBBundle)
        })
        .buttonStyle(DefaultButton())
    }
}

@available(iOS 15.0, *)
public struct ImageGeneratorView: View {
    @Environment(\.fullscreenContainerProperties) var properties
    @EnvironmentObject var assistant:Assistant
    
    var service: ImageGeneratorServiceProtocol
    
    @State var selectedStep: Step = .Home
    @State var selectedColor: ImageGeneratorOptions.Colorization = .Red
    @State var selectedShape: ImageGeneratorOptions.Shape = .Square
    @State var selectedBug: ImageGeneratorOptions.Bug = .Beetle
    
    public init(service: ImageGeneratorServiceProtocol) {
        self.service = service
    }
    
    func conditionalContrast<T>(_ valueIfPoorContrast: T, _ valueIfOther: T) -> T {
        return selectedColor == .White ? valueIfPoorContrast : valueIfOther
    }
    
    func slicedDict<TKey, TValue>(_ dict: [TKey: [TValue]], _ index: Int) -> [TKey: TValue] {
        return dict.mapValues { values in
            return values[index]
        }
    }
    
    public var body: some View {
        VStack {
            HStack {
                if [.Color, .Shape, .Bug, .Render].contains(selectedStep) {

                    if selectedStep.rawValue > Step.Color.rawValue {
                        Image(ImageGeneratorOptions.ColorImageMap[selectedColor]!, bundle: .module)
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                            .cornerRadius(18.0)
                            .frame(width: (properties.contentSize.width / 5) * 0.8)
                            .padding(10)
                            .animation(.easeIn)
                            .colorMultiply(ImageGeneratorOptions.GetColor(color: selectedColor))
                        
                        Image(conditionalContrast("mask.plus.outline", "mask.plus"), bundle: .module)
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                            .cornerRadius(18.0)
                            .frame(width: (properties.contentSize.width / 5) * 0.3)
                            .padding(10)
                            .animation(.easeIn)
                            .colorMultiply(ImageGeneratorOptions.GetColor(color: selectedColor))
                            .opacity(0.6)
                    }
                    
                    if selectedStep.rawValue > Step.Shape.rawValue {
                        
                        Image(conditionalContrast(ImageGeneratorOptions.ShapeImageMap[selectedShape]![1], ImageGeneratorOptions.ShapeImageMap[selectedShape]![0]), bundle: .module)
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                            .cornerRadius(18.0)
                            .frame(width: (properties.contentSize.width / 5) * 0.8)
                            .padding(10)
                            .animation(.easeIn)
                            .colorMultiply(ImageGeneratorOptions.GetColor(color: selectedColor))
                        
                        Image(conditionalContrast("mask.plus.outline", "mask.plus"), bundle: .module)
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                            .cornerRadius(18.0)
                            .frame(width: (properties.contentSize.width / 5) * 0.3)
                            .padding(10)
                            .animation(.easeIn)
                            .colorMultiply(ImageGeneratorOptions.GetColor(color: selectedColor))
                            .opacity(0.6)
                    }
                    
                    if selectedStep.rawValue > Step.Bug.rawValue {
                        Image(conditionalContrast(ImageGeneratorOptions.BugImageMap[selectedBug]![1], ImageGeneratorOptions.BugImageMap[selectedBug]![0]), bundle: .module)
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                            .cornerRadius(18.0)
                            .frame(width: (properties.contentSize.width / 5) * 0.8)
                            .padding(10)
                            .animation(.easeIn)
                            .colorMultiply(ImageGeneratorOptions.GetColor(color: selectedColor))
                    }
                }
            }
            
            if selectedStep == .Home {
                HomeBugView(selectedStep: $selectedStep)
                    .onAppear {
                        self.service.generator.initialize()
                        selectedColor = .Red
                        selectedShape = .Square
                        selectedBug = .Beetle
                    }
            }
            
            if selectedStep == .Color {
                SelectionView(
                    text: "image_generator_step_color",
                    items: ImageGeneratorOptions.ColorImageMap,
                    tintSelector: ImageGeneratorOptions.GetColor,
                    selectedStep: $selectedStep,
                    selectedItem: $selectedColor)
            }
            
            if selectedStep == .Shape {
                SelectionView(
                    text: "image_generator_step_shape",
                    items: conditionalContrast(
                        slicedDict(ImageGeneratorOptions.ShapeImageMap, 1),
                        slicedDict(ImageGeneratorOptions.ShapeImageMap, 0)),
                    tintSelector: { _ in
                        return ImageGeneratorOptions.GetColor(color: selectedColor)
                    },
                    selectedStep: $selectedStep,
                    selectedItem: $selectedShape)
            }
            
            if selectedStep == .Bug {
                SelectionView(
                    text: "image_generator_step_bug",
                    items: conditionalContrast(
                        slicedDict(ImageGeneratorOptions.BugImageMap, 1),
                        slicedDict(ImageGeneratorOptions.BugImageMap, 0)),
                    tintSelector: { _ in
                        return ImageGeneratorOptions.GetColor(color: selectedColor)
                    },
                    selectedStep: $selectedStep,
                    selectedItem: $selectedBug)
            }
            
            if selectedStep == .Render {
                RenderView(
                    selectedStep: $selectedStep,
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
            
            if selectedStep == .Result {
                ResultView(
                    selectedStep: $selectedStep,
                    image: self.service.generator.generatedImage,
                    statusText: self.service.generator.statusMessage
                )
            }
        }
        .frame(maxWidth: .infinity,
               maxHeight: .infinity)
        .padding(properties.spacing[.m])
        .primaryContainerBackground()
        .onAppear {
            self.service.generator.provideAssistant(assistant: assistant)
        }
    }
    
    func getPrompts() -> (positive: String, negative: String) {
        let userPrompt = [
            ImageGeneratorOptions.BugPromptMap[selectedBug]!,
            ImageGeneratorOptions.ColorPromptMap[selectedColor]!,
            ImageGeneratorOptions.ShapePromptMap[selectedShape]!
        ].joined(separator: ", ")
        
        return (
            positive: userPrompt + ", " + service.model.positivePrompt,
            negative: service.model.negativePrompt
        )
    }
    
    func getRandomShapeImageId() -> String {
        let possibilities = ImageGeneratorOptions.ShapeImageCNMap[selectedShape]!
        let randomIndex = Int.random(in: 0...(possibilities.count - 1))
        return possibilities[randomIndex]
    }
    
    func generateImage() {
        let (positive, negative) = getPrompts()
        self.service.generator.generateImage(params: ImageGeneratorParameters(
            positivePrompt: positive,
            negativePrompt: negative,
            shapeImageId: getRandomShapeImageId())) { success in
                selectedStep = .Result
            }
    }
}

class MockDeps : ImageGeneratorServiceProtocol {
    func initStartupCheck() {}
    
    class MockManager : AIImageGeneratorManagerProtocol {
        var generatedImage: UIImage? {
            get {
                return UIImage(named: "aiMockGenerate100", in: .module, with: nil)
            }
        }
        public var statusMessage: String = ""
        func initialize() { }
        func generateImage(params: ImageGeneratorParameters, onDone: @escaping (Bool) -> Void) {
            statusMessage = "Laddar..."
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [self] _ in
                statusMessage = "Klar!"
                onDone(true)
            }
        }
        func cancelGenerate() { }
        func provideAssistant(assistant: Assistant) {}
    }
    
    var model: ImageGeneratorServiceModel
    
    var generator: AIImageGeneratorManagerProtocol
    
    init() {
        model = ImageGeneratorServiceModel()
        generator = MockManager()
    }
}

@available(iOS 15.0, *)
struct ImageGeneratorView_Preview: PreviewProvider {
    static var service: ImageGeneratorServiceProtocol? = nil
    static var previews: some View {
        LBFullscreenContainer { _ in
            ImageGeneratorView(service: MockDeps())
        }.attachPreviewEnvironmentObjects()
    }
}
