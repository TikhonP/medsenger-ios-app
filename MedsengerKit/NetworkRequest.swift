//
//  NetworkRequest.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 24.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

// MARK: - Network Request Results

enum NetworkRequestError {
    case Request(Error)
    case Api([String])
    case PageNotFound(String) // URL
    case EmptyDataStatusCode(Int)
    case FailedToDeserializeError(DecodedDataError)
    case FailedToDeserialize(DecodedDataError)
    case failedToGetStatusCode
    case selfIsNil
}

enum NetworkRequestResult<T> {
    case success
    case SuccessData(T)
    case Error(NetworkRequestError)
}

enum DecodedDataError {
    case DataCorrupted(DecodingError.Context)
    case KeyNotFound(CodingKey, DecodingError.Context)
    case ValueNotFound(Any, DecodingError.Context)
    case TypeMismatch(Any, DecodingError.Context)
    case Error(Error)
}

enum DecodedDataReslut<T> {
    case Success(T)
    case Error(DecodedDataError)
}

// MARK: - Network Request

protocol NetworkRequest: AnyObject {
    associatedtype ModelType
    
    func decode(_ data: Data) -> DecodedDataReslut<ModelType>
    func decodeError(_ data: Data) -> DecodedDataReslut<[String]>
    
    func execute(withCompletion completion: @escaping (NetworkRequestResult<ModelType>) -> Void)
}

extension NetworkRequest {
    fileprivate func load(_ url: URL, headers: [String: String] = [:], method: String = "GET", body: Data? = nil, parseResponse: Bool = false, uploadData: Data? = nil, withCompletion completion: @escaping (NetworkRequestResult<ModelType>) -> Void) {
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        for header in headers {
            request.setValue(header.value, forHTTPHeaderField: header.key)
        }
        if let body = body {
            request.httpBody = body
        }
        
        let processResponse: (Data?, URLResponse?, Error?) -> Void = { [weak self] (data, response, error) -> Void in
            if let error = error {
                completion(.Error(.Request(error)))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.Error(.failedToGetStatusCode))
                return
            }
            guard let self = self else {
                completion(.Error(.selfIsNil))
                return
            }
            guard (200...299).contains(httpResponse.statusCode) else {
                if httpResponse.statusCode == 404 {
                    completion(.Error(.PageNotFound(url.formatted())))
                    return
                }
                guard let data = data else {
                    completion(.Error(.EmptyDataStatusCode(httpResponse.statusCode)))
                    return
                }
                let decodedDataReslut = self.decodeError(data)
                switch decodedDataReslut {
                case .Success(let result):
                    completion(.Error(.Api(result)))
                    return
                case .Error(let error):
                    completion(.Error(.FailedToDeserializeError(error)))
                    return
                }
            }
            if parseResponse {
                guard let data = data else {
                    completion(.Error(.EmptyDataStatusCode(httpResponse.statusCode)))
                    return
                }
                let decodedDataReslut = self.decode(data)
                switch decodedDataReslut {
                case .Success(let result):
                    completion(.SuccessData(result))
                    return
                case .Error(let error):
                    completion(.Error(.FailedToDeserialize(error)))
                    return
                }
            } else {
                completion(.success)
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
            return DecodedDataReslut<[String]>.Success(errorResponse.error)
        } catch DecodingError.dataCorrupted(let context) {
            return DecodedDataReslut<[String]>.Error(.DataCorrupted(context))
        } catch DecodingError.keyNotFound(let key, let context) {
            return DecodedDataReslut<[String]>.Error(.KeyNotFound(key, context))
        } catch DecodingError.valueNotFound(let value, let context) {
            return DecodedDataReslut<[String]>.Error(.ValueNotFound(value, context))
        } catch DecodingError.typeMismatch(let type, let context) {
            return DecodedDataReslut<[String]>.Error(.TypeMismatch(type, context))
        } catch {
            return DecodedDataReslut<[String]>.Error(.Error(error))
        }
    }
    
    func decode(_ data: Data) -> DecodedDataReslut<Resource.ModelType> {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = resource.options.dateDecodingStrategy
            let wrapper = try decoder.decode(Wrapper<Resource.ModelType>.self, from: data)
            return DecodedDataReslut<Resource.ModelType>.Success(wrapper.data)
        } catch DecodingError.dataCorrupted(let context) {
            return DecodedDataReslut<Resource.ModelType>.Error(.DataCorrupted(context))
        } catch DecodingError.keyNotFound(let key, let context) {
            return DecodedDataReslut<Resource.ModelType>.Error(.KeyNotFound(key, context))
        } catch DecodingError.valueNotFound(let value, let context) {
            return DecodedDataReslut<Resource.ModelType>.Error(.ValueNotFound(value, context))
        } catch DecodingError.typeMismatch(let type, let context) {
            return DecodedDataReslut<Resource.ModelType>.Error(.TypeMismatch(type, context))
        } catch {
            return DecodedDataReslut<Resource.ModelType>.Error(.Error(error))
        }
    }
    
    func execute(withCompletion completion: @escaping (NetworkRequestResult<Resource.ModelType>) -> Void) {
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
    func decodeError(_ data: Data) -> DecodedDataReslut<[String]> { return DecodedDataReslut<[String]>.Success([]) }
    
    func decode(_ data: Data) -> DecodedDataReslut<Data> { return DecodedDataReslut<Data>.Success(data) }
    
    func execute(withCompletion completion: @escaping (NetworkRequestResult<Data>) -> Void) {
        load(url, method: "GET", parseResponse: true, withCompletion: completion)
    }
}

