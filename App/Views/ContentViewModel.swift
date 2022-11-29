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
    init() {
        Websockets.shared.contentViewModelDelegate = self
    }
    
    @Published private(set) var isCalling: Bool = false
    @Published private(set) var videoCallContractId: Int?
    @Published private(set) var isCaller: Bool = false
    
    @Published var chatsNavigationSelection: Int? = nil
    @Published var archiveChatsNavigationSelection: Int? = nil
    
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
}

extension ContentViewModel: WebsocketsContentViewModelDelegate {
    func signalClient(_ websockets: Websockets, callWithContractId contractId: Int) {
        showCall(contractId: contractId, isCaller: false)
    }
    
    func signalClient(_ websockets: Websockets, callContinuedWithContractId contractId: Int) {
        showCall(contractId: contractId, isCaller: false)
    }
}
