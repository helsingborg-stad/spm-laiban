//
//  S3ModelProvider.swift
//  ml-sd-test
//
//  Created by Kenth Ljung on 2023-10-11.
//

import Foundation
import UIKit
import ZIPFoundation

enum UrlDownloadError : Error {
    case badUrl
    case badStatus(code: Int)
    case badResponse
}

@available(iOS 16.0, *)
class ZipFileDownloader : NSObject, URLSessionDelegate, URLSessionDownloadDelegate {
    public var onProgress : (_ fractionDone: Float) -> Void
    public var onDone : (_ location: URL?, _ error: Error?) -> Void
    private var task : URLSessionDownloadTask?
    private var downloadName: String
    
    init(onProgress: @escaping (_: Float) -> Void) {
        self.onProgress = onProgress
        self.onDone = { location, error in
        }
        self.downloadName = ""
    }
    
    func startDownload(_ name: String, url: URL, onDone: @escaping (_ location: URL?, _ error: Error?) -> Void) {
        let urlSession = URLSession(configuration: .default,
                                    delegate: self,
                                    delegateQueue: nil)
        self.downloadName = name
        self.onDone = onDone
        
        let expectedDestination = UrlModelProvider.destinationDirOf(downloadName: name)
        guard !FileManager.default.fileExists(atPath: expectedDestination.path()) else {
            print("\(downloadName) already exists (assuming OK): \(expectedDestination.path())")
            onDone(expectedDestination, nil)
            return
        }
        
        let downloadTask = urlSession.downloadTask(with: url)
        downloadTask.resume()
        self.task = downloadTask
    }
    
    // called during download
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        if downloadTask == self.task {
            let calculatedProgress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            DispatchQueue.main.async {
                // Todo report progress
                self.onProgress(calculatedProgress)
            }
        }
    }
    
    // called when done
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let response = downloadTask.response! as? HTTPURLResponse else {
            self.onDone(location, UrlDownloadError.badResponse)
            return
        }
        
        guard response.statusCode == 200 else {
            self.onDone(location, UrlDownloadError.badStatus(code: response.statusCode))
            return
        }
        
        do {
            let destinationURL = UrlModelProvider.destinationDirOf(downloadName: self.downloadName)
            let fileManager = FileManager()
            try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
            try fileManager.unzipItem(at: location, to: destinationURL)
            self.onDone(destinationURL, nil)
        } catch {
            self.onDone(nil, error)
        }
    }
    
    // called at end, contains any error
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error != nil {
            self.onDone(nil, error)
        }
    }
}

@available(iOS 16.0, *)
struct UrlModelProvider : AIModelProvider {
    var rawUrl: String
    
    init(rawUrl: String) {
        self.rawUrl = rawUrl
    }
    
    static func destinationDirOf(downloadName: String) -> URL {
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        return documentURL!.appendingPathComponent("models/\(downloadName)")
    }
    
    func isModelAvailable(_ modelName: String) -> Bool {
        return FileManager.default.fileExists(atPath: UrlModelProvider.destinationDirOf(downloadName: modelName).path())
    }
    
    func fetchModel(_ modelName: String, _ onFetchProgress: @escaping (Float) -> Void) async throws {
        print("fetching model.....")
        
        guard let url = URL(string: self.rawUrl) else {
            throw UrlDownloadError.badUrl
        }
        
        let downloader = ZipFileDownloader(onProgress: onFetchProgress)
        
        var done = false
        var dlError: Error? = nil
        downloader.startDownload(modelName, url: url) { location, error in
            done = true
            dlError = error
        }
        
        guard (dlError == nil) else {
            throw dlError!
        }
        
        while !done {
            try await Task.sleep(nanoseconds: 1 * 1_000_000_000)
        }
    }
    
    func getStoredModelURL(_ modelName: String) throws -> URL {
        return UrlModelProvider.destinationDirOf(downloadName: modelName)
    }
    
    func cleanModelCache() {
        UrlModelProvider.cleanModels()
    }
    
    static func cleanModels() {
        print("Cleaning models")
        let modelsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("models/")
        try? FileManager.default.removeItem(atPath: modelsURL.path())
    }
    
    static func getModelCacheSizeString() -> String? {
        let modelsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("models/")
        
        guard let size = try? modelsURL.sizeOnDisk() else {
            return "Det finns inga nedladdade modeller"
        }
        return size
    }
}

// https://stackoverflow.com/a/32814710
extension URL {
    /// check if the URL is a directory and if it is reachable
    func isDirectoryAndReachable() throws -> Bool {
        guard try resourceValues(forKeys: [.isDirectoryKey]).isDirectory == true else {
            return false
        }
        return try checkResourceIsReachable()
    }
    
    /// returns total allocated size of a the directory including its subFolders or not
    func directoryTotalAllocatedSize(includingSubfolders: Bool = false) throws -> Int? {
        guard try isDirectoryAndReachable() else { return nil }
        if includingSubfolders {
            guard
                let urls = FileManager.default.enumerator(at: self, includingPropertiesForKeys: nil)?.allObjects as? [URL] else { return nil }
            return try urls.lazy.reduce(0) {
                (try $1.resourceValues(forKeys: [.totalFileAllocatedSizeKey]).totalFileAllocatedSize ?? 0) + $0
            }
        }
        return try FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: nil).lazy.reduce(0) {
            (try $1.resourceValues(forKeys: [.totalFileAllocatedSizeKey])
                .totalFileAllocatedSize ?? 0) + $0
        }
    }
    
    /// returns the directory total size on disk
    func sizeOnDisk() throws -> String? {
        guard let size = try directoryTotalAllocatedSize(includingSubfolders: true) else { return nil }
        URL.byteCountFormatter.countStyle = .file
        guard let byteCount = URL.byteCountFormatter.string(for: size) else { return nil}
        return byteCount
    }
    private static let byteCountFormatter = ByteCountFormatter()
}
