//
//  ChatsViewModel.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 14.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import UIKit

@MainActor
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
    
    func getArchiveContracts(presentFailedAlert: Bool) async {
        showArchiveContractsLoading = true
        do {
            try await Contracts.fetchArchiveContracts()
            showArchiveContractsLoading = false
        } catch {
            showArchiveContractsLoading = false
            if presentFailedAlert {
                self.presentGlobalAlert()
            }
        }
    }
    
    func getContracts(presentFailedAlert: Bool) async throws {
        showContractsLoading = true
        do {
            _ = await (try Contracts.fetchConsiliumContracts(), try Contracts.fetchContracts())
            showContractsLoading = false
        } catch {
            showContractsLoading = false
            presentGlobalAlert()
            throw error
        }
    }
    
    func getContractAvatar(contractId: Int) async {
        try? await Contracts.fetchContractAvatar(contractId)
    }
    
    func getClinicLogo(contractId: Int, clinicId: Int) async {
        try? await Contracts.fetchClinicLogo(contractId: contractId, clinicId: clinicId)
    }
    
    func declineMessages(contractId: Int) async {
        do {
            try await DoctorActions.deactivateMessages(contractId)
        } catch {
            presentGlobalAlert()
        }
    }
    
    func concludeContract(contractId: Int) async {
        do {
            try await DoctorActions.concludeContract(contractId)
        } catch {
            presentGlobalAlert()
        }
    }
}
