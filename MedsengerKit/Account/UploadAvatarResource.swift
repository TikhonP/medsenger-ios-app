//
//  UploadAvatarResource.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 27.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

struct UploadAvatarResource: UploadImageResource {
    let image: Data
    
    typealias ModelType = User.JsonDecoder
    
    let paramName = "photo"
    let boundary = UUID().uuidString
    let fileName = UUID().uuidString
    
    var uploadData: Data {
        var data = Data()

        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(paramName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        data.append(image)

        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        return data
    }
    
    var methodPath = "/photo"
    
    var options: UploadImageResourceOptions {
        UploadImageResourceOptions(
            headers: ["Content-Type": "multipart/form-data; boundary=\(boundary)"]
        )
    }
}
