//
//  ImageAttachment+Wrappers.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 06.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

extension ImageAttachment {
    public var wrappedName: String {
        name ?? "Unknown name"
    }
}

extension ImageAttachment {
    public var dataPath: URL? {
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
            ImageAttachment.logger.error("FileManager.default.urls directory is nil")
            return nil
        }
        guard let localFileName = localFileName else {
            return nil
        }
        return URL(fileURLWithPath: localFileName, relativeTo: directory)
    }
}
