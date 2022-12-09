//
//  NewImagePicker.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 05.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI
import PhotosUI

struct NewImagePicker: UIViewControllerRepresentable {
    public typealias PickedImagesCompletionHandler = (_ media: ImagePickerMedia) -> Void
    
    public let filter: PHPickerFilter?
    
    /// Setting the value to 0 sets the selection limit to the maximum that the system supports.
    public let selectionLimit: Int
    
    public let pickedCompletionHandler: PickedImagesCompletionHandler
    
    init(filter: PHPickerFilter? = nil, selectionLimit: Int = 0, pickedCompletionHandler: @escaping PickedImagesCompletionHandler) {
        self.filter = filter
        self.selectionLimit = selectionLimit
        self.pickedCompletionHandler = pickedCompletionHandler
    }
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = filter
        config.selectionLimit = selectionLimit
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: NewImagePicker
        
        init(_ parent: NewImagePicker) {
            self.parent = parent
        }
        
        internal func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            defer {
                picker.dismiss(animated: true)
            }
            guard !results.isEmpty else {
                return
            }
            
            for result in results {
                let itemProvider = result.itemProvider
                
                guard let typeIdentifier = itemProvider.registeredTypeIdentifiers.first, let utType = UTType(typeIdentifier) else {
                    continue
                }
                
                if utType.conforms(to: .movie) || utType.conforms(to: .image) {
                    loadFromFile(itemProvider, typeIdentifier, utType)
                } else {
                    loadLivePhotoAsImage(itemProvider, typeIdentifier, utType)
                }
            }
        }
        
        private func loadFromFile(_ itemProvider: NSItemProvider, _ typeIdentifier: String, _ utType: UTType) {
            itemProvider.loadFileRepresentation(forTypeIdentifier: typeIdentifier) { url, error in
                if let error = error {
                    print(error.localizedDescription)
                }
                guard let url = url else {
                    return
                }
                do {
                    let data = try Data(contentsOf: url)
                    
                    DispatchQueue.main.async {
                        self.parent.pickedCompletionHandler(
                            ImagePickerMedia(
                                data: data,
                                extention: url.pathExtension,
                                realFilename: url.lastPathComponent,
                                type: utType.conforms(to: .movie) ? .movie : .image)
                        )
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        
        private func loadLivePhotoAsImage(_ itemProvider: NSItemProvider, _ typeIdentifier: String, _ utType: UTType) {
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { data, error in
                    if let error = error {
                        print("Failed load photo: \(error.localizedDescription)")
                    }
                    if let image = data as? UIImage, let imageData = image.upOrientationImage()?.pngData() {
                        DispatchQueue.main.async {
                            self.parent.pickedCompletionHandler(
                                ImagePickerMedia(
                                    data: imageData,
                                    extention: "png",
                                    realFilename: nil,
                                    type: utType.conforms(to: .movie) ? .movie : .image)
                            )
                        }
                    }
                }
            }
        }
    }
}
