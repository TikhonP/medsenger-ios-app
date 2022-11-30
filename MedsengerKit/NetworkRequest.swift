//
//  NetworkRequest.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 24.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import os.log

// MARK: Network Request

/// Network request failure cases
enum NetworkRequestError: Error {
    
    /// Error with `URLSession` request
    /// - Parameter error: Error codes returned by URL loading APIs
    case request(_ error: URLError)
    
    /// Failed to get `URLSession` error as `URLError`
    /// - Parameter error: error
    case failedToGetUrlError(_ error: Error)
    
    /// Error from medsenger server
    /// - Parameter errors: Errors as string got from medsenger server
    case api(_ errors: [String])
    
    /// 404 error from medsenger server
    /// - Parameter url: requested url
    case pageNotFound(_ url: URL)
    
    /// Empty data with HTTP error
    /// - Parameter statusCode: HTTP status code
    case emptyDataStatusCode(_ statusCode: Int)
    
    /// Failed to deserialize data with JSON, when got HTTP error
    /// - Parameters:
    ///  - statusCode: HTTP status code
    ///  - decodeDataError: decode JSON from data failure cases
    case failedToDeserializeError(_ statusCode: Int, _ decodeDataError: DecodeDataError)
    
    /// Failed to deserialize data with JSON
    /// - Parameters:
    ///  - decodeDataError: decode JSON from data failure cases
    case failedToDeserialize(_ decodeDataError: DecodeDataError)
    
    /// Failed to get `URLSession` response as `HTTPURLResponse`
    case failedToGetResponse
    
    /// Weak `self` is nil
    case selfIsNil
}

/// Decode JSON from data failure cases
enum DecodeDataError: Error {
    
    /// Data corrupted error
    ///  - Parameter context: DecodingError context
    case dataCorrupted(_ context: DecodingError.Context)
    
    ///  Key not found in JSON string
    ///  - Parameters:
    ///   - key: missing key
    ///   - context: DecodingError context
    case keyNotFound(_ key: CodingKey, _ context: DecodingError.Context)
    
    /// Value Not Found in JSON string
    /// - Parameters:
    ///  - value: missing value
    ///  - context: DecodingError context
    case valueNotFound(_ value: Any, _ context: DecodingError.Context)
    
    /// Type Mismatch in JSON string
    /// - Parameters:
    ///  - type: mismatch type
    ///  - context: DecodingError context
    case typeMismatch(_ type: Any.Type, _ context: DecodingError.Context)
    
    /// Other Decoding Errors
    /// - Parameter error: `DecodingError` error
    case error(_ error: Error)
}

/// Result of decoding JSON string
typealias DecodedDataReslut<T> = Result<T, DecodeDataError>

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
    func decode(_ data: Data) -> DecodedDataReslut<ModelType>
    
    /// Decode http request data on non 2xx status codes
    /// - Parameter data: Response data
    /// - Returns: List of errors strings
    func decodeError(_ data: Data) -> DecodedDataReslut<[String]>
    
    /// Perform url session request and return request result
    /// - Parameter completion: Request completion
    func execute(withCompletion completion: @escaping NetworkRequestCompletion<ModelType>)
}

extension NetworkRequest {
    
    /// Perform URLSession request with parameters
    /// - Parameters:
    ///   - url: The URL for the request.
    ///   - headers: Header fields
    ///   - method: The HTTP request method. Default is ``HttpMethod.GET``
    ///   - body: The data sent as the message body of a request, such as for an HTTP POST request.
    ///   - parseResponse: Parse or not response with ``NetworkRequest.decode()``. If `false` result data wiil be `nil`
    ///   - uploadData: The body data for the request upload data request
    ///   - completion: Request completion
    /// - Returns: The session task.
    fileprivate func load(_ url: URL, headers: [String: String] = [:], method: HTTPMethod = .GET, body: Data? = nil, parseResponse: Bool = false, uploadData: Data? = nil, withCompletion completion: @escaping NetworkRequestCompletion<ModelType>) -> URLSessionTask {
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        for header in headers {
            request.setValue(header.value, forHTTPHeaderField: header.key)
        }
        if let body = body {
            request.httpBody = body
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
        
        let task: URLSessionTask
        if let uploadData = uploadData {
            task = URLSession.shared.uploadTask(with: request, from: uploadData, completionHandler: processResponse)
        } else {
            task = URLSession.shared.dataTask(with: request, completionHandler: processResponse)
        }
        task.resume()
        return task
    }
}

// MARK: - APIRequest

/// The HTTP API request to `medsenger.ru` with JSON data
class APIRequest<Resource: APIResource> {
    
