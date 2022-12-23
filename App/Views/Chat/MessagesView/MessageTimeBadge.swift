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
    
    var body: some View {
        if let date = message.sent {
            Text(date, style: .time)
                .font(.caption2)
                .foregroundColor(.secondary)
                .shadow(color: backgroundColor, radius: 30)
                .padding(7)
        }
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
