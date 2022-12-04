//
//  TextInputImageView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 04.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct TextInputAttachmentView: View {
    @EnvironmentObject private var chatViewModel: ChatViewModel
    
    let attachment: ChatViewAttachment
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            switch attachment.type {
            case .image:
                Image(data: attachment.data)?
                    .resizable()
                    .scaledToFit()
            case.video:
                ZStack {
                    Rectangle()
                        .scaledToFit()
                    Image(systemName: "video.fill")
                        .foregroundColor(Color(UIColor.systemBackground))
                        .scaledToFit()
                }
            case .audio:
                ZStack {
                    Rectangle()
                        .scaledToFit()
                    Image(systemName: "waveform")
                        .foregroundColor(Color(UIColor.systemBackground))
                        .padding(10)
                }
            case .file:
                ZStack {
                    Rectangle()
                        .scaledToFit()
                    Image(systemName: "doc")
                        .foregroundColor(Color(UIColor.systemBackground))
                        .padding(10)
                }
            }
            
            Button(action: {
                if let index = chatViewModel.addedImages.firstIndex(of: attachment) {
                    chatViewModel.addedImages.remove(at: index)
                }
            }, label: {
                Image(systemName: "xmark.circle.fill")
                    .shadow(radius: 20)
                    .offset(x: 3, y: 3)
            })
        }
        .cornerRadius(10)
        .frame(height: 70)
    }
}

struct TextInputImageView_Previews: PreviewProvider {
    static var previews: some View {

        let img = UIImage(named: "UserAvatarExample")
        let data = img?.pngData()
        
        let attachment = ChatViewAttachment(data: data!, extention: "jpeg", realFilename: nil, type: .audio)

        return TextInputAttachmentView(attachment: attachment)
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
    }
}
