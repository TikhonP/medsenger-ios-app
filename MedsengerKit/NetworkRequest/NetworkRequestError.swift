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
    
    /// Error from medsenger server
    /// - Parameters:
    ///  - errors: Errors response type
    ///  - statusCode: HTTP status code
    case api(_ errors: ErrorResponse, _ statusCode: Int)
    
    /// Failed to deserialize data with JSON
    /// - Parameters:
    ///  - statusCode: HTTP status code
    ///  - decodeDataError: decode JSON from data failure cases
    case failedToDeserialize(_ statusCode: Int, _ decodeDataError: DecodingError)
    
    /// Failed to get `URLSession` response as `HTTPURLResponse`
    case failedToGetResponse
}

/// Process HTTP requests errors
///
/// The common usage of this function:
///
///     do {
///         // The request
///     } catch {
///         throw await processRequestError(error, "request name")
///     }
///
/// - Parameters:
///   - requestError: error from request result
///   - requestName: name of request for logging
///   - apiErrors: Array of errors to check and throw
func processRequestError(_ error: Error, _ requestName: String, apiErrors: [APIResourceError<Error>] = []) async -> Error {
    guard let requestError = error as? NetworkRequestError else {
        Logger.urlRequest.error("ProcessRequestError: \(requestName): Unknown error: \(error.localizedDescription)")
        return error
    }
    switch requestError {
    case .request(let urlError):
        Logger.urlRequest.error("ProcessRequestError: \(requestName): Request error: \(urlError.localizedDescription)")
        switch urlError.code {
        case .notConnectedToInternet:
            ContentViewModel.shared.createGlobalAlert(
                title: Text("processRequestError.internaetConnectionOfflineAlertTitle", comment: "The Internet connection appears to be offline"),
                message: Text("processRequestError.internaetConnectionOfflineAlertMessage", comment: "Turn off Airplane Mode or connect to Wi-Fi."))
        case .timedOut:
            ContentViewModel.shared.createGlobalAlert(
                title: Text("processRequestError.timeOutAlertTitle", comment: "The request timed out"),
                message: Text("processRequestError.timeOutAlertMessage", comment: "Please check your connection and try again."))
        default:
            break
        }
    case .api(let errorData, let statusCode):
        for error in apiErrors {
            if errorData.errors.contains(error.errorString) {
                return error.error
            }
        }
        if errorData.errors.contains(Constants.MedsengerErrorStrings.incorrectToken) {
            try? await Login.signOut()
            Logger.urlRequest.info("ProcessRequestError: \(requestName): Incorrect token in request, sign out")
        } else if errorData.errors.contains(Constants.MedsengerErrorStrings.incorrectData) {
            ContentViewModel.shared.createGlobalAlert(
                title: Text("processRequestError.incorrectDataProvidedAlertTitle", comment: "Incorrect data provided"),
                message: Text("processRequestError.IncorrectDataProvidedAlertMessage", comment: "Please check your input or contact Medsenger support."))
            Logger.urlRequest.info("ProcessRequestError: \(requestName): Incorrect data: Status code: \(statusCode)")
        } else {
            ContentViewModel.shared.createGlobalAlert(
                title: Text("processRequestError.serverErrorAlertTitle", comment: "Oops! Server error"),
                message: Text(errorData.errors.joined(separator: " ")))
            Logger.urlRequest.error("ProcessRequestError: \(requestName): Api error: \(errorData): Status code: \(statusCode)")
        }
    case .failedToDeserialize(let statusCode, let decodeDataError):
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
    case .failedToGetResponse:
        Logger.urlRequest.error("ProcessRequestError: \(requestName): Failed to get HTTPURLResponse and retrieve status code")
    }
    return requestError
}
