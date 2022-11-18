//
//  ChatViewModel.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 07.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

final class ChatViewModel: ObservableObject {
    @Published var message: String = ""
    
    private var contractId: Int
    
    init(contractId: Int) {
        self.contractId = contractId
    }

    func fetchMessages() {
        Messages.shared.getMessages(contractId: contractId)
    }
    
    func sendMessage() {
        if !self.message.isEmpty {
            let message = self.message
            self.message = ""
            Messages.shared.sendMessage(message, contractId: contractId)
        }
    }
}
