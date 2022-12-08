//
//  RecordingVoiceMessageView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 08.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct RecordingVoiceMessageView: View {
    @EnvironmentObject private var chatViewModel: ChatViewModel
    
    var body: some View {
        HStack {
            if chatViewModel.isRecordingVoiceMessage {
                Circle()
                    .foregroundColor(.pink)
                    .frame(height: 15)
            }
            Text(timeLabel)
                .font(.caption)
            Spacer()
            Button("Cancel") {
                if chatViewModel.isRecordingVoiceMessage {
                    chatViewModel.finishRecording(success: false)
                } else {
                    chatViewModel.showRecordedMessage = false
                }
            }
            Spacer()
            if chatViewModel.isRecordingVoiceMessage {
                Button(action: { chatViewModel.finishRecording(success: true) }, label: {
                    MessageInputButtonLabel(imageSystemName: "stop.circle.fill", showProgress: .constant(false))
                        .foregroundColor(.primary.opacity(0.7))
                })
            } else {
                Button(action: chatViewModel.sendMessage, label: {
                    MessageInputButtonLabel(imageSystemName: "arrow.up.circle.fill", showProgress: $chatViewModel.showSendingMessageLoading)
                        .foregroundColor(.accentColor.opacity(0.7))
                })
            }
        }
    }
    
    private var timeLabel: String {
        let minutes = Int(chatViewModel.currentVoiceMessageTime / 60)
        let seconds = Int(chatViewModel.currentVoiceMessageTime.truncatingRemainder(dividingBy: 60))
        let minutesString = minutes < 10 ? "0\(minutes)" : "\(minutes)"
        let secondsString = seconds < 10 ? "0\(seconds)" : "\(seconds)"
        return "\(minutesString):\(secondsString)"
    }
}

struct RecordingVoiceMessageView_Previews: PreviewProvider {
    static var previews: some View {
        RecordingVoiceMessageView()
            .environmentObject(ChatViewModel(contractId: Int(33)))
            .previewLayout(PreviewLayout.sizeThatFits)
    }
}
