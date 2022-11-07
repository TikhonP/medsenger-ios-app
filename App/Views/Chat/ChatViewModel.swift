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
    
    func fetchMessages(contractId: Int) {
        Messages.shared.getMessages(contractId: contractId)
    }
}
