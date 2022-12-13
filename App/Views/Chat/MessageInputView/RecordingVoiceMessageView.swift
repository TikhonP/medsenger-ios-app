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
            Circle()
                .foregroundColor(.pink)
                .frame(height: 15)
            Text(timeLabel)
                .font(.caption)
            Spacer()
            Button("Cancel") {
                chatViewModel.finishRecording(success: false)
            }
            Spacer()
            Button(action: { chatViewModel.finishRecording(success: true) }, label: {
                MessageInputButtonLabel(imageSystemName: "stop.circle.fill", showProgress: .constant(false))
                    .foregroundColor(.primary.opacity(0.7))
            })
        }
    }
    
    private var timeLabel: String {
        let minutes = Int(chatViewModel.currentVoiceMessageTime / 60)
        let seconds = Int(chatViewModel.currentVoiceMessageTime.truncatingRemainder(dividingBy: 60))
//        let minutesString = minutes < 10 ? "0\(minutes)" : "\(minutes)"
        let secondsString = seconds < 10 ? "0\(seconds)" : "\(seconds)"
        return "\(minutes):\(secondsString)"
    }
}

#if DEBUG
struct RecordingVoiceMessageView_Previews: PreviewProvider {
    static var previews: some View {
        RecordingVoiceMessageView()
            .environmentObject(ChatViewModel(contractId: Int(33)))
            .previewLayout(PreviewLayout.sizeThatFits)
    }
}
#endif
