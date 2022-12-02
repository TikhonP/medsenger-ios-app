//
//  NetworkRequest.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 24.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

/// Completion for HTTP request
/// - Parameter result: request result with decoded data type and error
typealias NetworkRequestCompletion<T> = (_ result: Result<T?, NetworkRequestError>) -> Void

enum HTTPMethod: String {
    case GET, POST
}

// MARK: - Network Request

/// The basic protocol for network requests
///
/// It can be used for creating new protocols and apies for specific network requests usage
protocol NetworkRequest: AnyObject {
    associatedtype ModelType
    
    /// Decode http success result data to specific swift type
    /// - Parameter data: response data
    /// - Returns: swift object that will be returned on request success
    func decode(_ data: Data) -> Result<ModelType, Error>
    
    /// Decode http request data on non 2xx status codes
    /// - Parameter data: Response data
    /// - Returns: List of errors strings
    func decodeError(_ data: Data) -> Result<[String], Error>
    
    /// Perform url session request and return request result
    /// - Parameter completion: Request completion
    func execute(withCompletion completion: @escaping NetworkRequestCompletion<ModelType>)
}

extension NetworkRequest {

    /// Perform URLSession request with parameters
    /// - Parameters:
    ///   - method: The HTTP request method.
    ///   - url: The URL for the request.
    ///   - parseResponse: Parse or not response with ``NetworkRequest.decode()``. If `false` result data wiil be `nil`
    ///   - data: The data sent as the message body of a request, such as for an HTTP POST request.
    ///   - headers: The  header fields.
    ///   - timeoutInterval: The request’s timeout interval, in seconds.
    ///   - completion: Request completion
    /// - Returns: The session task.
    func load(method: HTTPMethod,
              url: URL,
              parseResponse: Bool,
              data: Data? = nil,
              headers: [String: String] = [:],
              timeoutInterval: TimeInterval = 60.0,
              withCompletion completion: @escaping NetworkRequestCompletion<ModelType>) -> URLSessionTask {
        
        var request = URLRequest(url: url, timeoutInterval: timeoutInterval)
        request.httpMethod = method.rawValue
        request.httpBody = data
        for header in headers {
            request.setValue(header.value, forHTTPHeaderField: header.key)
        }
        
        let processResponse: (Data?, URLResponse?, Error?) -> Void = { [weak self] (data, response, error) -> Void in
            if let error = error {
                guard let urlError = error as? URLError else {
                    completion(.failure(.failedToGetUrlError(error)))
                    return
                }
                completion(.failure(.request(urlError)))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.failedToGetResponse))
                return
            }
            guard let self = self else {
                completion(.failure(.selfIsNil))
                return
            }
            guard (200...299).contains(httpResponse.statusCode) else {
                if httpResponse.statusCode == 404 {
                    completion(.failure(.pageNotFound(url)))
                    return
                }
                guard let data = data else {
                    completion(.failure(.emptyDataStatusCode(httpResponse.statusCode)))
                    return
                }
                let decodedDataReslut = self.decodeError(data)
                switch decodedDataReslut {
                case .success(let result):
                    completion(.failure(.api(result)))
                    return
                case .failure(let error):
                    completion(.failure(.failedToDeserializeError(httpResponse.statusCode, error)))
                    return
                }
            }
            if parseResponse {
                guard let data = data else {
                    completion(.failure(.emptyDataStatusCode(httpResponse.statusCode)))
                    return
                }
                let decodedDataReslut = self.decode(data)
                switch decodedDataReslut {
                case .success(let result):
                    completion(.success(result))
                    return
                case .failure(let error):
                    let decodedDataReslut = self.decodeError(data)
                    switch decodedDataReslut {
                    case .success(let result):
                        completion(.failure(.api(result)))
                        return
                    case .failure(_):
                        completion(.failure(.failedToDeserialize(error)))
                        return
                    }
                }
            } else {
                completion(.success(nil))
                return
            }
        }
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: processResponse)
        task.resume()
        return task
    }
}
