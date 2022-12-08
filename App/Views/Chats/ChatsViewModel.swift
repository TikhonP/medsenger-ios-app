//
//  ChatsViewModel.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 14.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

final class ChatsViewModel: ObservableObject {
    @Published var showContractsLoading = false
    @Published var showArchiveContractsLoading = false
    
    func initilizeWebsockets() {
        Websockets.shared.createUrlSession()
    }
    
    func getArchiveContracts() {
        DispatchQueue.main.async {
            self.showArchiveContractsLoading = true
        }
        Contracts.shared.fetchArchiveContracts { [weak self] in
            DispatchQueue.main.async {
                self?.showArchiveContractsLoading = false
            }
        }
    }
    
    func getContracts() {
        DispatchQueue.main.async {
            self.showContractsLoading = true
        }
        Contracts.shared.fetchContracts { [weak self] in
            DispatchQueue.main.async {
                self?.showContractsLoading = false
            }
        }
    }
    
    func getContractAvatar(contractId: Int) {
        Contracts.shared.fetchContractAvatar(contractId)
    }
    
    func getClinicLogo(contractId: Int) {
        Contracts.shared.fetchClinicLogo(contractId)
    }
    
    func declineMessages(contractId: Int) {
        DoctorActions.shared.deactivateMessages(contractId)
    }
    
    func concludeContract(contractId: Int) {
        DoctorActions.shared.concludeContract(contractId)
    }
}
