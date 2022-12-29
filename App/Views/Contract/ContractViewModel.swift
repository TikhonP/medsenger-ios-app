//
//  ContractViewModel.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 02.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import UIKit


@MainActor
final class ContractViewModel: ObservableObject, Alertable {
    @Published var showRemoveScenarioLoading = false
    @Published var showChooseScenario = false
    @Published var alert: AlertInfo?
    
    let contractId: Int
    
    init(contractId: Int) {
        self.contractId = contractId
    }
    
    func declineMessages() async {
        do {
            try await DoctorActions.deactivateMessages(contractId)
        } catch {
            presentGlobalAlert()
        }
    }
    
    func concludeContract() async {
        do {
            try await DoctorActions.concludeContract(contractId)
        } catch {
            presentGlobalAlert()
        }
    }
    
    func removeScenario() async {
        showRemoveScenarioLoading = true
        do {
            try await DoctorActions.removeScenario(contractId: contractId)
            showRemoveScenarioLoading = false
        } catch {
            presentGlobalAlert()
            showRemoveScenarioLoading = false
        }
    }
    
    func getContracts() async {
        _ = await (try? Contracts.fetchContracts(), try? Contracts.fetchConsiliumContracts())
    }
    
    func callClinic(phone: String) {
        let formattedString = "tel://" + phone.replacingOccurrences(
            of: #"[^\d]"#, with: "", options: .regularExpression)
        guard let url = URL(string: formattedString) else { return }
        UIApplication.shared.open(url)
    }
}