// MARK: - API Resource

struct APIResourceOptions {
    let dateDecodingStrategy: JSONDecoder.DateDecodingStrategy
    let parseResponse: Bool
    let httpBody: Data?
    let httpMethod: String
    let headers: [String: String]
    let queryItems: [URLQueryItem]
    let addApiKey: Bool
    
    init(dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .formatted(DateFormatter.iso8601Full),
         parseResponse: Bool = false,
         httpBody: Data? = nil,
         httpMethod: String = "GET",
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
            return DecodedDataReslut<[String]>.Success(errorResponse.error)
        } catch DecodingError.dataCorrupted(let context) {
            return DecodedDataReslut<[String]>.Error(.DataCorrupted(context))
        } catch DecodingError.keyNotFound(let key, let context) {
            return DecodedDataReslut<[String]>.Error(.KeyNotFound(key, context))
        } catch DecodingError.valueNotFound(let value, let context) {
            return DecodedDataReslut<[String]>.Error(.ValueNotFound(value, context))
        } catch DecodingError.typeMismatch(let type, let context) {
            return DecodedDataReslut<[String]>.Error(.TypeMismatch(type, context))
        } catch {
            return DecodedDataReslut<[String]>.Error(.Error(error))
        }
    }
    
    func decode(_ data: Data) -> DecodedDataReslut<Resource.ModelType> {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = resource.options.dateDecodingStrategy
            let wrapper = try decoder.decode(Wrapper<Resource.ModelType>.self, from: data)
            return DecodedDataReslut<Resource.ModelType>.Success(wrapper.data)
        } catch DecodingError.dataCorrupted(let context) {
            return DecodedDataReslut<Resource.ModelType>.Error(.DataCorrupted(context))
        } catch DecodingError.keyNotFound(let key, let context) {
            return DecodedDataReslut<Resource.ModelType>.Error(.KeyNotFound(key, context))
        } catch DecodingError.valueNotFound(let value, let context) {
            return DecodedDataReslut<Resource.ModelType>.Error(.ValueNotFound(value, context))
        } catch DecodingError.typeMismatch(let type, let context) {
            return DecodedDataReslut<Resource.ModelType>.Error(.TypeMismatch(type, context))
        } catch {
            return DecodedDataReslut<Resource.ModelType>.Error(.Error(error))
        }
    }
    
    func execute(withCompletion completion: @escaping (NetworkRequestResult<Resource.ModelType>) -> Void) {
        load(resource.url, headers: resource.options.headers, method: resource.options.httpMethod, uploadData: resource.uploadData, withCompletion: completion)
    }
}

// MARK: - Upload Image Resource

struct UploadImageResourceOptions {
    let dateDecodingStrategy: JSONDecoder.DateDecodingStrategy
    let parseResponse: Bool
    let httpMethod: String
    let headers: [String: String]
    let queryItems: [URLQueryItem]
    let addApiKey: Bool
    
    init(dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .formatted(DateFormatter.iso8601Full),
         parseResponse: Bool = false,
         httpBody: Data? = nil,
         httpMethod: String = "POST",
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
    case .Request(let error):
        print("Request `\(requestName)` error: \(error.localizedDescription)")
    case .Api(let errorData):
        print("Request `\(requestName)` error data: \(errorData)")
    case .PageNotFound(let url):
        print("Request `\(requestName)` error: Page not found with url: \(url)")
    case .EmptyDataStatusCode(let statusCode):
        print("Request `\(requestName)` error: Invalid status code (\(statusCode)) with empty data")
    case .FailedToDeserializeError(let error):
        switch error {
        case .DataCorrupted(let context):
            print("Request `\(requestName)` error: Failed to deserialize data from error: Data corrupted, context: \(context)")
        case .KeyNotFound(let key, let context):
            print("Request `\(requestName)` error: Failed to deserialize data from error: Key `\(key)` not found, context: \(context)")
        case .ValueNotFound(let value, let context):
            print("Request `\(requestName)` error: Failed to deserialize data from error: Value `\(value)` not found, context: \(context)")
        case .TypeMismatch(let type, let context):
            print("Request `\(requestName)` error: Failed to deserialize data from error: Type `\(type)` Mismatch, context: \(context)")
        case .Error(let error):
            print("Request `\(requestName)` error: Failed to deserialize data from error: Unknown error: \(error.localizedDescription)")
        }
    case .FailedToDeserialize(let error):
        switch error {
        case .DataCorrupted(let context):
            print("Request `\(requestName)` error: Failed to deserialize data: Data corrupted, context: \(context)")
        case .KeyNotFound(let key, let context):
            print("Request `\(requestName)` error: Failed to deserialize data: Key `\(key)` not found, context: \(context)")
        case .ValueNotFound(let value, let context):
            print("Request `\(requestName)` error: Failed to deserialize data: Value `\(value)` not found, context: \(context)")
        case .TypeMismatch(let type, let context):
            print("Request `\(requestName)` error: Failed to deserialize data: Type `\(type)` Mismatch, context: \(context)")
        case .Error(let error):
            print("Request `\(requestName)` error: Failed to deserialize data: Unknown error: \(error.localizedDescription)")
        }
    case .failedToGetStatusCode:
        print("Request `\(requestName)` error: Failed to get status code")
    case .selfIsNil:
        print("Request `\(requestName)` error: `self` is `nil`")
    }
}
