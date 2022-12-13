//
//  ReplyPreviewView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 13.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct ReplyPreviewView: View {
    @ObservedObject var replyedMessage: Message
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var chatViewModel: ChatViewModel
    
    var body: some View {
        Button(action: {
            chatViewModel.scrollToMessageId = Int(replyedMessage.id)
        }, label: {
            HStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 2)
                    .background(colorScheme == .dark ? Color.primary : Color.accentColor)
                    .frame(width: 2, height: 42)
                    .padding(.trailing, 10)
                Text(replyedMessage.wrappedText)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
            }
            .padding(10)
        })
    }
}

#if DEBUG
struct ReplyPreviewView_Previews: PreviewProvider {
    static let persistence = PersistenceController.preview
    
    static var message: Message = {
        let context = persistence.container.viewContext
        return Message.getSampleMessage(
            for: context, with: #"Случай в театре. Спектакль для детей. Момент, где вот-вот должен появиться главный злодей - свет выключен, оркестр настороженно так жужжит. в зале тишина. И тут такой тоненький детский голосок: "@б твою мать! Страшно-то как!!!""#, withReply: true)
    }()
    
    static var previews: some View {
        MessageView(viewWidth: 450, message: message)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif
