//
//  AgentMessageView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 04.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct AgentMessageView: View {
    @ObservedObject var message: Message
    
    @EnvironmentObject private var chatViewModel: ChatViewModel
    
    var body: some View {
        Text(message.wrappedText)
    }
}

#if DEBUG
struct AgentMessageView_Previews: PreviewProvider {
    static let persistence = PersistenceController.preview
    
    static var message1: Message = {
        let context = persistence.container.viewContext
        return Message.getSampleMessage(for: context)
    }()
    
    static var previews: some View {
        AgentMessageView(message: message1)
            .environmentObject(ChatViewModel(contractId: 123))
    }
}
#endif
