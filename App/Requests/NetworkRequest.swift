//
//  NetworkRequest.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 24.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

// MARK: - NetworkRequest

enum NetworkRequestError {
    case failedToGetStatusCode
    case requestError
    case emptyDataOrFailedToDeserializeError
    case emptyDataOrFailedToDeserializeValue
    case pageNotFound
}

protocol NetworkRequest: AnyObject {
    associatedtype ModelType
    associatedtype ErrorModelType
    
    func decode(_ data: Data) -> ModelType?
    func decodeError(_ data: Data) -> ErrorModelType?
    func execute(withCompletion completion: @escaping (ModelType?, ErrorModelType?, NetworkRequestError?) -> Void)
}

extension NetworkRequest {
    fileprivate func load(_ url: URL, headers: [String: String]?, method: String = "GET", body: Data? = nil, parseResponse: Bool = false, withCompletion completion: @escaping (ModelType?, ErrorModelType?, NetworkRequestError?) -> Void) {
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        if let headers = headers {
            for header in headers {
                request.setValue(header.value, forHTTPHeaderField: header.key)
            }
        }
        if let body = body {
            request.httpBody = body
        }
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) -> Void in
            if let error = error {
                print("Request error: \(error.localizedDescription)")
                DispatchQueue.main.async { completion(nil, nil, .requestError) }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async { completion(nil, nil, .failedToGetStatusCode) }
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                if httpResponse.statusCode == 404 {
                    DispatchQueue.main.async { completion(nil, nil, .pageNotFound) }
                    print("URL: \(url)")
                    return
                }
                guard let data = data, let errorFromData = self?.decodeError(data) else {
                    DispatchQueue.main.async { completion(nil, nil, .emptyDataOrFailedToDeserializeError) }
                    return
                }
                DispatchQueue.main.async { completion(nil, errorFromData, nil) }
                return
            }
            if parseResponse {
                guard let data = data, let value = self?.decode(data) else {
                    if let data = data {
                        print(String(decoding: data, as: UTF8.self))
                    }
                    DispatchQueue.main.async { completion(nil, nil, .emptyDataOrFailedToDeserializeValue) }
                    return
                }
                DispatchQueue.main.async { completion(value, nil, nil) }
            } else {
                DispatchQueue.main.async { completion(nil, nil, nil) }
            }
        }
        task.resume()
    }
}

// MARK: - ImageRequest

class ImageRequest {
    let url: URL
    
    init(path: String) {
        var components = URLComponents(string: Constants.medsengerApiUrl)!
        components.path = components.path + path
        components.queryItems = [
            URLQueryItem(name: "api_token", value: KeychainSwift.apiToken),
        ]
        self.url = components.url!
    }
}

extension ImageRequest: NetworkRequest {
    func decodeError(_ data: Data) -> Void? { return nil }
    
    func decode(_ data: Data) -> Data? { data }
    
    func execute(withCompletion completion: @escaping (_ data:  Data?, _ errorReponse: Void?, _ networkRequestError: NetworkRequestError?) -> Void) {
        load(url, headers: nil, method: "GET", withCompletion: completion)
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
    func decodeError(_ data: Data) -> ErrorReponse? {
        let decoder = JSONDecoder()
        if let dateDecodingStrategy = resource.dateDecodingStrategy {
            decoder.dateDecodingStrategy = dateDecodingStrategy
        } else {
            decoder.dateDecodingStrategy = .secondsSince1970
        }
        let errorResponse = try? decoder.decode(ErrorReponse.self, from: data)
        return errorResponse
    }
    
    func decode(_ data: Data) -> Wrapper<Resource.ModelType>? {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
   
            let wrapper = try decoder.decode(Wrapper<Resource.ModelType>.self, from: data)
            return wrapper
        } catch DecodingError.dataCorrupted(let context) {
            print(context)
            return nil
        } catch DecodingError.keyNotFound(let key, let context) {
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
            return nil
        } catch DecodingError.valueNotFound(let value, let context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
            return nil
        } catch DecodingError.typeMismatch(let type, let context) {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
            return nil
        } catch {
            print("error: ", error)
            return nil
        }
    }
    
    func execute(withCompletion completion: @escaping (_ data:  Wrapper<Resource.ModelType>?, _ errorReponse: ErrorReponse?, _ networkRequestError: NetworkRequestError?) -> Void) {
        load(resource.url, headers: resource.headers, method: resource.httpMethod, body: resource.httpBody, parseResponse: resource.parseResponse, withCompletion: completion)
    }
}

// MARK: - APIResource

protocol APIResource {
    associatedtype ModelType: Decodable
    
