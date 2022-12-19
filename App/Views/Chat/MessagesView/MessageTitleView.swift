//
//  MessageTitleView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 18.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct MessageTitleView: View {
    @ObservedObject var message: Message
    @EnvironmentObject private var chatViewModel: ChatViewModel
    
    var body: some View {
        HStack {
            Text(message.wrappedAuthor)
                .font(.caption2)
                .fontWeight(.bold)
            if message.isAgent {
                Text("Automatic message")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            } else {
                Text(message.wrappedAuthorRole)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 10)
        .padding(.top, 10)
        .padding(.bottom, 5)
    }
}

#if DEBUG
struct MessageTitleView_Previews: PreviewProvider {
    static let persistence = PersistenceController.preview
    
    static var message: Message = {
        let context = persistence.container.viewContext
        return Message.getSampleMessage(
            for: context, with: #"""
        Маленький мальчик заглянул в комнату, где мать принимала любовника, пока отец на работе. Сынишка спрятался в шкаф и оттуда подглядывал. Внезапно входит муж.
            Жена прячет любовника в шкаф, не зная, что ее сын там.
            Мальчик:
            — Темно здесь.
            — Да.
            — У меня есть футбольный мяч.
            — Это хорошо.
            — Вы не хотите его купить?
            — Нет, спасибо.
            — Мой отец снаружи.
            — Ок, сколько?
            — 250 долларов.
            Спустя несколько недель мальчик и мужчина снова встречаются в шкафу.
            Мальчик:
            — Темно здесь.
            — Да.
            — У меня есть кроссовки.
            Помня прошлый раз, мужчина спрашивает:
            — Сколько?
            — 750 долларов.
            — Ок.
            Спустя несколько дней отец предлагает сыну поиграть в футбол.
            — Я не могу, я продал мяч и кроссовки.
            — За сколько?
            — За 1000 баксов.
            — Но это намного больше, чем они стоят! Это грех, ты должен пойти в церковь и покаяться.
            В церкви мальчик зашел в исповедальню, закрыл дверь и сказал:
            — Темно здесь.
            Священник:
            — Черт побери, вот только не начинай, а!
"""#, withReply: true)
    }()
    
    static var previews: some View {
        MessageView(viewWidth: 450, message: message)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif
