//
//  ImageStorage.swift
//
//  Created by Tomas Green on 2020-09-10.
//

import Foundation
import SwiftUI
import UIKit
import Shout
import Analytics

extension UIImage.Orientation {
    var imageOrienatation:Image.Orientation {
        switch self {
        case .up: return Image.Orientation.up
        case .down: return Image.Orientation.down
        case .left: return Image.Orientation.left
        case .right: return Image.Orientation.right
        case .upMirrored: return Image.Orientation.upMirrored
        case .downMirrored: return Image.Orientation.downMirrored
        case .leftMirrored: return Image.Orientation.leftMirrored
        case .rightMirrored: return Image.Orientation.rightMirrored
        @unknown default:
            print("unkown orientation")
            return .up
        }
    }
}
public struct LBImageStorage {
    public let folder:String
    public let maxWidth:CGFloat?
    public let maxHeight:CGFloat?
    public init(folder:String,maxWidth:CGFloat? = nil,maxHeight:CGFloat? = nil) {
        self.folder = folder
        self.maxWidth = maxWidth
        self.maxHeight = maxHeight
    }
    public func url(for image:String?) -> URL? {
        guard let name = image else {
            return nil
        }
        return try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false).appendingPathComponent(folder).appendingPathComponent(name)
    }
    public func write(image:UIImage) -> String? {
        var image = image
        if let w = maxWidth {
            image = image.resizeImage(w, opaque: true)
        }
        let name = UUID().uuidString + ".jpeg"
        let fileManager = FileManager.default
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create:false)
            let fileURL = documentDirectory.appendingPathComponent(folder).appendingPathComponent(name)
            if fileManager.fileExists(atPath: documentDirectory.appendingPathComponent(folder).path) == false {
                try fileManager.createDirectory(at: documentDirectory.appendingPathComponent(folder), withIntermediateDirectories: true, attributes: nil)
            }
            if let imageData = image.jpegData(compressionQuality: 0.5) {
                try imageData.write(to: fileURL)
                return name
            }
        } catch {
            AnalyticsService.shared.logError(error)
            print("⛔️ [\(#fileID):\(#function):\(#line)] " + String(describing: error))
        }
        return nil
    }
    public func delete(image:String?) {
        if let url = url(for: image) {
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                AnalyticsService.shared.logError(error)
                print("⛔️ [\(#fileID):\(#function):\(#line)] " + String(describing: error))
            }
        }
    }
    public func exists(name:String?) -> Bool {
        guard let name = name, let url = url(for: name) else {
            return false
        }
        return FileManager.default.fileExists(atPath: url.path)
    }
    public func data(for name:String?) -> Data? {
        guard let name = name, let url = url(for: name) else {
            return nil
        }
        do {
            return try Data(contentsOf: url)
        } catch {
            AnalyticsService.shared.logError(error)
            print("⛔️ [\(#fileID):\(#function):\(#line)] " + String(describing: error))
        }
        return nil
    }
    public func image(with name:String?) -> Image? {
        guard let name = name, let url = url(for: name) else {
            return nil
        }
        do {
            let data = try Data(contentsOf: url)
            if let img = UIImage(data: data) {
                return Image(img.cgImage!, scale: img.scale, orientation: img.imageOrientation.imageOrienatation, label: Text(name))
            }
        } catch {
            AnalyticsService.shared.logError(error)
            print("⛔️ [\(#fileID):\(#function):\(#line)] " + String(describing: error))
        }
        return nil
    }
}
extension UIImage {
    //func resizeImage(_ dimension: CGFloat, opaque: Bool, contentMode: UIView.ContentMode = .scaleAspectFit) -> UIImage
    func resizeImage(_ dimension: CGFloat, opaque: Bool) -> UIImage {
        var width: CGFloat
        var height: CGFloat
        var newImage: UIImage
        
        let size = self.size
        let aspectRatio =  size.width/size.height
        
        if aspectRatio > 1 {                            // Landscape image
            width = dimension
            height = dimension / aspectRatio
        } else {                                        // Portrait image
            height = dimension
            width = dimension * aspectRatio
        }
        if #available(iOS 10.0, *) {
            let renderFormat = UIGraphicsImageRendererFormat.default()
            renderFormat.opaque = opaque
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: renderFormat)
            newImage = renderer.image {
                (context) in
                self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), opaque, 0)
            self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
            newImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
        }
        
        return newImage
    }
}