    /// API resource: data for specific request
    let resource: Resource
    
    /// Create object
    /// - Parameter resource: data for specific request
    init(_ resource: Resource) {
        self.resource = resource
    }
}

extension APIRequest: NetworkRequest {
    func decodeError(_ data: Data) -> DecodedDataReslut<[String]> {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = resource.options.dateDecodingStrategy
            let errorResponse = try decoder.decode(ErrorReponse.self, from: data)
            return DecodedDataReslut<[String]>.success(errorResponse.error)
        } catch DecodingError.dataCorrupted(let context) {
            return DecodedDataReslut<[String]>.failure(.dataCorrupted(context))
        } catch DecodingError.keyNotFound(let key, let context) {
            return DecodedDataReslut<[String]>.failure(.keyNotFound(key, context))
        } catch DecodingError.valueNotFound(let value, let context) {
            return DecodedDataReslut<[String]>.failure(.valueNotFound(value, context))
        } catch DecodingError.typeMismatch(let type, let context) {
            return DecodedDataReslut<[String]>.failure(.typeMismatch(type, context))
        } catch {
            return DecodedDataReslut<[String]>.failure(.error(error))
        }
    }
    
    func decode(_ data: Data) -> DecodedDataReslut<Resource.ModelType> {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = resource.options.dateDecodingStrategy
            let wrapper = try decoder.decode(Wrapper<Resource.ModelType>.self, from: data)
            return DecodedDataReslut<Resource.ModelType>.success(wrapper.data)
        } catch DecodingError.dataCorrupted(let context) {
            return DecodedDataReslut<Resource.ModelType>.failure(.dataCorrupted(context))
        } catch DecodingError.keyNotFound(let key, let context) {
            return DecodedDataReslut<Resource.ModelType>.failure(.keyNotFound(key, context))
        } catch DecodingError.valueNotFound(let value, let context) {
            return DecodedDataReslut<Resource.ModelType>.failure(.valueNotFound(value, context))
        } catch DecodingError.typeMismatch(let type, let context) {
            return DecodedDataReslut<Resource.ModelType>.failure(.typeMismatch(type, context))
        } catch {
            return DecodedDataReslut<Resource.ModelType>.failure(.error(error))
        }
    }
    
    func execute(withCompletion completion: @escaping NetworkRequestCompletion<Resource.ModelType>) {
        _ = load(resource.url, headers: resource.options.headers, method: resource.options.httpMethod, body: resource.options.httpBody, parseResponse: resource.options.parseResponse, withCompletion: completion)
    }
}

// MARK: - API Resource

struct APIResourceOptions {
    let dateDecodingStrategy: JSONDecoder.DateDecodingStrategy
    let parseResponse: Bool
    let httpBody: Data?
    let httpMethod: HTTPMethod
    let headers: [String: String]
    let queryItems: [URLQueryItem]
    let addApiKey: Bool
    
