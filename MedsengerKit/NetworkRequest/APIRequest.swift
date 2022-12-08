//
//  APIRequest.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 02.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

enum Wrapper<T: Decodable> {
    case success(T)
    case error(ErrorResponse)
}

/// `medsenger.ru` response base model
extension Wrapper: Decodable {
    enum status: String, Decodable {
        case success, error, failed
    }
    
    enum CodingKeys: CodingKey {
        case state
        case data
        case error
        case error_fields
    }
    
    init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<Wrapper<T>.CodingKeys> = try decoder.container(keyedBy: Wrapper<T>.CodingKeys.self)
        let state = try container.decode(Wrapper<T>.status.self, forKey: Wrapper<T>.CodingKeys.state)
        
        switch state {
        case .success:
            self = .success(try container.decode(T.self, forKey: .data))
        case .error, .failed:
            let errorFields: [String]
            do {
                errorFields = try container.decode(Array<String>.self, forKey: .error_fields)
            } catch is DecodingError {
                errorFields = []
            }
            let errorDescriptions: [String]
            do {
                errorDescriptions = try container.decode(Array<String>.self, forKey: .error)
            } catch is DecodingError {
                errorDescriptions = [try container.decode(String.self, forKey: .error)]
            }
            self = .error(ErrorResponse(errors: errorDescriptions, errorFields: errorFields))
        }
    }
}

struct ErrorResponse: CustomStringConvertible {
    let errors: Array<String>
    let errorFields: Array<String>
    
    var description: String {
        "Server errors: \(errors) with errorFields: \(errorFields)"
    }
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
    
    internal func decode(_ data: Data) -> Result<Resource.ModelType, DecodeError> {
        let result: Result<Resource.ModelType, DecodeError>
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = resource.options.dateDecodingStrategy
            decoder.keyDecodingStrategy = resource.options.keyDecodingStrategy
            let wrapper = try decoder.decode(Wrapper<Resource.ModelType>.self, from: data)
            switch wrapper {
            case .success(let data):
                result = .success(data)
            case .error(let errorResponse):
                result = .failure(.api(errorResponse))
            }
        } catch {
            result = .failure(.json(error))
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
