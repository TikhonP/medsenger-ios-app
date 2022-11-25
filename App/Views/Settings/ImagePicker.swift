//
//  ImagePicker.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 27.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: Data
    
    var edit: Bool = true
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {

        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = edit
        imagePicker.sourceType = sourceType
        imagePicker.mediaTypes = ["public.image"]
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
            
            if parent.edit {
                if let image = info[.editedImage] as? UIImage, let data = image.pngData() {
                    parent.selectedImage = data
                }
            } else {
                if let image = info[.originalImage] as? UIImage, let data = image.pngData() {
                    parent.selectedImage = data
                }
            }
            
            parent.presentationMode.wrappedValue.dismiss()
        }

    }
}

struct ImagePicker_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ImagePicker(selectedImage: .constant(Data()))
        }
    }
}
