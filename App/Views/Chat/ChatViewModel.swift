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
    @Published var messageIDToScroll: Int?
    
    private var contractId: Int
    
    init(contractId: Int) {
        self.contractId = contractId
    }

    private func scrollToLastMessage() {
        DispatchQueue.main.async {
            guard let contract = Contract.get(id: self.contractId) else {
                return
            }
            self.messageIDToScroll = Int(contract.lastFetchedMessageId)
        }
    }
    
    func fetchMessages() {
        Messages.shared.getMessages(contractId: contractId) {
            self.scrollToLastMessage()
        }
    }
    
    func sendMessage() {
        Messages.shared.sendMessage(message, contractId: contractId) {
            self.scrollToLastMessage()
        }
    }
}
