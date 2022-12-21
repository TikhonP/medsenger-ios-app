//
//  NetworkRequestError.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 02.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import os.log
import SwiftUI

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
    
    /// Empty data with HTTP error
    /// - Parameter statusCode: HTTP status code
    case emptyDataStatusCode(_ statusCode: Int)
    
    /// Failed to deserialize data with JSON
    /// - Parameters:
    ///  - statusCode: HTTP status code
    ///  - decodeDataError: decode JSON from data failure cases
    case failedToDeserialize(_ statusCode: Int, _ decodeDataError: Error)
    
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
        case .notConnectedToInternet:
            ContentViewModel.shared.createGlobalAlert(
                title: Text("processRequestError.internaetConnectionOfflineAlertTitle", comment: "The Internet connection appears to be offline"),
                message: Text("processRequestError.internaetConnectionOfflineAlertMessage", comment: "Turn off Airplane Mode or connect to Wi-Fi."))
            Logger.urlRequest.error("Request `\(requestName)` error: \(urlError.localizedDescription)")
        case .timedOut:
            ContentViewModel.shared.createGlobalAlert(
                title: Text("processRequestError.timeOutAlertTitle", comment: "The request timed out"),
                message: Text("processRequestError.timeOutAlertMessage", comment: "Please check your connection and try again."))
            Logger.urlRequest.error("Request `\(requestName)` error: \(urlError.localizedDescription)")
        default:
            Logger.urlRequest.error("Request `\(requestName)` error: \(urlError.localizedDescription)")
        }
    case .api(let errorData, let statusCode):
        if errorData.errors.contains("Incorrect token") {
            Login.shared.signOut()
            Logger.urlRequest.info("Incorrect token in request, sign out.")
        } else if errorData.errors.contains("Incorrect data") {
            ContentViewModel.shared.createGlobalAlert(
                title: Text("processRequestError.incorrectDataProvidedAlertTitle", comment: "Incorrect data provided"),
                message: Text("processRequestError.IncorrectDataProvidedAlertMessage", comment: "Please check your input or contact Medsenger support."))
            Logger.urlRequest.info("Request `\(requestName)` error: medsenger server status code: \(statusCode), message: \(errorData)")
        } else {
            ContentViewModel.shared.createGlobalAlert(
                title: Text("processRequestError.serverErrorAlertTitle", comment: "Oops! Server error"),
                message: Text(errorData.errors.joined(separator: " ")))
            Logger.urlRequest.error("Request `\(requestName)` error: medsenger server status code: \(statusCode), message: \(errorData)")
        }
    case .emptyDataStatusCode(let statusCode):
        Logger.urlRequest.error("Request `\(requestName)` error: Invalid status code (\(statusCode)) with empty data")
    case .failedToDeserialize(let statusCode, let decodeDataError):
        if let decodeDataError = decodeDataError as? DecodingError {
            switch decodeDataError {
            case .typeMismatch(let type, let context):
                Logger.urlRequest.error("Request `\(requestName)` error: Failed to deserialize data status code: \(statusCode): Type `\(String(describing: type))` Mismatch, context: \(String(describing: context))")
            case .valueNotFound(let value, let context):
                Logger.urlRequest.error("Request `\(requestName)` error: Failed to deserialize data status code: \(statusCode): Value `\(String(describing: value))` not found, context: \(String(describing: context))")
            case .keyNotFound(let key, let context):
                Logger.urlRequest.error("Request `\(requestName)` error: Failed to deserialize data status code: \(statusCode): Key `\(String(describing: key))` not found, context: \(String(describing: context))")
            case .dataCorrupted(let context):
                Logger.urlRequest.error("Request `\(requestName)` error: Failed to deserialize data status code: \(statusCode): Data corrupted, context: \(String(describing: context))")
            @unknown default:
                Logger.urlRequest.error("Request `\(requestName)` error: Failed to deserialize data status code: \(statusCode): Unknown error: \(decodeDataError.localizedDescription)")
            }
        } else {
            Logger.urlRequest.error("Request `\(requestName)` error: Failed to deserialize data status code: \(statusCode): Unknown error: \(decodeDataError.localizedDescription)")
        }
    case .failedToGetResponse:
        Logger.urlRequest.error("Request `\(requestName)` error: Failed to get status code")
    case .selfIsNil:
        Logger.urlRequest.error("Request `\(requestName)` error: `self` is `nil`")
    }
}