    /// Initilize options for ``APIResource``
    /// - Parameters:
    ///   - dateDecodingStrategy: The strategy used when decoding dates from part of a JSON object.
    ///   - parseResponse: Parse or not response with ``NetworkRequest.decode()``. If `false` result data wiil be `nil`
    ///   - httpBody: The data sent as the message body of a request, such as for an HTTP POST request.
    ///   - httpMethod: The HTTP request method. Default is ``HttpMethod.GET``
    ///   - headers: Header fields
    ///   - queryItems: An array of query items for the URL in the order in which they appear in the original query string.
    ///   - addApiKey: Append medsenger ApiKey from keychain as query item
    init(dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .formatted(DateFormatter.iso8601Full),
         parseResponse: Bool = false,
         httpBody: Data? = nil,
         httpMethod: HTTPMethod = .GET,
         headers: [String: String] = [:],
         queryItems: [URLQueryItem] = [],
         addApiKey: Bool = true
    ) {
        self.dateDecodingStrategy = dateDecodingStrategy
        self.parseResponse = parseResponse
        self.httpBody = httpBody
        self.httpMethod = httpMethod
        self.headers = headers
        self.queryItems = queryItems
        self.addApiKey = addApiKey
    }
}

protocol APIResource {
    
    /// Decodable model type for response JSON decoding
    associatedtype ModelType: Decodable
    
    /// Path of the resource without query items and base host
    var methodPath: String { get }
    
    /// Api resource data
    var options: APIResourceOptions { get }
}

/// Empty model
///
/// Use as placeholder for ``APIResource`` without handling response data
struct EmptyModel: Decodable {}

extension APIResource {
    
    /// Generate ``MultipartFormData`` from string params
    /// - Parameter params: Parameters with string key and string value
    /// - Returns: MultipartFormData object
    private func getMultipartFormData(params: [String: String]) -> MultipartFormData {
        var data = [MultipartFormData.Part]()
        
        for (key, value) in params {
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

        let multipartFormData = MultipartFormData(
            uniqueAndValidLengthBoundary: "boundary",
            body: data
        )
        
        return multipartFormData
    }
    
    /// Get httpBody and header as multipartFormData from string params
    /// - Parameter params: Parameters with string key and string value
    /// - Returns: Tuple with httpBody and headers
    func multipartFormData(params: [String: String]) -> (httpBody: Data?, headers: [String: String]) {
        let multipartFormData  = getMultipartFormData(params: params)
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
    
    /// Computed final url
    var url: URL {
        var components = URLComponents(string: Constants.medsengerApiUrl)!
        components.path = components.path + methodPath
        var queryItems = options.queryItems
        if options.addApiKey {
            queryItems.append(URLQueryItem(name: "api_token", value: KeyСhain.apiToken))
        }
        components.queryItems = queryItems
        return components.url!
    }
}

// MARK: - FileRequest

/// Load file from `medsenger.ru` request
class FileRequest {
    let url: URL
    
    /// Create object
    /// - Parameters:
    ///   - path: Path of the resource without query items and base host
    ///   - addApiKey: Append medsenger ApiKey from keychain as query item
    init(path: String, addApiKey: Bool = true) {
        var components = URLComponents(string: Constants.medsengerApiUrl)!
        components.path = components.path + path
        if addApiKey {
            components.queryItems = [
                URLQueryItem(name: "api_token", value: KeyСhain.apiToken),
            ]
        }
        self.url = components.url!
    }
}

extension FileRequest: NetworkRequest {
    func decodeError(_ data: Data) -> DecodedDataReslut<[String]> { return DecodedDataReslut<[String]>.success([]) }
    
    func decode(_ data: Data) -> DecodedDataReslut<Data> { return DecodedDataReslut<Data>.success(data) }
    
    func execute(withCompletion completion: @escaping NetworkRequestCompletion<Data>) {
        _ = load(url, method: .GET, parseResponse: true, withCompletion: completion)
    }
}

// MARK: - Upload Image Request

/// Upload image to `medsenger.ru`
class UploadImageRequest<Resource: UploadImageResource> {
    let resource: Resource
    
    /// Create object
    /// - Parameter resource: data for specific request
    init(_ resource: Resource) {
        self.resource = resource
    }
}

extension UploadImageRequest: NetworkRequest {
    func decodeError(_ data: Data) -> DecodedDataReslut<[String]> {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = resource.options.dateDecodingStrategy
            let errorResponse = try decoder.decode(ErrorReponse.self, from: data)
            return DecodedDataReslut<[String]>.success(errorResponse.error)
        } catch DecodingError.dataCorrupted(let context) {
            return DecodedDataReslut<[String]>.failure(.dataCorrupted(context))
        } catch DecodingError.keyNotFound(let key, let context) {
            return DecodedDataReslut<[String]>.failure(.keyNotFound(key, context))
        } catch DecodingError.valueNotFound(let value, let context) {
            return DecodedDataReslut<[String]>.failure(.valueNotFound(value, context))
        } catch DecodingError.typeMismatch(let type, let context) {
            return DecodedDataReslut<[String]>.failure(.typeMismatch(type, context))
        } catch {
            return DecodedDataReslut<[String]>.failure(.error(error))
        }
    }
    
    func decode(_ data: Data) -> DecodedDataReslut<Resource.ModelType> {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = resource.options.dateDecodingStrategy
            let wrapper = try decoder.decode(Wrapper<Resource.ModelType>.self, from: data)
            return DecodedDataReslut<Resource.ModelType>.success(wrapper.data)
        } catch DecodingError.dataCorrupted(let context) {
            return DecodedDataReslut<Resource.ModelType>.failure(.dataCorrupted(context))
        } catch DecodingError.keyNotFound(let key, let context) {
            return DecodedDataReslut<Resource.ModelType>.failure(.keyNotFound(key, context))
        } catch DecodingError.valueNotFound(let value, let context) {
            return DecodedDataReslut<Resource.ModelType>.failure(.valueNotFound(value, context))
        } catch DecodingError.typeMismatch(let type, let context) {
            return DecodedDataReslut<Resource.ModelType>.failure(.typeMismatch(type, context))
        } catch {
            return DecodedDataReslut<Resource.ModelType>.failure(.error(error))
        }
    }
    
