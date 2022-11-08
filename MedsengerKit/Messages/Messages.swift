//
//  Messages.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 07.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

class Messages {
    static let shared = Messages()
    
    private var getMessagesRequest: APIRequest<MessagesResource>?
    
    public func getMessages(contractId: Int) {
        let messagesResource = MessagesResource(contractId: contractId)
        getMessagesRequest = APIRequest(resource: messagesResource)
        getMessagesRequest?.execute { result in
            switch result {
            case .success:
                break
            case .SuccessData(let data):
                Message.saveFromJson(data: data, contractId: contractId)
                print("Done messages")
            case .Error(let error):
                processRequestError(error, "get messages for contract \(contractId)")
            }
        }
    }
}
