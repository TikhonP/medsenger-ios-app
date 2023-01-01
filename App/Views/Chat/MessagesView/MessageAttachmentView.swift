//
//  MessageAttachmentView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 13.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct MessageAttachmentView: View {
    @ObservedObject var attachment: Attachment
    @EnvironmentObject private var chatViewModel: ChatViewModel
    
    var body: some View {
        Button {
            Task(priority: .userInitiated) {
                await chatViewModel.showAttachmentPreview(attachment)
            }
        } label: {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.accentColor)
                    if chatViewModel.loadingAttachmentIds.contains(Int(attachment.id)) {
                        ProgressView()
                            .padding(7)
                    } else {
                        Image(systemName: attachment.iconAsSystemImageName)
                            .resizable()
                            .scaledToFit()
                            .padding(7)
                    }
                }
                .frame(height: 30)
                .animation(.default, value: chatViewModel.loadingAttachmentIds)
                
                Text(attachment.wrappedName)
                
            }
            .padding(10)
        }
    }
}

#if DEBUG
struct MessageAttachmentView_Previews: PreviewProvider {
    static let persistence = PersistenceController.preview
    
    static var message1: Message = {
        let context = persistence.container.viewContext
        return Message.getSampleMessage(for: context)
    }()
    
    static var message2: Message = {
        let context = persistence.container.viewContext
        return Message.getSampleMessage(for: context, with: "sdsc dscsdcvs")
    }()
    
    static var previews: some View {
        Group {
            MessageView(viewWidth: 450, message: message1)
                .padding()
                .previewLayout(.sizeThatFits)
            
            MessageView(viewWidth: 450, message: message2)
                .padding()
                .previewLayout(.sizeThatFits)
        }
    }
}
#endif
