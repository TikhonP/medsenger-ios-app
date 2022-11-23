//
//  ChatsViewModel.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 14.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

final class ChatsViewModel: ObservableObject {
    func getArchiveContracts() {
        switch Account.shared.role {
        case .patient:
            Contracts.shared.getDoctorsArchive()
        case .doctor:
            Contracts.shared.getPatients()
        }
    }
    
    func getContracts() {
//        Websockets.shared.createUrlSession()
        switch Account.shared.role {
        case .patient:
            Contracts.shared.getDoctors()
        case .doctor:
            Contracts.shared.getPatients()
        }
    }
    
    func getContractAvatar(contractId: Int) {
        switch Account.shared.role {
        case .patient:
            Contracts.shared.getAndSaveDoctorAvatar(contractId)
        case .doctor:
            Contracts.shared.getPatients()
        }
    }
    
    func getClinicLogo(contractId: Int) {
        Contracts.shared.getAndSaveClinicLogo(contractId)
    }
}
