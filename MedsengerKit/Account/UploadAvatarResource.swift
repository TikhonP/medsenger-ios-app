//
//  UploadAvatarResource.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 27.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

struct UploadAvatarResource: APIResource {
    let image: ImagePickerMedia

    typealias ModelType = User.JsonDecoder
    
    var files: [MultipartFormData.Part] {
        [MultipartFormData.Part(
            contentDisposition: ContentDisposition(
                name: Name(asPercentEncoded: "photo"),
                filename: Filename(asPercentEncoded: image.filename)
            ),
            contentType: ContentType(representing: MIMEType(text: image.mimeType)),
            content: image.data
        )]
    }
    
    var methodPath = "/photo"
    
    var options: APIResourceOptions {
        let result = multipartFormData(files: files)
        return APIResourceOptions(
            method: .POST,
            httpBody: result.httpBody,
            headers: result.headers
        )
    }
}
