//
//  SendMessageResouce.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 09.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import os.log

struct SendMessageResouce: APIResource {
    let text: String
    let contractID: Int
    let replyToId: Int?
    let attachments: Array<(String, Data)>
//    let attachments: Array<URL>
    
    init(_ text: String, contractID: Int, replyToId: Int? = nil, attachments: Array<(String, Data)> = []) {
        self.text = text
        self.contractID = contractID
        self.replyToId = replyToId
        self.attachments = attachments
    }
    
    var multipartFormData: MultipartFormData {
        var data: [MultipartFormData.Part] = [
            MultipartFormData.Part(
                contentDisposition: ContentDisposition(
                    name: Name(asPercentEncoded: "text"),
                    filename: nil
                ),
                contentType: nil,
                content: text.data(using: .utf8)!
            )
        ]
        if let replyToId = replyToId {
            data.append(
                MultipartFormData.Part(
                    contentDisposition: ContentDisposition(
                        name: Name(asPercentEncoded: "reply_to_id"),
                        filename: nil
                    ),
                    contentType: nil,
                    content: String(replyToId).data(using: .utf8)!
                )
            )
        }
        for (index, attachment) in attachments.enumerated() {
            data.append(
                MultipartFormData.Part(
                    contentDisposition: ContentDisposition(
                        name: Name(asPercentEncoded: "attachment[\(index)]"),
                        filename: Filename(asPercentEncoded: attachment.0)
                    ),
                    contentType: ContentType(representing: MIMEType(text: attachment.1.mimeType)),
                    content: attachment.1
                )
            )
        }
        return MultipartFormData(
            uniqueAndValidLengthBoundary: "boundary",
            body: data
        )
    }
    
    typealias ModelType = Message.JsonDecoder
    
    var methodPath: String { "/\(UserDefaults.userRole.clientsForNetworkRequest)/\(contractID)/messages" }
    
    var options: APIResourceOptions {
        let multipartFormData = multipartFormData
        let httpBody: Data? = {
            switch multipartFormData.asData() {
            case let .valid(data):
                return data
            case let .invalid(error):
                Logger.urlRequest.error("Serialize `send message` form data error: \(error.localizedDescription)")
                return nil
            }
        }()
        
        return APIResourceOptions(
            dateDecodingStrategy: .secondsSince1970,
            parseResponse: true,
            httpBody: httpBody,
            httpMethod: .POST,
            headers: [multipartFormData.header.name: multipartFormData.header.value]
        )
    }
}
