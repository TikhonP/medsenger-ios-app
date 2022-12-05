//
//  NetworkRequestError.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 02.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import os.log

/// Network request failure cases
enum NetworkRequestError: Error {
    
    /// Error with `URLSession` request
    /// - Parameter error: Error codes returned by URL loading APIs
    case request(_ error: URLError)
    
    /// Failed to get `URLSession` error as `URLError`
    /// - Parameter error: error
    case failedToGetUrlError(_ error: Error)
    
    /// Error from medsenger server
    /// - Parameters:
    ///  - errors: Errors response type
    ///  - statusCode: HTTP status code
    case api(_ errors: ErrorResponse, _ statusCode: Int)
    
    /// Invalid status code but api decoded succeded
    /// - Parameter statusCode: HTTP status code
    case apiWithDecodedData(_ statusCode: Int)
    
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
    case failedToDeserializeError(_ statusCode: Int, _ decodeDataError: Error)
    
    /// Failed to deserialize data with JSON
    /// - Parameters:
    ///  - decodeDataError: decode JSON from data failure cases
    case failedToDeserialize(_ decodeDataError: Error)
    
    /// Failed to get `URLSession` response as `HTTPURLResponse`
    case failedToGetResponse
    
    /// Weak `self` is nil
    case selfIsNil
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
    case .api(let errorData, let statusCode):
        if errorData.errors.contains("Incorrect token") {
            Login.shared.signOut()
            Logger.urlRequest.info("Incorrect token in request, sign out.")
        } else {
            Logger.urlRequest.error("Request `\(requestName)` error: medsenger server status code: \(statusCode), message: \(errorData)")
        }
    case .pageNotFound(let url):
        Logger.urlRequest.error("Request `\(requestName)` error: Page not found with url: \(url)")
    case .emptyDataStatusCode(let statusCode):
        Logger.urlRequest.error("Request `\(requestName)` error: Invalid status code (\(statusCode)) with empty data")
    case .failedToDeserializeError(let statusCode, let decodeDataError):
        if let decodeDataError = decodeDataError as? DecodingError {
            switch decodeDataError {
            case .typeMismatch(let type, let context):
                Logger.urlRequest.error("Request `\(requestName)` error: Failed to deserialize data from error (status code: \(statusCode)): Type `\(String(describing: type))` Mismatch, context: \(String(describing: context))")
            case .valueNotFound(let value, let context):
                Logger.urlRequest.error("Request `\(requestName)` error: Failed to deserialize data from error (status code: \(statusCode)): Value `\(String(describing: value))` not found, context: \(String(describing: context))")
            case .keyNotFound(let key, let context):
                Logger.urlRequest.error("Request `\(requestName)` error: Failed to deserialize data from error (status code: \(statusCode)): Key `\(String(describing: key))` not found, context: \(String(describing: context))")
            case .dataCorrupted(let context):
                Logger.urlRequest.error("Request `\(requestName)` error: Failed to deserialize data from error (status code: \(statusCode)): Data corrupted, context: \(String(describing: context))")
            @unknown default:
                Logger.urlRequest.error("Request `\(requestName)` error: Failed to deserialize data from error (status code: \(statusCode)): Unknown error: \(decodeDataError.localizedDescription)")
            }
        } else {
            Logger.urlRequest.error("Request `\(requestName)` error: Failed to deserialize data from error (status code: \(statusCode)): Unknown error: \(decodeDataError.localizedDescription)")
        }
    case .failedToDeserialize(let decodeDataError):
        if let decodeDataError = decodeDataError as? DecodingError {
            switch decodeDataError {
            case .typeMismatch(let type, let context):
                Logger.urlRequest.error("Request `\(requestName)` error: Failed to deserialize data: Type `\(String(describing: type))` Mismatch, context: \(String(describing: context))")
            case .valueNotFound(let value, let context):
                Logger.urlRequest.error("Request `\(requestName)` error: Failed to deserialize data: Value `\(String(describing: value))` not found, context: \(String(describing: context))")
            case .keyNotFound(let key, let context):
                Logger.urlRequest.error("Request `\(requestName)` error: Failed to deserialize data: Key `\(String(describing: key))` not found, context: \(String(describing: context))")
            case .dataCorrupted(let context):
                Logger.urlRequest.error("Request `\(requestName)` error: Failed to deserialize data: Data corrupted, context: \(String(describing: context))")
            @unknown default:
                Logger.urlRequest.error("Request `\(requestName)` error: Failed to deserialize data: Unknown error: \(decodeDataError.localizedDescription)")
            }
        } else {
            Logger.urlRequest.error("Request `\(requestName)` error: Failed to deserialize data: Unknown error: \(decodeDataError.localizedDescription)")
        }
    case .failedToGetResponse:
        Logger.urlRequest.error("Request `\(requestName)` error: Failed to get status code")
    case .selfIsNil:
        Logger.urlRequest.error("Request `\(requestName)` error: `self` is `nil`")
    case .apiWithDecodedData(let statusCode):
        Logger.urlRequest.error("Request `\(requestName)` error: apiWithDecodedData statusCode: \(statusCode)")
    }
}
