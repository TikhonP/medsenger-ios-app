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
    
    var body: some View {
        if let path = imageAttachment.dataPath, let uiImage = UIImage(contentsOfFile: path.path) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .onTapGesture {
                    chatViewModel.quickLookDocumentUrl = path
                }
        } else {
            ProgressView()
                .padding()
                .onAppear {
                    chatViewModel.fetchImageAttachment(imageAttachment)
                }
        }
    }
}

//struct MessageImageView_Previews: PreviewProvider {
//    static var previews: some View {
//        MessageImageView()
//    }
//}
