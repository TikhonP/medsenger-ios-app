//
//  NetworkRequest.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 24.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

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
    case dataCorrupted(DecodingError.Context)
    case keyNotFound(CodingKey, DecodingError.Context)
    case valueNotFound(Any, DecodingError.Context)
    case typeMismatch(Any, DecodingError.Context)
    case error(Error)
}

typealias DecodedDataReslut<T> = Result<T, DecodeDataError>

typealias NetworkRequestCompletion<T> = (_ result: Result<T?, NetworkRequestError>) -> Void

// MARK: - Network Request

protocol NetworkRequest: AnyObject {
    associatedtype ModelType
    
    func decode(_ data: Data) -> DecodedDataReslut<ModelType>
    func decodeError(_ data: Data) -> DecodedDataReslut<[String]>
    
    func execute(withCompletion completion: @escaping NetworkRequestCompletion<ModelType>)
}

extension NetworkRequest {
    fileprivate func load(_ url: URL, headers: [String: String] = [:], method: HttpMethod = .GET, body: Data? = nil, parseResponse: Bool = false, uploadData: Data? = nil, withCompletion completion: @escaping NetworkRequestCompletion<ModelType>) {
        
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
        
        if let uploadData = uploadData {
            URLSession.shared.uploadTask(with: request, from: uploadData, completionHandler: processResponse)
                .resume()
        } else {
            URLSession.shared.dataTask(with: request, completionHandler: processResponse)
                .resume()
        }
    }
}

// MARK: - APIRequest

class APIRequest<Resource: APIResource> {
    let resource: Resource
    
    init(resource: Resource) {
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
        load(resource.url, headers: resource.options.headers, method: resource.options.httpMethod, body: resource.options.httpBody, parseResponse: resource.options.parseResponse, withCompletion: completion)
    }
}

// MARK: - ImageRequest

class ImageRequest {
    let url: URL
    
    init(path: String) {
        var components = URLComponents(string: Constants.medsengerApiUrl)!
        components.path = components.path + path
        components.queryItems = [
            URLQueryItem(name: "api_token", value: KeyСhain.apiToken),
        ]
        self.url = components.url!
    }
}

extension ImageRequest: NetworkRequest {
    func decodeError(_ data: Data) -> DecodedDataReslut<[String]> { return DecodedDataReslut<[String]>.success([]) }
    
    func decode(_ data: Data) -> DecodedDataReslut<Data> { return DecodedDataReslut<Data>.success(data) }
    
    func execute(withCompletion completion: @escaping NetworkRequestCompletion<Data>) {
        load(url, method: .GET, parseResponse: true, withCompletion: completion)
    }
}

// MARK: - API Resource

enum HttpMethod: String {
    case GET, POST
}

struct APIResourceOptions {
    let dateDecodingStrategy: JSONDecoder.DateDecodingStrategy
    let parseResponse: Bool
    let httpBody: Data?
    let httpMethod: HttpMethod
    let headers: [String: String]
    let queryItems: [URLQueryItem]
    let addApiKey: Bool
    
    init(dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .formatted(DateFormatter.iso8601Full),
         parseResponse: Bool = false,
         httpBody: Data? = nil,
         httpMethod: HttpMethod = .GET,
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
    associatedtype ModelType: Decodable

    var methodPath: String { get }
    var options: APIResourceOptions { get }
}

struct EmptyModel: Decodable {}

extension APIResource {
    static func getPostString(params: [String: Any]) -> String {
        var data = [String]()
        for (key, value) in params {
            data.append(key + "=\(value)")
        }
        return data.map { String($0) }.joined(separator: "&")
    }
    
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

// MARK: - Upload Image Request

class UploadImageRequest<Resource: UploadImageResource> {
    let resource: Resource
    
    init(resource: Resource) {
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
        load(resource.url, headers: resource.options.headers, method: resource.options.httpMethod, uploadData: resource.uploadData, withCompletion: completion)
    }
}

// MARK: - Upload Image Resource

struct UploadImageResourceOptions {
    let dateDecodingStrategy: JSONDecoder.DateDecodingStrategy
    let parseResponse: Bool
    let httpMethod: HttpMethod
    let headers: [String: String]
    let queryItems: [URLQueryItem]
    let addApiKey: Bool
    
    init(dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .formatted(DateFormatter.iso8601Full),
         parseResponse: Bool = false,
         httpBody: Data? = nil,
         httpMethod: HttpMethod = .GET,
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
    associatedtype ModelType: Decodable
    
    var uploadData: Data { get }
    var methodPath: String { get }
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

struct Wrapper<T: Decodable>: Decodable {
    enum status: String, Decodable {
        case success = "success"
        case error = "error"
    }
    
    let state: status
    let data: T
}

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
        print("Request `\(requestName)` failed to get URLError error: \(error.localizedDescription)")
    case .request(let urlError):
        switch urlError.code {
        default:
            print("Request `\(requestName)` error: \(urlError.localizedDescription)")
        }
    case .api(let errorData):
        for error in errorData {
            switch error {
            case "Incorrect token":
                Login.shared.signOut()
                print("Incorrect token in request, sign out.")
            default:
                print("Request `\(requestName)` error: medsenger server message: \(error)")
            }
        }
    case .pageNotFound(let url):
        print("Request `\(requestName)` error: Page not found with url: \(url)")
    case .emptyDataStatusCode(let statusCode):
        print("Request `\(requestName)` error: Invalid status code (\(statusCode)) with empty data")
    case .failedToDeserializeError(let statusCode, let decodeDataError):
        switch decodeDataError {
        case .dataCorrupted(let context):
            print("Request `\(requestName)` error: Failed to deserialize data from error (status code: \(statusCode)): Data corrupted, context: \(context)")
        case .keyNotFound(let key, let context):
            print("Request `\(requestName)` error: Failed to deserialize data from error (status code: \(statusCode)): Key `\(key)` not found, context: \(context)")
        case .valueNotFound(let value, let context):
            print("Request `\(requestName)` error: Failed to deserialize data from error (status code: \(statusCode)): Value `\(value)` not found, context: \(context)")
        case .typeMismatch(let type, let context):
            print("Request `\(requestName)` error: Failed to deserialize data from error (status code: \(statusCode)): Type `\(type)` Mismatch, context: \(context)")
        case .error(let error):
            print("Request `\(requestName)` error: Failed to deserialize data from error (status code: \(statusCode)): Unknown error: \(error.localizedDescription)")
        }
    case .failedToDeserialize(let decodeDataError):
        switch decodeDataError {
        case .dataCorrupted(let context):
            print("Request `\(requestName)` error: Failed to deserialize data: Data corrupted, context: \(context)")
        case .keyNotFound(let key, let context):
            print("Request `\(requestName)` error: Failed to deserialize data: Key `\(key)` not found, context: \(context)")
        case .valueNotFound(let value, let context):
            print("Request `\(requestName)` error: Failed to deserialize data: Value `\(value)` not found, context: \(context)")
        case .typeMismatch(let type, let context):
            print("Request `\(requestName)` error: Failed to deserialize data: Type `\(type)` Mismatch, context: \(context)")
        case .error(let error):
            print("Request `\(requestName)` error: Failed to deserialize data: Unknown error: \(error.localizedDescription)")
        }
    case .failedToGetResponse:
        print("Request `\(requestName)` error: Failed to get status code")
    case .selfIsNil:
        print("Request `\(requestName)` error: `self` is `nil`")
    }
}
