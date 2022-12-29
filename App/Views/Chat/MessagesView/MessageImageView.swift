//
//  MessageImageView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 04.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct MessageImageView: View {
    @ObservedObject var imageAttachment: ImageAttachment
    @EnvironmentObject private var chatViewModel: ChatViewModel
    @AppStorage(UserDefaults.Keys.showFullPreviewForImagesKey) private var showFullPreviewForImages: Bool = UserDefaults.showFullPreviewForImages
    
    var body: some View {
        ZStack {
            if showFullPreviewForImages {
                image
            } else {
                HStack {
                    image
                        .clipShape(Rectangle())
                        .frame(height: 50)
                        .cornerRadius(10)
                    Text(imageAttachment.wrappedName)
                }
                .padding(10)
            }
        }
        .onTapGesture {
            openFullImagePreview()
        }
    }
    
    var image: some View {
        ZStack {
            if let path = imageAttachment.dataPath, let uiImage = UIImage(contentsOfFile: path.path) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            } else {
                HStack {
                    Spacer()
                    ProgressView()
                        .padding()
                        .onAppear {
                            Task {
                                await chatViewModel.fetchImageAttachment(imageAttachment)
                            }
                        }
                    Spacer()
                }
            }
        }
    }
    
    func openFullImagePreview() {
        chatViewModel.quickLookDocumentUrl = imageAttachment.dataPath
    }
}

//struct MessageImageView_Previews: PreviewProvider {
//    static var previews: some View {
//        MessageImageView()
//    }
//}
