//
//  Created by Tomas Green on 2022-04-29.
//

import Foundation

public protocol CodableStorage {
    associatedtype Value:Codable
    associatedtype StorageOptions
    func write(_ value:Value) async throws
    func delete() async throws
    func read() async throws -> Value
    func defaults() async throws -> Value
    init(options:StorageOptions)
}
public enum CodableUserDefaultsServiceError: Error {
    case missingValueInUserDefaults
}
public actor CodableUserDefaultsService<T>: CodableStorage where T:Codable {
    public struct Options {
        public var keyname:String
        public var defaultValue:T
        public init(keyname:String, defaultValue:T) {
            self.keyname = keyname
            self.defaultValue = defaultValue
        }
    }
    public typealias Value = T
    public typealias StorageOptions = Options
    var options:Options
    public init(options: Options) {
        self.options = options
    }
    public func write(_ value: T) async throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(value)
        UserDefaults.standard.set(data, forKey: options.keyname)
    }
    public func delete() async throws {
        UserDefaults.standard.removeObject(forKey: options.keyname)
    }
    public func read() async throws -> T {
        let decoder = JSONDecoder()
        guard let data = UserDefaults.standard.value(forKey:options.keyname) as? Data else {
            throw CodableUserDefaultsServiceError.missingValueInUserDefaults
        }
        return try decoder.decode(T.self, from: data)
    }
    public func defaults() async throws -> T {
        return options.defaultValue
    }
    
}
public enum CodableLocalJSONServiceError: Error {
    case noSuchResourceInBundle
    case noSuchFile
    case missingDefaultBundleFilenameOption
}
public actor CodableLocalJSONService<T>: CodableStorage where T: Codable {
    public typealias Value = T
    public typealias StorageOptions = Options
    
    public struct Options: Equatable {
        /// excluding json file extension
        public var filename:String
        /// foldername, not path
        public var foldername:String
        /// excluding json file extension
        public var bundleFilename:String?
        /// defaults to main bundle
        public var bundle:Bundle
        public init(filename:String, foldername:String, bundleFilename:String? = nil, bundle:Bundle = .main) {
            self.filename = filename
            self.foldername = foldername
            self.bundle = bundle
            self.bundleFilename = bundleFilename
        }
    }

    public let options:Options
    public init(options:Options) {
        self.options = options
    }
    var dir: URL {
        let fm = FileManager.default
        return fm.urls(for: .libraryDirectory, in: .userDomainMask)[0].appendingPathComponent(options.foldername)
    }
    var fileURL:URL {
        return dir.appendingPathComponent(options.filename + ".json")
    }
    public func write(_ value:T) async throws {
        let fm = FileManager.default
        let dir = dir
        let file = fileURL
        if !fm.fileExists(atPath: dir.path) {
            try fm.createDirectory(at: dir, withIntermediateDirectories: false, attributes: nil) // [.protectionKey : FileProtectionType.complete]
        }
        let encoder = JSONEncoder()
        let data = try encoder.encode(value)
        if fm.fileExists(atPath: file.path) {
            try fm.removeItem(atPath: file.path)
        }
        try data.write(to: file, options: .completeFileProtection)
    }
    public func defaults() async throws -> T {
        guard let filename = options.bundleFilename else {
            throw CodableLocalJSONServiceError.missingDefaultBundleFilenameOption
        }
        guard let url = options.bundle.url(forResource: filename, withExtension: "json") else {
            throw CodableLocalJSONServiceError.noSuchResourceInBundle
        }
        return try JSONDecoder().decode(T.self, from: try Data(contentsOf: url))
    }
    public func read() async throws -> T {
        let fm = FileManager.default
        let file = fileURL
        if !fm.fileExists(atPath: file.path) {
            throw CodableLocalJSONServiceError.noSuchFile
        }
        let decoder = JSONDecoder()
        let data = try Data(contentsOf: file)
        return try decoder.decode(T.self, from: data)
    }
    public func delete() async throws {
        try FileManager.default.removeItem(atPath: fileURL.path)
    }
}
