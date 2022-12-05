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
        case success, error
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
        case .error:
            let errorFields: [String]
            do {
                errorFields = try container.decode(Array<String>.self, forKey: .error_fields)
            } catch {
                errorFields = []
            }
            let errorDescriptions: [String]
            do {
                errorDescriptions = try container.decode(Array<String>.self, forKey: .error)
            } catch {
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

/// `medsenger.ru` error model
//struct ErrorReponse: Decodable {
//    let error: Array<String>
//    let state: String
//
//    enum CodingKeys: CodingKey {
//        case error
//        case state
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        do {
//            self.error = try container.decode([String].self, forKey: .error)
//        } catch {
//            self.error = [try container.decode(String.self, forKey: .error)]
//        }
//        self.state = try container.decode(String.self, forKey: .state)
//    }
//}

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
    
    internal func decode(_ data: Data) -> Result<Wrapper<Resource.ModelType>, Error> {
        let resultDecoded = decodeFromJSON(Wrapper<Resource.ModelType>.self, from: data,
                                           dateDecodingStrategy: resource.options.dateDecodingStrategy,
                                           keyDecodingStrategy: resource.options.keyDecodingStrategy)
        let result: Result<Wrapper<Resource.ModelType>, Error>
        switch resultDecoded {
        case .success(let wrapper):
            result = .success(wrapper)
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
                 withCompletion: { result in
            
        })
    }
}
