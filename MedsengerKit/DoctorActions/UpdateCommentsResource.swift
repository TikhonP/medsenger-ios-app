//
//  UpdateCommentsResource.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 07.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

struct UpdateCommentsResource: APIResource {
    let contractId: Int
    let comment: String
    
    typealias ModelType = EmptyModel
    
    var methodPath: String { "/comments/\(contractId)" }
    
    var options: APIResourceOptions {
        let formdata = multipartFormData(textParams: [
            "comments": comment
        ])
        return APIResourceOptions(
            method: .POST,
            httpBody: formdata.httpBody,
            headers: formdata.headers
        )
    }
    
    let apiErrors: [APIResourceError<Error>] = []
}
