//
//  APIResource.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 02.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import os.log

/// Empty model
///
/// Use as placeholder for ``APIResource`` without handling response data
struct EmptyModel: Decodable {}

struct APIResourceError<T: Error> {
    let errorString: String
    let error: T
}

protocol APIResource: Sendable {
    
    /// Decodable model type for response JSON decoding
    associatedtype ModelType: Decodable, Sendable
    
    /// Path of the resource without query items and base host
    var methodPath: String { get }
    
    /// Api resource data
    var options: APIResourceOptions { get }
    
    var apiErrors: [APIResourceError<Error>] { get }
}

extension APIResource {
    
    /// Computed final url
    internal var url: URL {
        var components = URLComponents(string: Constants.medsengerApiUrl)!
        components.path = components.path + methodPath
        var queryItems = options.params
        if options.addApiKey {
            queryItems.append(URLQueryItem(name: "api_token", value: KeyChain.apiToken))
        }
        components.queryItems = queryItems
        return components.url!
    }
    
    /// Generate ``MultipartFormData``
    /// - Parameters:
    ///   - textParams: Parameters with string key and string value
    ///   - files: ``MultipartFormData.Part`` objects with files
    /// - Returns: MultipartFormData object
    private func getMultipartFormData(textParams: [String: String], files: [MultipartFormData.Part]) -> MultipartFormData {
        var data = [MultipartFormData.Part]()
        
        for (key, value) in textParams {
            data.append(
                MultipartFormData.Part(
                    contentDisposition: ContentDisposition(
                        name: Name(asPercentEncoded: key),
                        filename: nil
                    ),
                    contentType: nil,
                    content: value.data(using: .utf8)!
                )
            )
        }
        
        data.append(contentsOf: files)
        
        let multipartFormData = MultipartFormData(
            uniqueAndValidLengthBoundary: RandomBoundaryGenerator.generate(),
            body: data
        )
        
        return multipartFormData
    }

    /// Get httpBody and header as multipartFormData from string params
    /// - Parameters:
    ///   - textParams: Parameters with string key and string value
    ///   - files: `MultipartFormData.Part` objects with files
    /// - Returns: Tuple with httpBody and headers
    public func multipartFormData(textParams: [String: String] = [:], files: [MultipartFormData.Part] = []) -> (httpBody: Data?, headers: [String: String]) {
        let multipartFormData = getMultipartFormData(textParams: textParams, files: files)
        let httpBody: Data? = {
            switch multipartFormData.asData() {
            case let .valid(data):
                return data
            case let .invalid(error):
                Logger.urlRequest.fault("APIResource: Serilize `send message` form data error: \(error.localizedDescription)")
                return nil
            }
        }()
        let headers = [multipartFormData.header.name: multipartFormData.header.value]
        return (httpBody, headers)
    }
    
    /// Returns a JSON-encoded representation of the value you supply.
    /// - Parameters:
    ///   - value: The value to encode as JSON.
    ///   - dateEncodingStrategy: The strategy that an encoder uses to encode raw data.
    ///   - keyEncodingStrategy: A value that determines how to encode a type’s coding keys as JSON keys.
    /// - Returns: The encoded JSON data.
    public func encodeToJSON<T: Encodable>(_ value: T,
                                           dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .secondsSince1970,
                                           keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy = .useDefaultKeys) -> Data? {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = dateEncodingStrategy
            encoder.keyEncodingStrategy = keyEncodingStrategy
            let data = try encoder.encode(value)
            return data
        } catch {
            Logger.urlRequest.error("APIResource: encodeToJSON error: \(error.localizedDescription)")
            return nil
        }
    }
}


struct APIResourceOptions {
    let dateDecodingStrategy: JSONDecoder.DateDecodingStrategy
    let keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy
    let parseResponse: Bool
    let httpBody: Data?
    let method: HTTPMethod
    let headers: [String: String]
    let params: [URLQueryItem]
    let addApiKey: Bool
    
    /// Create options for ``APIResource``
    /// - Parameters:
    ///   - parseResponse: Parse or not response with `NetworkRequest.decode()`. If `false` result data wiil be `nil`
    ///   - method: The HTTP request method. Default is `HttpMethod.GET`
    ///   - params: An array of query items for the URL in the order in which they appear in the original query string.
    ///   - httpBody: The data sent as the message body of a request, such as for an HTTP POST request.
    ///   - headers: Header fields
    ///   - dateDecodingStrategy: The strategy used when decoding dates from part of a JSON object.
    ///   - keyDecodingStrategy: A value that determines how to decode a type’s coding keys from JSON keys.
    ///   - addApiKey: Append medsenger ApiKey from keychain as query item
    init(parseResponse: Bool = false,
         method: HTTPMethod = .GET,
         params: [URLQueryItem] = [],
         httpBody: Data? = nil,
         headers: [String: String] = [:],
         dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .formatted(DateFormatter.iso8601Full),
         keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
         addApiKey: Bool = true) {
        self.dateDecodingStrategy = dateDecodingStrategy
        self.keyDecodingStrategy = keyDecodingStrategy
        self.parseResponse = parseResponse
        self.httpBody = httpBody
        self.method = method
        self.headers = headers
        self.params = params
        self.addApiKey = addApiKey
    }
}
