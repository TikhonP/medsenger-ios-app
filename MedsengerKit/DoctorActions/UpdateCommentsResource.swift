//
//  UpdateCommentsResource.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 07.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

class UpdateCommentsResource: APIResource {
    let contractId: Int
    let comment: String
    
    init(contractId: Int, comment: String) {
        self.contractId = contractId
        self.comment = comment
    }
    
    typealias ModelType = EmptyModel
    
    lazy var methodPath: String = { "/comments/\(contractId)" }()
    
    lazy var options: APIResourceOptions = {
        let formdata = multipartFormData(textParams: [
            "comments": comment
        ])
        return APIResourceOptions(
            method: .POST,
            httpBody: formdata.httpBody,
            headers: formdata.headers
        )
    }()
}