    associatedtype ErrorModelType: Decodable = ErrorReponse
    
    var dateDecodingStrategy: JSONDecoder.DateDecodingStrategy? { get }
    var parseResponse: Bool { get }
    var httpBody: Data? { get }
    var httpMethod: String { get }
    var headers: [String: String]? { get }
    var methodPath: String { get }
    var queryItems: [URLQueryItem]? { get }
    var addApiKey: Bool { get }
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
        if let queryItems = queryItems {
            components.queryItems = queryItems
        }
        if addApiKey {
            if var queryItems = components.queryItems {
                queryItems.append(URLQueryItem(name: "api_token", value: KeychainSwift.apiToken))
                components.queryItems = queryItems
            } else {
                components.queryItems = [URLQueryItem(name: "api_token", value: KeychainSwift.apiToken)]
            }
        }
        return components.url!
    }
}

// MARK: - UploadImageRequest

class UploadImageRequest<Resource: UploadImageResource> {
    let resource: Resource
    
    init(resource: Resource) {
        self.resource = resource
    }
}

extension UploadImageRequest: NetworkRequest {
    func decodeError(_ data: Data) -> ErrorReponse? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        let errorResponse = try? decoder.decode(ErrorReponse.self, from: data)
        return errorResponse
    }
    
    func decode(_ data: Data) -> Wrapper<Resource.ModelType>? {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            
            let wrapper = try decoder.decode(Wrapper<Resource.ModelType>.self, from: data)
            return wrapper
        } catch DecodingError.dataCorrupted(let context) {
            print(context)
            return nil
        } catch DecodingError.keyNotFound(let key, let context) {
            print("Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
            return nil
        } catch DecodingError.valueNotFound(let value, let context) {
            print("Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
            return nil
        } catch DecodingError.typeMismatch(let type, let context) {
            print("Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
            return nil
        } catch {
            print("error: ", error)
            return nil
        }
    }
    
    func load(_ url: URL, headers: [String: String]?, data: Data, withCompletion completion: @escaping (ModelType?, ErrorModelType?, NetworkRequestError?) -> Void) {
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        if let headers = headers {
            for header in headers {
                request.setValue(header.value, forHTTPHeaderField: header.key)
            }
        }
        
        let task = URLSession.shared.uploadTask(with: request, from: data) { [weak self] (data, response, error) -> Void in
            if let error = error {
                print("Request error: \(error.localizedDescription)")
                DispatchQueue.main.async { completion(nil, nil, .requestError) }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async { completion(nil, nil, .failedToGetStatusCode) }
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                if httpResponse.statusCode == 404 {
                    DispatchQueue.main.async { completion(nil, nil, .pageNotFound) }
                    print("URL: \(url)")
                    return
                }
                guard let data = data, let errorFromData = self?.decodeError(data) else {
                    DispatchQueue.main.async { completion(nil, nil, .emptyDataOrFailedToDeserializeError) }
                    return
                }
                DispatchQueue.main.async { completion(nil, errorFromData, nil) }
                return
            }
            guard let data = data, let value = self?.decode(data) else {
                DispatchQueue.main.async { completion(nil, nil, nil) }
                return
            }
            DispatchQueue.main.async { completion(value, nil, nil) }
        }
        task.resume()
    }
    
    func execute(withCompletion completion: @escaping (_ data:  Wrapper<Resource.ModelType>?, _ errorReponse: ErrorReponse?, _ networkRequestError: NetworkRequestError?) -> Void) {
        load(resource.url, headers: resource.headers, data: resource.data, withCompletion: completion)
    }
}

// MARK: - UploadImageResource

protocol UploadImageResource {
    associatedtype ModelType: Decodable
    
    associatedtype ErrorModelType: Decodable = ErrorReponse
    
    var data: Data { get }
    var headers: [String: String]? { get }
    var methodPath: String { get }
    var queryItems: [URLQueryItem]? { get }
    var addApiKey: Bool { get }
}

extension UploadImageResource {
    var url: URL {
        var components = URLComponents(string: Constants.medsengerApiUrl)!
        components.path = components.path + methodPath
        if let queryItems = queryItems {
            components.queryItems = queryItems
        }
        if addApiKey {
            if var queryItems = components.queryItems {
                queryItems.append(URLQueryItem(name: "api_token", value: KeychainSwift.apiToken))
                components.queryItems = queryItems
            } else {
                components.queryItems = [URLQueryItem(name: "api_token", value: KeychainSwift.apiToken)]
            }
        }
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

// MARK: - QueryItems

protocol QueryItems {
    var queryItems: [URLQueryItem] { get }
}
