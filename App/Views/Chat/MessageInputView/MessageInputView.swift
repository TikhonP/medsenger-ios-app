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
                ZStack {
                    if let replyToMessage = chatViewModel.replyToMessage {
                        ReplyedMessageView(message: replyToMessage)
                    }
                }
                .transition(.slide)
                .animation(.default, value: chatViewModel.replyToMessage)
                
                ZStack {
                    if !chatViewModel.messageAttachments.isEmpty {
                        InputAttachmentsView()
                    }
                }
                .transition(.slide)
                .animation(.default, value: chatViewModel.messageAttachments)
                
                if !chatViewModel.isRecordingVoiceMessage && !chatViewModel.showRecordedMessage {
                    MainInputView()
                } else {
                    RecordingVoiceMessageView()
                }
            }
            .padding(.horizontal, 7)
            .padding(.vertical, 5)
        }
        .blurEffect(ignoresSafeAreaEdges: .all)
    }
}

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
