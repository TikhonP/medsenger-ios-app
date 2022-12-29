//
//  ContentViewModel.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 24.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import SwiftUI

/// Main app controller with shared property for using all over the app
final class ContentViewModel: ObservableObject {
    static let shared = ContentViewModel()
    
    init() {
        Websockets.shared.contentViewModelDelegate = self
    }
    
    @Published var isCalling: Bool = false
    @Published private(set) var videoCallContractId: Int?
    @Published private(set) var isCaller: Bool = false
    @Published private(set) var openChatContractId: Int?
    @Published private(set) var openedChatContractId: Int?
    
    private var globalAlertTitle: Text?
    private var globalAlertMessage: Text?
    
    /// Store alert data for presenting it anywhere
    /// - Parameters:
    ///   - title: Alert title.
    ///   - message: Alert description.
    public func createGlobalAlert(title: Text, message: Text?) {
        globalAlertTitle = title
        globalAlertMessage = message
    }
    
    /// Get stored alert data
    /// - Returns: tuple with alert title and description
    @MainActor public func getGlobalAlert() -> (title: Text?, message: Text?) {
        let result = (globalAlertTitle, globalAlertMessage)
        globalAlertTitle = nil
        globalAlertMessage = nil
        return result
    }
    
    /// Show call modal
    /// - Parameters:
    ///   - contractId: Contract Id for call.
    ///   - isCaller: Is user caller when opening.
    public func showCall(contractId: Int, isCaller: Bool) {
        DispatchQueue.main.async {
            self.videoCallContractId = contractId
            self.isCaller = isCaller
            self.isCalling = true
        }
    }
    
    /// Stop call and close call modal
    func hideCall() {
        DispatchQueue.main.async {
            self.isCalling = false
        }
    }
    
    /// Mark chat as opened for disable notifications for this chat
    /// - Parameter contractId: Chat contract Id.
    func markChatAsOpened(contractId: Int) {
        DispatchQueue.main.async {
            self.openedChatContractId = contractId
        }
    }
    
    /// Mark chat as closed for enabling notifications for any
    func markChatAsClosed() {
        DispatchQueue.main.async {
            self.openedChatContractId = nil
        }
    }
    
    /// Open chat from deeplink or notification
    /// - Parameter contractId: Chat contract Id
    func openChat(with contractId: Int) {
        DispatchQueue.main.async {
            self.openChatContractId = contractId
        }
    }
    
    /// Process open app from url
    /// - Parameter url: Url from app opened
    func processDeeplink(_ url: URL) {
        DispatchQueue.main.async {
            let paramKey = "c"
            guard let urlComponents = URLComponents(string: url.absoluteString),
                  let stringValue = urlComponents.queryItems?.first(where: { $0.name == paramKey })?.value,
                  let contractId = Int(stringValue) else { return }
            self.openChat(with: contractId)
        }
    }
}

extension ContentViewModel: WebsocketsContentViewModelDelegate {
    func signalClient(_ websockets: Websockets, callWithContractId contractId: Int) {
        showCall(contractId: contractId, isCaller: false)
    }
    
    func signalClient(_ websockets: Websockets, callContinuedWithContractId contractId: Int) {
        showCall(contractId: contractId, isCaller: false)
    }
}
