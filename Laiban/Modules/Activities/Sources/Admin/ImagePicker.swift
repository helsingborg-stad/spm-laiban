//
//  ImagePicker.swift
//
//  Created by Tomas Green on 2020-05-05.
//

import SwiftUI
import Combine


struct ImagePicker : UIViewControllerRepresentable {
    @Binding var isShown: Bool
    var imageStorage:LBImageStorage
    var completionHandler:PhotoCaptureView.CompletionHandler
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        
    }
    func makeCoordinator() -> ImagePickerCordinator {
        return ImagePickerCordinator(isShown: $isShown, imageStorage: imageStorage, completionHandler: completionHandler)
    }
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
}

class ImagePickerCordinator : NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    @Binding var isShown: Bool
    var imageStorage:LBImageStorage
    var completionHandler:PhotoCaptureView.CompletionHandler
    init(isShown : Binding<Bool>, imageStorage:LBImageStorage, completionHandler: @escaping PhotoCaptureView.CompletionHandler) {
        _isShown = isShown
        self.imageStorage = imageStorage
        self.completionHandler = completionHandler
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let name = imageStorage.write(image: info[.originalImage] as! UIImage) {
            completionHandler(name)
        }
        isShown = false
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        isShown = false
    }
}

struct PhotoCaptureView: View {
    typealias CompletionHandler = (String) -> Void
    @Binding var showImagePicker: Bool
    var imageStorage:LBImageStorage
    var completionHandler:CompletionHandler
    var body: some View {
        ImagePicker(isShown: $showImagePicker, imageStorage: imageStorage, completionHandler: completionHandler)
    }
}

struct PhotoCaptureView_Previews: PreviewProvider {
    static var previews: some View {
        PhotoCaptureView(showImagePicker: .constant(false),imageStorage: LBImageStorage(folder: "previewimage")) { asset in
            
        }
    }
}