    func execute(withCompletion completion: @escaping NetworkRequestCompletion<Resource.ModelType>) {
        _ = load(resource.url, headers: resource.options.headers, method: resource.options.httpMethod, uploadData: resource.uploadData, withCompletion: completion)
    }
}

// MARK: - Upload Image Resource

struct UploadImageResourceOptions {
    let dateDecodingStrategy: JSONDecoder.DateDecodingStrategy
    let parseResponse: Bool
    let httpMethod: HTTPMethod
    let headers: [String: String]
    let queryItems: [URLQueryItem]
    let addApiKey: Bool
    
    /// Initilize options for ``UploadImageResource``
    /// - Parameters:
    ///   - dateDecodingStrategy: The strategy used when decoding dates from part of a JSON object.
    ///   - parseResponse: Parse or not response with ``NetworkRequest.decode()``. If `false` result data wiil be `nil`
    ///   - httpBody: The data sent as the message body of a request, such as for an HTTP POST request.
    ///   - httpMethod: The HTTP request method. Default is ``HttpMethod.GET``
    ///   - headers: Header fields
    ///   - queryItems: An array of query items for the URL in the order in which they appear in the original query string.
    ///   - addApiKey: Append medsenger ApiKey from keychain as query item
    init(dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .formatted(DateFormatter.iso8601Full),
         parseResponse: Bool = false,
         httpBody: Data? = nil,
         httpMethod: HTTPMethod = .GET,
         headers: [String: String] = [:],
         queryItems: [URLQueryItem] = [],
         addApiKey: Bool = true
    ) {
        self.dateDecodingStrategy = dateDecodingStrategy
        self.parseResponse = parseResponse
        self.httpMethod = httpMethod
        self.headers = headers
        self.queryItems = queryItems
        self.addApiKey = addApiKey
    }
}

protocol UploadImageResource {
    
    /// Decodable model type for response JSON decoding
    associatedtype ModelType: Decodable
    
    /// Data object to upload
    var uploadData: Data { get }
    
    /// Path of the resource without query items and base host
    var methodPath: String { get }
    
    /// Upload image resource data
    var options: UploadImageResourceOptions { get }
}

