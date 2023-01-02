//
//  NSItemProvider+loadFileRepresentation.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 02.01.2023.
//  Copyright © 2023 TelePat ltd. All rights reserved.
//

import Foundation

extension NSItemProvider {
    struct EmptyURLError: Error {}
    
    /// Asynchronously writes a copy of the provided, typed data to a temporary file, returning a file data
    func loadFileRepresentation(forTypeIdentifier typeIdentifier: String) async throws -> (Data, URL) {
        try await withCheckedThrowingContinuation { continuation in
            loadFileRepresentation(forTypeIdentifier: typeIdentifier) { url, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let url = url else {
                    continuation.resume(throwing: EmptyURLError())
                    return
                }
                do {
                    let data = try Data(contentsOf: url)
                    continuation.resume(returning: (data, url))
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
