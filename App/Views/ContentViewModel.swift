//
//  ContentViewModel.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 24.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import SwiftUI

final class ContentViewModel: ObservableObject {
    static let shared = ContentViewModel()
    
    init() {
        Websockets.shared.contentViewModelDelegate = self
    }
    
    @Published private(set) var isCalling: Bool = false
    @Published private(set) var videoCallContractId: Int?
    @Published private(set) var isCaller: Bool = false
    
    @Published private(set) var openChatContractId: Int?
    
    func showCall(contractId: Int, isCaller: Bool) {
        DispatchQueue.main.async {
            withAnimation {
                self.videoCallContractId = contractId
                self.isCaller = isCaller
                self.isCalling = true
            }
        }
    }
    
    func hideCall() {
        DispatchQueue.main.async {
            withAnimation {
                self.isCalling = false
            }
        }
    }
    
    func openChat(with contractId: Int) {
        DispatchQueue.main.async {
            self.openChatContractId = contractId
        }
    }
    
    func processDeeplink(_ url: URL) {
        guard let urlComponents = URLComponents(string: url.absoluteString) else { return }
        guard let queryItems = urlComponents.queryItems else { return }
        for queryItem in queryItems {
            if queryItem.name == "c" {
                if let contractId = queryItem.value,  let contractId = Int(contractId) {
                    openChat(with: contractId)
                }
            }
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
