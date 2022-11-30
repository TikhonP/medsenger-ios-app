//
//  URL+mimeType.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 23.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import UniformTypeIdentifiers

extension URL {
    public func mimeType() -> String {
        if let mimeType = UTType(filenameExtension: pathExtension)?.preferredMIMEType {
            return mimeType
        } else {
            return "application/octet-stream"
        }
    }
}
