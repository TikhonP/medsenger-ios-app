//
//  SendMessageResouce.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 09.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

struct SendMessageResouce: APIResource {
    let text: String
    let contractID: Int
    let replyToId: Int?
    let images: Array<(String, Data)>
    let attachments: Array<(String, Data)>
    
    init(_ text: String, contractID: Int, replyToId: Int? = nil, images: Array<(String, Data)> = [], attachments: Array<(String, Data)> = []) {
        self.text = text
        self.contractID = contractID
        self.replyToId = replyToId
        self.images = images
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
        for (index, image) in images.enumerated() {
            data.append(
                MultipartFormData.Part(
                    contentDisposition: ContentDisposition(
                        name: Name(asPercentEncoded: "attachment[\(index)]"),
                        filename: Filename(asPercentEncoded: image.0)
                    ),
                    contentType: nil,
                    content: image.1
                )
            )
        }
        for (index, attachment) in attachments.enumerated() {
            data.append(
                MultipartFormData.Part(
                    contentDisposition: ContentDisposition(
                        name: Name(asPercentEncoded: "attachment[\(index)]".addingPercentEncoding(withAllowedCharacters: .alphanumerics)!),
                        filename: Filename(asPercentEncoded: attachment.0)
                    ),
                    contentType: nil,
                    content: attachment.1
                )
            )
        }
        return MultipartFormData(
            uniqueAndValidLengthBoundary: "boundary",
            body: data
        )
    }
    
    typealias ModelType = Message.JsonDeserializer
    
    var methodPath: String { "/\(Account.shared.role.clientsForHttpRequest)/\(contractID)/messages" }
    
    var options: APIResourceOptions {
        let httpBody: Data? = {
            switch multipartFormData.asData() {
            case let .valid(data):
                return data
            case let .invalid(error):
                print("Serilize `send message` form data error: \(error.localizedDescription)")
                return nil
            }
        }()
        
        return APIResourceOptions(
            dateDecodingStrategy: .secondsSince1970,
            parseResponse: true,
            httpBody: httpBody,
            httpMethod: "POST",
            headers: [multipartFormData.header.name: multipartFormData.header.value]
        )
    }
}
