//
//  File.swift
//  
//
//  Created by Kenth Ljung on 2023-10-27.
//

import Foundation

public struct ImageGeneratorServiceModel: Codable {
    public var downloadUrl: String = "https://laiban-test.s3.eu-north-1.amazonaws.com/sd-15-se2-q2.zip"
    public var positivePrompt: String = """
    masterpiece, best quality, absurdres, high quality, photorealistic, photography, macro
    """
    public var negativePrompt: String = """
    low quality, bad quality, worst quality, blurry, distorted, deformed, text, watermark, nsfw, nudity, human, people, person, man, woman, child
    """
    public var steps: Int = 15
    public var scale: Float = 7.0
    public var size: Int = 512
    public var reduceMemory: Bool = true
    public var useControlNet: Bool = false
}
