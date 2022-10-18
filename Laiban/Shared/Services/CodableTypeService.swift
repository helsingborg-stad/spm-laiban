//
//  Created by Tomas Green on 2022-04-28.
//


import Foundation
import Combine
import Analytics

public enum CTSStatus: Equatable {
    case initializing
    case loading
    case saving
    case deleting
    case resetting
    case idle
}
public protocol LBService {
    var status:CTSStatus { get }
}
open class CTS<T,Storage> : LBService, ObservableObject where Storage: CodableStorage, T == Storage.Value {
    public private(set) var storage:Storage
    @Published public var data:T
    private var emptyValue:T
    @Published public private(set) var status:CTSStatus = .initializing
    public init(emptyValue:T,storageOptions:Storage.StorageOptions) {
        self.data = emptyValue
        self.storage = Storage(options: storageOptions)
        self.emptyValue = emptyValue
        Task {
            await self.load()
        }
    }
    @MainActor public func update(_ data:T, saveAfter:Bool = true) where T: Equatable {
        if self.data == data {
            self.data = data
            if saveAfter {
                save()
            }
        }
    }
    @MainActor public func save() {
        self.status = .saving
        Task {
            do {
                try await storage.write(data)
            } catch {
                AnalyticsService.shared.logError(error)
                debugPrint(error)
            }
            self.status = .idle
        }
    }
    
    @MainActor public func load() {
        self.status = .loading

        Task {
            defer {
                self.status = .idle
            }

            do {
                self.data = try await storage.read()
                return
            } catch {
                debugPrint(error)
            }
            
            do {
                debugPrint("Could not load from file, try loading values from bundle resource.")
                
                self.data = try await storage.defaults()
                return
            } catch {
                debugPrint(error)
            }
        }
    }
    
    @MainActor public func resetToDefaults() {
        self.resetToDefaults(saveAfter: true)
    }
    @MainActor public func resetToDefaults(saveAfter:Bool = true) {
        self.status = .resetting
        Task {
            try? await storage.delete()
            data = (try? await storage.defaults()) ?? emptyValue
            if saveAfter {
                self.save()
            }
            self.status = .idle
        }
    }
    @MainActor public func delete() {
        self.data = emptyValue
        self.status = .deleting
        Task {
            do {
                try await storage.delete()
            } catch {
                AnalyticsService.shared.logError(error)
                debugPrint(error)
            }
            self.status = .idle
        }
    }
}

