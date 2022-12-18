//
//  MessageInputView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 30.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct MessageInputView: View {
    @EnvironmentObject private var messageInputViewModel: MessageInputViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
                .edgesIgnoringSafeArea(.horizontal)
            VStack {
                if let replyToMessage = messageInputViewModel.replyToMessage {
                    ReplyedMessageView(message: replyToMessage)
                        .transition(.move(edge: .bottom))
                }
                
                if !messageInputViewModel.messageAttachments.isEmpty {
                    InputAttachmentsView()
                        .transition(.move(edge: .bottom))
                }
                
                if !messageInputViewModel.isRecordingVoiceMessage && !messageInputViewModel.showRecordedMessage {
                    MainInputView()
                } else if messageInputViewModel.isRecordingVoiceMessage {
                    RecordingVoiceMessageView()
                } else if messageInputViewModel.showRecordedMessage {
                    RecordedVoiceMessageView()
                }
            }
            .padding(.horizontal, 7)
            .padding(.vertical, 5)
        }
        .blurEffect(ignoresSafeAreaEdges: .all)
        .alert(item: $messageInputViewModel.alert) { $0.alert }
        .animation(.default, value: messageInputViewModel.messageAttachments)
        .animation(.default, value: messageInputViewModel.replyToMessage)
        .animation(.default, value: messageInputViewModel.isRecordingVoiceMessage)
        .animation(.default, value: messageInputViewModel.showRecordedMessage)
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
