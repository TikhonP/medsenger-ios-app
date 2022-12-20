//
//  ImagePicker.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 27.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI
import UniformTypeIdentifiers
import os.log

enum ImagePickerMediaTypes: String {
    case image = "public.image"
    case movie = "public.movie"
}

struct ImagePickerMedia: Equatable {
    
    internal static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: ImagePickerMedia.self)
    )
    
    let data: Data
    let extention: String
    let realFilename: String?
    let type: ImagePickerMediaTypes
    
    var mimeType: String {
        if let mimeType = UTType(filenameExtension: extention)?.preferredMIMEType {
            return mimeType
        } else {
            return "multipart/form-data"
        }
    }
    
    var randomFilename: String {
        let url = URL(fileURLWithPath: String.uniqueFilename(), relativeTo: nil)
        let fileURL = url.appendingPathExtension(extention)
        return fileURL.relativePath
    }
    
    var filename: String {
        realFilename ?? randomFilename
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedMedia: ImagePickerMedia?
    
    var sourceType: UIImagePickerController.SourceType
    var mediaTypes: [ImagePickerMediaTypes]
    var edit: Bool = false
    
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = edit
        imagePicker.sourceType = sourceType
        imagePicker.mediaTypes = mediaTypes.map { $0.rawValue }
        imagePicker.delegate = context.coordinator
        
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            defer {
                parent.presentationMode.wrappedValue.dismiss()
            }
            guard let mediaType = info[.mediaType] as? String, let type = ImagePickerMediaTypes(rawValue: mediaType) else {
                return
            }
                
            let data: Data
            let extention: String
            let realFilename: String?
            if parent.edit {
                guard let image = info[.editedImage] as? UIImage, let imageData = image.upOrientationImage()?.pngData() else {
                    return
                }
                extention = "png"
                data = imageData
                realFilename = nil
            } else {
                if parent.sourceType == .photoLibrary || parent.sourceType == .savedPhotosAlbum {
                    let url: URL
                    switch type {
                    case .image:
                        guard let imageURL = info[.imageURL] as? URL, let imageData = try? Data(contentsOf: imageURL) else {
                            ImagePickerMedia.logger.error("Failed to get data for selectedMedia.imageURL")
                            return
                        }
                        url = imageURL
                        data = imageData
                    case .movie:
                        guard let mediaURL = info[.mediaURL] as? URL, let mediaData = try? Data(contentsOf: mediaURL) else {
                            ImagePickerMedia.logger.error("Failed to get data for selectedMedia.mediaURL")
                            return
                        }
                        url = mediaURL
                        data = mediaData
                    }
                    extention = url.pathExtension
                    realFilename = url.lastPathComponent
                } else {
                    switch type {
                    case .image:
                        guard let image = info[.originalImage] as? UIImage, let imageData = image.upOrientationImage()?.pngData() else {
                            ImagePickerMedia.logger.error("Failed to get data for camera .originalImage")
                            return
                        }
                        extention = "png"
                        data = imageData
                        realFilename = nil
                    case .movie:
                        guard let mediaURL = info[.mediaURL] as? URL, let mediaData = try? Data(contentsOf: mediaURL) else {
                            ImagePickerMedia.logger.error("Failed to get data for camera selectedMedia.mediaURL")
                            return
                        }
                        extention = mediaURL.pathExtension
                        data = mediaData
                        realFilename = mediaURL.lastPathComponent
                    }
                }
            }
            let ImagePickerMedia = ImagePickerMedia(data: data, extention: extention, realFilename: realFilename, type: type)
            parent.selectedMedia = ImagePickerMedia
        }
    }
}

#if DEBUG
struct ImagePicker_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ImagePicker(selectedMedia: .constant(nil), sourceType: .photoLibrary, mediaTypes: [.image])
        }
    }
}
#endif
