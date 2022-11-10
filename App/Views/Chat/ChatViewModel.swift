//
//  ChatViewModel.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 07.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import SwiftUI

final class ChatViewModel: ObservableObject {
    let contract: Contract
    
    init(contract: Contract) {
        self.contract = contract
    }
    
    @Published var message: String = ""
    @Published var messageIDToScroll: Int?
    @Published var lastMessageId: Int?
    
    func fetchMessages() {
        Messages.shared.getMessages(contractId: Int(contract.id)) {
            DispatchQueue.main.async {
                if let lastMessageId = self.lastMessageId {
                    self.messageIDToScroll = lastMessageId
                }
            }
        }
    }
    
    func sendMessage() {
        Messages.shared.sendMessage(message, contractId: Int(contract.id)) { messageId in
            DispatchQueue.main.async {
                self.messageIDToScroll = messageId
            }
        }
    }
}
