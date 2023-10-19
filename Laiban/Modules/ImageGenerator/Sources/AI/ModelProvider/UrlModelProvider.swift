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
    static func destinationDirOf(downloadName: String) -> URL {
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        return documentURL!.appendingPathComponent("models/\(downloadName)")
    }
    
    func isModelAvailable(_ modelName: String) -> Bool {
        return FileManager.default.fileExists(atPath: UrlModelProvider.destinationDirOf(downloadName: modelName).path())
    }
    
    func fetchModel(_ modelName: String, _ onFetchProgress: @escaping (Float) -> Void) async throws {
        print("fetching model.....")
        let rawUrl =
            """
            ADD MODEL ZIP DOWNLOAD URL HERE
            """
        
        guard let url = URL(string: rawUrl) else {
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
    
    
}
