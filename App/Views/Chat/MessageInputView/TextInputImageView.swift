//
//  TextInputImageView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 04.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct TextInputAttachmentView: View {
    @State var attachment: ChatViewAttachment
    
    @EnvironmentObject private var chatViewModel: ChatViewModel
    @EnvironmentObject private var messageInputViewModel: MessageInputViewModel
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Group {
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
                            .foregroundColor(.systemBackground)
                            .scaledToFit()
                    }
                case .audio:
                    ZStack {
                        Rectangle()
                            .scaledToFit()
                        Image(systemName: "waveform")
                            .foregroundColor(.systemBackground)
                            .padding(10)
                    }
                case .file:
                    ZStack {
                        Rectangle()
                            .scaledToFit()
                        Image(systemName: "doc")
                            .foregroundColor(.systemBackground)
                            .padding(10)
                    }
                }
            }
            .onTapGesture {
                if let url = attachment.saveToFile() {
                    chatViewModel.quickLookDocumentUrl = url
                }
            }
            
            Button(action: {
                if let index = messageInputViewModel.messageAttachments.firstIndex(of: attachment) {
                    messageInputViewModel.messageAttachments.remove(at: index)
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

#if DEBUG
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
#endif
