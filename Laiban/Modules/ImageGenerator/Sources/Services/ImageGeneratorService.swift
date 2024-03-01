import Foundation
import Combine
import SwiftUI

public protocol ImageGeneratorModuleProtocol {
    var service: ImageGeneratorServiceProtocol { get }
    var dashboard: LBDashboardItem { get }
    var admin: LBAdminService { get }
}

public protocol ImageGeneratorServiceProtocol {
    var model: ImageGeneratorServiceModel { get }
    var generator: AIImageGeneratorManagerProtocol { get }
    func initStartupCheck()
}

public extension LBViewIdentity {
    static let imageGenerator = LBViewIdentity("ImageGeneratorService")
}

public typealias ImageGeneratorStorageService = CodableLocalJSONService<ImageGeneratorServiceModel>

@available(iOS 17, *)
public class ImageGeneratorService : CTS<ImageGeneratorServiceModel, ImageGeneratorStorageService>, LBAdminService, LBDashboardItem, ImageGeneratorServiceProtocol, ImageGeneratorModuleProtocol {
    public var service: ImageGeneratorServiceProtocol { get { return self } }
    public var dashboard: LBDashboardItem { get { return self } }
    public var admin: LBAdminService { get { return self } }
    
    public var model: ImageGeneratorServiceModel { get { return data; }}
    
    public var generator: AIImageGeneratorManagerProtocol {
        get { return manager }
    }
    
    lazy var manager: AIImageGeneratorManager = AIImageGeneratorManager(service: self)
    public var cancellables = Set<AnyCancellable>()
    public convenience init() {
        self.init(
            emptyValue: ImageGeneratorServiceModel(),
            storageOptions: .init(filename: "ImagGeneratorServiceModel", foldername: "ImageGenerator")
        )
        self.isAvailable = true
    }
    
    ///----------------------------------------
    /// begin LBDashboardItem
    ///----------------------------------------
    public var viewIdentity: LBViewIdentity = .imageGenerator
    
    public var isAvailablePublisher: AnyPublisher<Bool, Never> {
        $isAvailable.eraseToAnyPublisher()
    }
    
    @Published public private(set) var isAvailable: Bool = false
    ///----------------------------------------
    /// end LBDashboardItem
    ///----------------------------------------
    
    ///----------------------------------------
    /// begin LBAdminService
    ///----------------------------------------
    public var id: String = "ImageGeneratorService"
    
    public var listOrderPriority: Int = 1
    
    public var listViewSection: LBAdminListViewSection = .init(id: "ImageGenerator", title: "Bildgenerering", listOrderPriority: .content.after)
    
    public func adminView() -> AnyView {
        AnyView(ImageGeneratorAdminView(service: self))
    }
    ///----------------------------------------
    /// end LBAdminService
    ///----------------------------------------

    public func initStartupCheck() {
        if(data.initOnStartup && manager.status == .WaitingForInit) {
            manager.initialize()
        }
    }
}

public struct StubImageGeneratorServiceModel: Codable, Equatable {
}

public typealias StubImageGeneratorStorageService = CodableLocalJSONService<StubImageGeneratorServiceModel>

public class StubImageGeneratorService : CTS<StubImageGeneratorServiceModel, StubImageGeneratorStorageService>, LBAdminService, LBDashboardItem, ImageGeneratorServiceProtocol, ImageGeneratorModuleProtocol {
    public var service: ImageGeneratorServiceProtocol { get { return self } }
    public var dashboard: LBDashboardItem { get { return self } }
    public var admin: LBAdminService { get { return self } }
    
    struct StubAdminView: View {
        var body: some View {
            Text("Bildgenerering är endast tillgänglig med iOS 17 och senare.")
        }
    }
    
    struct StubGenerator: AIImageGeneratorManagerProtocol {
        var generatedImage: UIImage?
        var statusMessage: String = "Bildgenerering är endast tillgänglig med iOS 17 och senare."
        func initialize() {}
        func generateImage(params: ImageGeneratorParameters, onDone: @escaping (Bool) -> Void) {}
        func cancelGenerate() {}
    }
    
    public var model: ImageGeneratorServiceModel {
        get {
            return ImageGeneratorServiceModel()
        }
    }
    public func initStartupCheck() {}
    
    public var generator: AIImageGeneratorManagerProtocol = StubGenerator()
    
    public convenience init() {
        self.init(
            emptyValue: StubImageGeneratorServiceModel(),
            storageOptions: .init(filename: "StubImagGeneratorServiceModel", foldername: "ImageGenerator")
        )
        self.isAvailable = false
    }
    
    ///----------------------------------------
    /// begin LBDashboardItem
    ///----------------------------------------
    public var viewIdentity: LBViewIdentity = .imageGenerator
    
    public var isAvailablePublisher: AnyPublisher<Bool, Never> {
        $isAvailable.eraseToAnyPublisher()
    }
    
    @Published public private(set) var isAvailable: Bool = false
    ///----------------------------------------
    /// end LBDashboardItem
    ///----------------------------------------
    
    ///----------------------------------------
    /// begin LBAdminService
    ///----------------------------------------
    public var id: String = "ImageGeneratorService"
    
    public var listOrderPriority: Int = 1
    
    public var listViewSection: LBAdminListViewSection = .init(id: "ImageGenerator", title: "Bildgenerering", listOrderPriority: .content.after)
    
    public func adminView() -> AnyView {
        AnyView(StubAdminView())
    }
    ///----------------------------------------
    /// end LBAdminService
    ///----------------------------------------
}

public class ImageGeneratorServiceFactory {
    public static func GetService() -> ImageGeneratorModuleProtocol {
        if #available(iOS 17.0, *) {
            return ImageGeneratorService()
        }
        return StubImageGeneratorService()
    }
}
