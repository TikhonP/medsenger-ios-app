//
//  ChatsViewModel.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 14.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

final class ChatsViewModel: ObservableObject {
    func initilizeWebsockets() {
        Websockets.shared.createUrlSession()
    }
    
    func getArchiveContracts() {
        Contracts.shared.fetchArchiveContracts()
    }
    
    func getContracts() {
        Contracts.shared.fetchContracts()
    }
    
    func getContractAvatar(contractId: Int) {
        Contracts.shared.fetchContractAvatar(contractId)
    }
    
    func getClinicLogo(contractId: Int) {
        Contracts.shared.fetchClinicLogo(contractId)
    }
}
