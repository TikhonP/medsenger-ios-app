//
//  NetworkRequest.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 24.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

enum HTTPMethod: String {
    case GET, POST
}

enum DecodeError: Error {
    
    /// Failed to deserialize data with JSON
    /// - Parameters:
    ///  - decodeDataError: decode JSON from data failure cases
    case json(_ decodeDataError: DecodingError)
    
    /// Error from medsenger server
    /// - Parameters:
    ///  - errors: Errors response type
    case api(_ errors: ErrorResponse)
}

// MARK: - Network Request

/// The basic protocol for network requests
///
/// It can be used for creating new protocols and apies for specific network requests usage
protocol NetworkRequest: AnyObject {
    associatedtype ResponseModelType: Decodable
    
    /// Decode response data to specific type.
    /// Throws ``DecodeError``.
    /// - Parameter data: The response data.
    /// - Returns: Decoded response.
    func decode(_ data: Data) throws -> ResponseModelType
    
    /// Perform url session request
    func execute() async throws
    
    /// Perform url session request with decoding data result. 
    /// - Returns: Decoded response
    func executeWithResult() async throws -> ResponseModelType
}

extension NetworkRequest {
    
    /// Perform `URLSession` request.
    ///
    /// Throws ``NetworkRequestError``
    /// - Parameter request: A URL request object that provides request-specific information such as the URL, cache policy, request type, and body data or body stream.
    internal func load(for request: URLRequest) async throws {
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkRequestError.failedToGetResponse
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            do {
                _ = try self.decode(data)
            } catch DecodeError.json(let error) {
                throw NetworkRequestError.failedToDeserialize(httpResponse.statusCode, error)
            } catch DecodeError.api(let error) {
                throw NetworkRequestError.api(error, httpResponse.statusCode)
            }
        }
    }
    
    /// Perform `URLSession` request with decoding data
    /// - Parameter request: A URL request object that provides request-specific information such as the URL, cache policy, request type, and body data or body stream.
    /// - Returns: Decoded response
    internal func loadWithResult(for request: URLRequest) async throws -> ResponseModelType {
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkRequestError.failedToGetResponse
            }
            
            do {
                return try self.decode(data)
            } catch DecodeError.json(let error) {
                throw NetworkRequestError.failedToDeserialize(httpResponse.statusCode, error)
            } catch DecodeError.api(let error) {
                throw NetworkRequestError.api(error, httpResponse.statusCode)
            }
        } catch let error as URLError {
            throw NetworkRequestError.request(error)
        }
    }
    
    /// Create a URL load request that is independent of protocol or URL scheme.
    /// - Parameters:
    ///   - method: The HTTP request method.
    ///   - url: The URL for the request.
    ///   - data: The data sent as the message body of a request, such as for an HTTP POST request.
    ///   - headers: The  header fields.
    ///   - timeoutInterval: The request’s timeout interval, in seconds.
    /// - Returns: The URLRequest.
    internal func createURLRequest(method: HTTPMethod,
                                   url: URL,
                                   data: Data? = nil,
                                   headers: [String: String] = [:],
                                   timeoutInterval: TimeInterval = 60.0) -> URLRequest {
        var request = URLRequest(url: url, timeoutInterval: timeoutInterval)
        request.httpMethod = method.rawValue
        request.httpBody = data
        for header in headers {
            request.setValue(header.value, forHTTPHeaderField: header.key)
        }
        return request
    }
}
