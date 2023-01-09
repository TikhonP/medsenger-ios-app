//
//  SendMessageResouce.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 09.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import os.log

/// Send message to chat
struct SendMessageResouce: APIResource {
    let text: String
    let contractID: Int
    let replyToId: Int?

    /// Array of file data ``ChatViewAttachment``
    let attachments: Array<ChatViewAttachment>
    
    init(text: String, contractID: Int, replyToId: Int?, attachments: Array<ChatViewAttachment>) {
        self.text = text
        self.contractID = contractID
        self.replyToId = replyToId
        self.attachments = attachments
    }
    
    var params: [String: String] {
        var params = ["text": text]
        if let replyToId = replyToId {
            params["reply_to_id"] = String(replyToId)
        }
        return params
    }
    
    var files: [MultipartFormData.Part] {
        var files = [MultipartFormData.Part]()
        for (index, attachment) in attachments.enumerated() {
            files.append(
                MultipartFormData.Part(
                    contentDisposition: ContentDisposition(
                        name: Name(asPercentEncoded: "attachment[\(index)]"),
                        filename: Filename(asPercentEncoded: attachment.filename)
                    ),
                    contentType: ContentType(representing: MIMEType(text: attachment.mimeType)),
                    content: attachment.data
                )
            )
        }
        return files
    }
    
    typealias ModelType = Message.JsonDeserializer
    
    var methodPath: String { "/\(UserDefaults.userRole.clientsForNetworkRequest)/\(contractID)/messages" }
    
    var options: APIResourceOptions {
        let result = multipartFormData(textParams: params, files: files)
        return APIResourceOptions(
            parseResponse: true,
            method: .POST,
            httpBody: result.httpBody,
            headers: result.headers,
            dateDecodingStrategy: .secondsSince1970
        )
    }
    
    let apiErrors: [APIResourceError<Error>] = []
}
