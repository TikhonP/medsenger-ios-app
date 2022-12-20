//
//  ContractViewModel.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 02.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import UIKit

final class ContractViewModel: ObservableObject, Alertable {
    @Published var showRemoveScenarioLoading = false
    @Published var showChooseScenario = false
    @Published var alert: AlertInfo?
    
    let contractId: Int
    
    init(contractId: Int) {
        self.contractId = contractId
    }
    
    func declineMessages() {
        DoctorActions.shared.deactivateMessages(contractId) { [weak self] succeeded in
            if !succeeded {
                self?.presentGlobalAlert()
            }
        }
    }
    
    func concludeContract() {
        DoctorActions.shared.concludeContract(contractId) { [weak self] succeeded in
            if !succeeded {
                self?.presentGlobalAlert()
            }
        }
    }
    
    func removeScenario() {
        showRemoveScenarioLoading = true
        DoctorActions.shared.removeScenario(contractId: contractId) { [weak self] succeeded in
            DispatchQueue.main.async {
                self?.showRemoveScenarioLoading = false
            }
        }
    }
    
    func getContracts() {
        Contracts.shared.fetchContracts() { _ in }
        Contracts.shared.fetchConsiliumContracts()
    }
    
    func callClinic(phone: String) {
        let formattedString = "tel://" + phone.replacingOccurrences(
            of: #"[^\d]"#, with: "", options: .regularExpression)
        guard let url = URL(string: formattedString) else { return }
        UIApplication.shared.open(url)
    }
}
