//
//  File.swift
//  
//
//  Created by Kenth Ljung on 2023-10-27.
//

import Foundation

public struct ImageGeneratorServiceModel: Codable {
    public var downloadUrl: String = "https://example.com/"
    public var positivePrompt: String = "masterpiece, best quality"
    public var negativePrompt: String = "low quality, bad quality, worst quality, blurry"
    public var steps: Int = 15
    public var scale: Float = 7.0
    public var size: Int = 512
    public var reduceMemory: Bool = true
}
