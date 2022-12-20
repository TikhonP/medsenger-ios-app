//
//  ChatsViewModel.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 14.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import UIKit

final class ChatsViewModel: ObservableObject, Alertable {
    static let shared = ChatsViewModel()
    
    @Published var showContractsLoading = false
    @Published var showArchiveContractsLoading = false
    @Published var alert: AlertInfo?
    
    func canCallClinicPhone(contract: Contract) -> String? {
        guard let clinic = contract.clinic, clinic.phonePaid, let phoneNumber = clinic.phone, !phoneNumber.isEmpty else {
            return nil
        }
        return phoneNumber
    }
    
    func callClinic(phone: String) {
        let formattedString = "tel://" + phone.replacingOccurrences(
            of: #"[^\d]"#, with: "", options: .regularExpression)
        guard let url = URL(string: formattedString) else { return }
        UIApplication.shared.open(url)
    }
    
    func initilizeWebsockets() {
        Websockets.shared.createUrlSession()
    }
    
    func getArchiveContracts(presentFailedAlert: Bool) {
        DispatchQueue.main.async {
            self.showArchiveContractsLoading = true
        }
        Contracts.shared.fetchArchiveContracts { [weak self] succeeded in
            DispatchQueue.main.async {
                self?.showArchiveContractsLoading = false
                if !succeeded, presentFailedAlert {
                    self?.presentGlobalAlert()
                }
            }
        }
    }
    
    func getContracts(presentFailedAlert: Bool) {
        DispatchQueue.main.async {
            self.showContractsLoading = true
        }
        Contracts.shared.fetchConsiliumContracts()
        Contracts.shared.fetchContracts { [weak self] succeeded in
            DispatchQueue.main.async {
                self?.showContractsLoading = false
                if !succeeded, presentFailedAlert {
                    self?.presentGlobalAlert()
                }
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
        DoctorActions.shared.deactivateMessages(contractId) { [weak self] succeeded in
            if !succeeded {
                self?.presentGlobalAlert()
            }
        }
    }
    
    func concludeContract(contractId: Int) {
        DoctorActions.shared.concludeContract(contractId) { [weak self] succeeded in
            if !succeeded {
                self?.presentGlobalAlert()
            }
        }
    }
}
