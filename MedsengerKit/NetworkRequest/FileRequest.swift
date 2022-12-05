//
//  FileRequest.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 02.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

/// Load file from `medsenger.ru` request
class FileRequest {
    private let url: URL
    
    /// Create object
    /// - Parameters:
    ///   - path: Path of the resource without query items and base host
    ///   - addApiKey: Append medsenger ApiKey from keychain as query item
    init(path: String, addApiKey: Bool = true) {
        var components = URLComponents(string: Constants.medsengerApiUrl)!
        components.path = components.path + path
        if addApiKey {
            components.queryItems = [
                URLQueryItem(name: "api_token", value: KeyChain.apiToken),
            ]
        }
        self.url = components.url!
    }
}

extension FileRequest: NetworkRequest {
    internal func decodeError(_ data: Data) -> Result<[String], Error> { return Result<[String], Error>.success([]) }
    
    internal func decode(_ data: Data) -> Result<Data, Error> { return Result<Data, Error>.success(data) }
    
    public func execute(withCompletion completion: @escaping NetworkRequestCompletion<Data>) {
        _ = load(method: .GET, url: url, parseResponse: true, withCompletion: completion)
    }
}
