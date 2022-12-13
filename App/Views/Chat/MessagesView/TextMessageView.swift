//
//  TextMessageView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 13.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct TextMessageView: View {
    @ObservedObject var message: Message
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        if message.isAgent, let actionDeadline = message.actionDeadline, actionDeadline > Date(), !message.actionUsed {
            Text(.init(HtmlParser.getMarkdownString(from: message.wrappedText)))
                .accentColor(colorScheme == .light ? .blue : .accentColor)
                .padding(10)
        } else {
            Text(message.wrappedText)
                .padding(10)
        }
    }
}

#if DEBUG
struct TextMessageView_Previews: PreviewProvider {
    static let persistence = PersistenceController.preview
    
    static var message1: Message = {
        let context = persistence.container.viewContext
        return Message.getSampleMessage(for: context)
    }()
    
    static var message2: Message = {
        let context = persistence.container.viewContext
        return Message.getSampleMessage(for: context, with: "sdsc dscsdcvs")
    }()
    
    static var previews: some View {
        Group {
            MessageView(viewWidth: 450, message: message1)
                .padding()
                .previewLayout(.sizeThatFits)
            
            MessageView(viewWidth: 450, message: message2)
                .padding()
                .previewLayout(.sizeThatFits)
        }
    }
}
#endif
