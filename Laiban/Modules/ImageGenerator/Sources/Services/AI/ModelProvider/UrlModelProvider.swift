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
            https://laiban-test.s3.eu-north-1.amazonaws.com/apple_coreml-stable-diffusion-2-1-base_einsum.zip?response-content-disposition=inline&X-Amz-Security-Token=IQoJb3JpZ2luX2VjELn%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaCmV1LW5vcnRoLTEiRzBFAiBARuuJHiDbQPsf3RODkCDfcTECrJhevpGjFV88KmQvuQIhAN7ChWVez3xO2dJJDsPmEAy7PYPOVBCywSiUIYvgsaxhKoAECNL%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEQARoMNDk3MDI0MzMzMTUxIgzVjF9pvVYYo%2BakcgEq1AOlNGqOBOSCDJEtqD179BLT1ItpTncsXE3fiHXOJ9gNVz13bq%2FhjMJv3FStchS55WSbIMfHZtu80CvG4PFY4XuFy1ys0D%2BQAV09YlebyXxMWEzY9jpGNZ2%2Fp%2B%2FFgfk2TIRgtpmhEy3hziR6mv5Z4e%2Bq%2BoW9ryvkbQ1dJSWhTLctXx5Ssu0AlyAndZvpcEwaJi1ZXCcsz6QhuLamXASVS7jNnFzlidzWX%2FnioA5xHGtWWRbpJLGM7yVwqwze3neGqm9m1pmrVZ6kvKB7XoOl%2BM782GQcUeJwDG%2Bk2LGb4%2FLc0oa69Wj%2B2Hu88QxkCS5YHndQmky%2Bk2%2Bmx9YTajv6PPZXc7UmrQBcXgbzzDP7imoLSRBYMxGyblXQC6snUW%2FC8hznJuMTRJq9Rf%2FfUzYkgutQvH8l%2FOQkejzbp178xOBO9a1sehoModkUn%2F5f7M9Im%2BoscDz4Q9hM2b1xT%2B%2F%2FnEyFxvE1DcueuEuin8jbHs3U6TpEeaEpipeyfS7hrisirPy3qaB5EHcPDcGIjnfWweSIwWciV4Jdv2lzzwUijTE%2BIoeIiC8uOmlTPcw%2F7mOMTO%2Fr0iq8R9zEOcWcxUd0V%2FWnWaHuldUsP8kmXU2VTXrpTJH9%2Fu8w9IjJqQY6lAKEl%2BkOn8Q1r7QL6XPDfc7oSHGEX6X%2FIrb4n1qooa8svVukdkZdcLaygLSvPzEeRfFAgHEAnNpp7%2BoTxZ04tlRINs0nDZox%2BCn2ZL3ma7iJowq7FiNpXGsTMAiU3dveSYkt3An%2BZrlzbDEjPFc%2B0awIl%2FeJeET1pJgsSlbs%2Ft603xmDc65N%2FL05pEgJ5RWyHVzEeITKzPrY%2FfFr3yi49CgoWgc5WqZSpVhzrM5c7fK947DqmX6RfV3wLCdFFCUnUT6Jzmn%2B9xn3A%2FPu7sDUdYzoMbsLWWElDLj16Iz7S2cnySxX4GYOsymPvAVRGnEEPg%2F%2BnjBpX7BhYWgRYYHWxncgI3ahGt5iDyEd6yJxkv3P0QhhMd0%3D&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20231020T091244Z&X-Amz-SignedHeaders=host&X-Amz-Expires=43200&X-Amz-Credential=ASIAXHOHVOVP23C2K47F%2F20231020%2Feu-north-1%2Fs3%2Faws4_request&X-Amz-Signature=58b7d29690c108b234fe6a241814c15ad85f1fc6aba4b92d37081931d8ff3a83
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
