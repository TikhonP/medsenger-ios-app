//
//  ReplyedMessageView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 07.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct ReplyedMessageView: View {
    @ObservedObject var message: Message
    @EnvironmentObject private var chatViewModel: ChatViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack {
            Image(systemName: "arrowshape.turn.up.left")
                .resizable()
                .scaledToFit()
                .padding(10)
                .frame(height: 38)
            RoundedRectangle(cornerRadius: 1)
                .background(colorScheme == .dark ? Color.primary : Color.accentColor)
                .frame(width: 2, height: 35)
                .padding(.leading)
            VStack(alignment: .leading) {
                if let contract = message.contract {
                    Text("Answer \(contract.wrappedShortName)")
                        .bold()
                }
                Text(message.wrappedText)
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                    .onTapGesture {
                        chatViewModel.scrollToMessageId = Int(message.id)
                    }
            }
            Spacer()
            Button(action: {
                chatViewModel.replyToMessage = nil
            }, label: {
                Image(systemName: "xmark")
                    .resizable()
                    .scaledToFit()
                    .padding(10)
                    .frame(width: 33)
            })
        }
        .foregroundColor(colorScheme == .dark ? .primary : .accentColor)
        .padding(.bottom, 5)
    }
}

//struct ReplyedMessageView_Previews: PreviewProvider {
//    static var previews: some View {
//        ReplyedMessageView()
//    }
//}
