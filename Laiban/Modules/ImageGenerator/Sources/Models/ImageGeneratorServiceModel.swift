//
//  File.swift
//  
//
//  Created by Kenth Ljung on 2023-10-27.
//

import Foundation

public struct ImageGeneratorServiceModel: LBServiceModel, Codable {
    public var downloadUrl: String = "https://laiban-test.s3.eu-north-1.amazonaws.com/sd-15-se-q6-canny.zip"
    public var positivePrompt: String = """
    masterpiece, best quality, absurdres, high quality, photorealistic, photography, macro, symmetrical, centered, simple background, plain background, single, sharp
    """
    public var negativePrompt: String = """
    low quality, bad quality, framed, frame, painting, worst quality, blurry, distorted, deformed, text, watermark, nsfw, nudity, human, people, person, man, woman, child, asymmetrical, cropped, cut off, drawing, multiple, many
    """
    public var steps: Int = 15
    public var scale: Float = 9.0
    public var size: Int = 512
    public var reduceMemory: Bool = true
    public var useControlNet: Bool = true
    public var initOnStartup: Bool = false
    public var showOnDashboard: Bool = false
}
