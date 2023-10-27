//
//  AIModelProvider.swift
//  ml-sd-test
//
//  Created by Kenth Ljung on 2023-10-10.
//

import Foundation

protocol AIModelProvider {
    func isModelAvailable(_ modelName: String) -> Bool
    func fetchModel(_ modelName: String, _ onFetchProgress: @escaping (_ fractionDone: Float) -> Void) async throws -> Void
    func getStoredModelURL(_ modelName: String) throws -> URL
}
