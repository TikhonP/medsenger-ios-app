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
    let attachments: Array<URL>
    
    init(_ text: String, contractID: Int, replyToId: Int? = nil, images: Array<(String, Data)> = [], attachments: Array<URL> = []) {
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
                    contentType: ContentType(representing: MIMEType(text: image.1.mimeType)),
                    content: image.1
                )
            )
        }
        for (index, url) in attachments.enumerated() {
            do {
                let fileValue = try Data(contentsOf: url)
                data.append(
                    MultipartFormData.Part(
                        contentDisposition: ContentDisposition(
                            name: Name(asPercentEncoded: "attachment[\(index)]".addingPercentEncoding(withAllowedCharacters: .alphanumerics)!),
                            filename: Filename(asPercentEncoded: url.lastPathComponent)
                        ),
                        contentType: ContentType(representing: MIMEType(text: url.mimeType())),
                        content: fileValue
                    )
                )
            } catch {
                print("Send message resource: Failed to read data: \(error.localizedDescription)")
            }
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
                print("Serilize `send message` form data error: \(error.localizedDescription)")
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
