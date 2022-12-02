//
//  APIRequest.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 02.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

/// `medsenger.ru` response base model
struct Wrapper<T: Decodable>: Decodable {
    enum status: String, Decodable {
        case success, error
    }
    
    let state: status
    let data: T
}

/// `medsenger.ru` error model
struct ErrorReponse: Decodable {
    let error: Array<String>
    let state: String
}

/// The HTTP API request to `medsenger.ru` with JSON data
class APIRequest<Resource: APIResource> {
    
    /// API resource: data for specific request
    private let resource: Resource
    
    /// Create object
    /// - Parameter resource: data for specific request
    init(_ resource: Resource) {
        self.resource = resource
    }
}

extension APIRequest: NetworkRequest {
    
    /// Returns a value of the type you specify, decoded from a JSON object.
    /// - Parameters:
    ///   - type: The type of the value to decode from the supplied JSON object.
    ///   - data: The JSON object to decode.
    ///   - dateDecodingStrategy: The strategy used when decoding dates from part of a JSON object.
    ///   - keyDecodingStrategy: A value that determines how to decode a type’s coding keys from JSON keys.
    /// - Returns: A value of the specified type, if the decoder can parse the data.
    private func decodeFromJSON<T: Decodable>(_ type: T.Type, from data: Data,
                                              dateDecodingStrategy: JSONDecoder.DateDecodingStrategy,
                                              keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy) -> Result<T, Error> {
        let result: Result<T, Error>
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = dateDecodingStrategy
            decoder.keyDecodingStrategy = keyDecodingStrategy
            let data = try decoder.decode(type, from: data)
            result = .success(data)
        } catch {
            result = .failure(error)
        }
        return result
    }
    
    internal func decodeError(_ data: Data) -> Result<[String], Error> {
        let resultDecoded = decodeFromJSON(ErrorReponse.self, from: data,
                                           dateDecodingStrategy: resource.options.dateDecodingStrategy,
                                           keyDecodingStrategy: .useDefaultKeys)
        let result: Result<[String], Error>
        switch resultDecoded {
        case .success(let wrapper):
            result = .success(wrapper.error)
        case .failure(let error):
            result = .failure(error)
        }
        return result
    }
    
    internal func decode(_ data: Data) -> Result<Resource.ModelType, Error> {
        let resultDecoded = decodeFromJSON(Wrapper<Resource.ModelType>.self, from: data,
                                           dateDecodingStrategy: resource.options.dateDecodingStrategy,
                                           keyDecodingStrategy: resource.options.keyDecodingStrategy)
        let result: Result<Resource.ModelType, Error>
        switch resultDecoded {
        case .success(let wrapper):
            result = .success(wrapper.data)
        case .failure(let error):
            result = .failure(error)
        }
        return result
    }
    
    public func execute(withCompletion completion: @escaping NetworkRequestCompletion<Resource.ModelType>) {
        _ = load(method: resource.options.method,
                 url: resource.url,
                 parseResponse: resource.options.parseResponse,
                 data: resource.options.httpBody,
                 headers: resource.options.headers,
                 withCompletion: completion)
    }
}
