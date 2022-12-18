//
//  MessageTimeBadge.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 13.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct MessageTimeBadge: View {
    @ObservedObject var message: Message
    
    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    var body: some View {
        if let date = message.sent {
            Text(date, formatter: MessageTimeBadge.formatter)
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(1)
                .background(
                    Color(message.isMessageSent ? "SendedMessageBackgroundColor" : "RecievedMessageBackgroundColor").opacity(0.7))
                .cornerRadius(7)
                .padding(6)
        }
    }
}

#if DEBUG
struct MessageTimeBadge_Previews: PreviewProvider {
    static let persistence = PersistenceController.preview
    
    static var message: Message = {
        let context = persistence.container.viewContext
        return Message.getSampleMessage(
            for: context, with: #"""
            Улица. У магазина стоит коляска. Голос из коляски:
            - Ну бля, обоссался! Ну пиздец, еще и обосрался!
            Идет мимо мужчина и говорит:
            - Мальчик ты еще маленький, ходить не умеешь, а уже матом ругаешься.
            - Дядя, а ты ходить умеешь?
            - Умею.
            - Ну вот и пиздуй отсюда.
            """#, withReply: true)
    }()
    
    static var previews: some View {
        MessageView(viewWidth: 450, message: message)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif
