//
//  LocalBundleModelProvider.swift
//  ml-sd-test
//
//  Created by Kenth Ljung on 2023-10-10.
//

import Foundation

enum LocalBundleModelError: Error {
    case fetchMakesNoSense
    case noLocalModelFound
}

@available(iOS 16.0, *)
struct LocalBundleModelProvider : AIModelProvider {
    func isModelAvailable(_ modelName: String) -> Bool {
        return Bundle.main.path(forResource: modelName, ofType: nil, inDirectory: nil) != nil
    }
    
    func fetchModel(_ modelName: String, _ onFetchProgress: (Float) -> Void) async throws {
        throw LocalBundleModelError.fetchMakesNoSense
    }
    
    func getStoredModelURL(_ modelName: String) throws -> URL {
        guard let path = Bundle.main.path(forResource: modelName, ofType: nil, inDirectory: nil) else {
            throw LocalBundleModelError.noLocalModelFound
        }
        
        return URL(filePath: path)
    }
}
