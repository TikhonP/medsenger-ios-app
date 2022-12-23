//
//  VideoCallMessageView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 19.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct VideoCallMessageView: View {
    let viewWidth: CGFloat
    
    @ObservedObject var message: Message
    @EnvironmentObject private var chatViewModel: ChatViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 0) {
                Text(message.wrappedAuthor)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .padding(.top, 10)
                    .padding(.bottom, 5)
                HStack {
                    Image(systemName: "phone")
                        .padding([.trailing], 5)
                    VStack(alignment: .leading) {
                        Text("VideoCallMessageView.CallFromDoctor.Label")
                        Text(message.wrappedText)
                    }
                }
            }
            .foregroundColor(foregroundColor)
            .padding(.bottom, 20)
            .padding(.horizontal, 10)
            MessageTimeBadge(message: message)
        }
        .background(backgroundColor)
        .cornerRadius(20)
        .frame(width: viewWidth * 0.7, alignment: message.isMessageSent ? .trailing : .leading)
        .frame(maxWidth: .infinity, alignment: message.isMessageSent ? .trailing : .leading)
    }
    
    var backgroundColor: Color {
        if message.isAgent, message.isUrgent {
            return Color("MessageDangerColor")
        } else if message.isAgent, message.isWarning {
            return Color("MessageWarningColor")
        } else if message.isMessageSent {
            return Color("SendedMessageBackgroundColor")
        } else {
            return Color("RecievedMessageBackgroundColor")
        }
    }
    
    var foregroundColor: Color {
        if message.isAgent, message.isUrgent {
            return .white
        } else if message.isAgent, message.isWarning {
            return .white
        } else if colorScheme == .light, !message.isMessageSent {
            return .white
        } else {
            return .primary
        }
    }
}

//struct VideoCallMessageView_Previews: PreviewProvider {
//    static var previews: some View {
//        VideoCallMessageView()
//    }
//}