extension UploadImageResource {
    var url: URL {
        var components = URLComponents(string: Constants.medsengerApiUrl)!
        components.path = components.path + methodPath
        var queryItems = options.queryItems
        if options.addApiKey {
            queryItems.append(URLQueryItem(name: "api_token", value: KeyСhain.apiToken))
        }
        components.queryItems = queryItems
        return components.url!
    }
}

// MARK: - Wrapper

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

/// Process HTTP requests errors
/// - Parameters:
///   - requestError: error from request result
///   - requestName: name of request for logging
func processRequestError(_ requestError: NetworkRequestError, _ requestName: String) {
    switch requestError {
    case .failedToGetUrlError(let error):
        Logger.urlRequest.error("Request `\(requestName)` failed to get URLError error: \(error.localizedDescription)")
    case .request(let urlError):
        switch urlError.code {
        default:
            Logger.urlRequest.error("Request `\(requestName)` error: \(urlError.localizedDescription)")
        }
    case .api(let errorData):
        for error in errorData {
            switch error {
            case "Incorrect token":
                Login.shared.signOut()
                Logger.urlRequest.info("Incorrect token in request, sign out.")
            default:
                Logger.urlRequest.error("Request `\(requestName)` error: medsenger server message: \(error)")
            }
        }
    case .pageNotFound(let url):
        Logger.urlRequest.error("Request `\(requestName)` error: Page not found with url: \(url)")
    case .emptyDataStatusCode(let statusCode):
        Logger.urlRequest.error("Request `\(requestName)` error: Invalid status code (\(statusCode)) with empty data")
    case .failedToDeserializeError(let statusCode, let decodeDataError):
        switch decodeDataError {
        case .dataCorrupted(let context):
            Logger.urlRequest.error("Request `\(requestName)` error: Failed to deserialize data from error (status code: \(statusCode)): Data corrupted, context: \(String(describing: context))")
        case .keyNotFound(let key, let context):
            Logger.urlRequest.error("Request `\(requestName)` error: Failed to deserialize data from error (status code: \(statusCode)): Key `\(String(describing: key))` not found, context: \(String(describing: context))")
        case .valueNotFound(let value, let context):
            Logger.urlRequest.error("Request `\(requestName)` error: Failed to deserialize data from error (status code: \(statusCode)): Value `\(String(describing: value))` not found, context: \(String(describing: context))")
        case .typeMismatch(let type, let context):
            Logger.urlRequest.error("Request `\(requestName)` error: Failed to deserialize data from error (status code: \(statusCode)): Type `\(String(describing: type))` Mismatch, context: \(String(describing: context))")
        case .error(let error):
            Logger.urlRequest.error("Request `\(requestName)` error: Failed to deserialize data from error (status code: \(statusCode)): Unknown error: \(error.localizedDescription)")
        }
    case .failedToDeserialize(let decodeDataError):
        switch decodeDataError {
        case .dataCorrupted(let context):
            Logger.urlRequest.error("Request `\(requestName)` error: Failed to deserialize data: Data corrupted, context: \(String(describing: context))")
        case .keyNotFound(let key, let context):
            Logger.urlRequest.error("Request `\(requestName)` error: Failed to deserialize data: Key `\(String(describing: key))` not found, context: \(String(describing: context))")
        case .valueNotFound(let value, let context):
            Logger.urlRequest.error("Request `\(requestName)` error: Failed to deserialize data: Value `\(String(describing: value))` not found, context: \(String(describing: context))")
        case .typeMismatch(let type, let context):
            Logger.urlRequest.error("Request `\(requestName)` error: Failed to deserialize data: Type `\(String(describing: type))` Mismatch, context: \(String(describing: context))")
        case .error(let error):
            Logger.urlRequest.error("Request `\(requestName)` error: Failed to deserialize data: Unknown error: \(error.localizedDescription)")
        }
    case .failedToGetResponse:
        Logger.urlRequest.error("Request `\(requestName)` error: Failed to get status code")
    case .selfIsNil:
        Logger.urlRequest.error("Request `\(requestName)` error: `self` is `nil`")
    }
}
