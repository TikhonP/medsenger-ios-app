//
//  MessageInputView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 30.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct MessageInputView: View {
    @EnvironmentObject private var chatViewModel: ChatViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .edgesIgnoringSafeArea(.horizontal)
            VStack {
                if let replyToMessage = chatViewModel.replyToMessage {
                    ReplyedMessageView(message: replyToMessage)
                        .transition(.move(edge: .bottom))
                }
                
                if !chatViewModel.messageAttachments.isEmpty {
                    InputAttachmentsView()
                        .transition(.move(edge: .bottom))
                }
                
                if !chatViewModel.isRecordingVoiceMessage && !chatViewModel.showRecordedMessage {
                    MainInputView()
                } else if chatViewModel.isRecordingVoiceMessage {
                    RecordingVoiceMessageView()
                } else if chatViewModel.showRecordedMessage {
                    RecordedVoiceMessageView()
                }
            }
            .padding(.horizontal, 7)
            .padding(.vertical, 5)
        }
        .blurEffect(ignoresSafeAreaEdges: .all)
        .animation(.default, value: chatViewModel.messageAttachments)
        .animation(.default, value: chatViewModel.replyToMessage)
        .animation(.default, value: chatViewModel.isRecordingVoiceMessage)
        .animation(.default, value: chatViewModel.showRecordedMessage)
    }
}

#if DEBUG
struct MessageInputView_Previews: PreviewProvider {
    //    static let persistence = PersistenceController.preview
    //
    //    static var contract1: Contract = {
    //        let context = persistence.container.viewContext
    //        return Contract.createSampleContract1(for: context)
    //    }()
    //
    static var previews: some View {
        MessageInputView()
        //            .environment(\.managedObjectContext, persistence.container.viewContext)
            .environmentObject(ChatViewModel(contractId: Int(33)))
            .previewLayout(PreviewLayout.sizeThatFits)
    }
}
#endif
