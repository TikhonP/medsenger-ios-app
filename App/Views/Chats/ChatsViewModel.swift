//
//  ChatsViewModel.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 31.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

final class ChatsViewModel: ObservableObject {
    func getArchiveContracts() {
        switch Account.shared.role {
        case .patient:
            Contracts.shared.getDoctorsArchive()
        case .doctor:
            break // FIXME: !!!
        }
    }
    
    func getContracts() {
        switch Account.shared.role {
        case .patient:
            Contracts.shared.getDoctors()
        case .doctor:
            break // FIXME: !!!
        }
    }
    
    func getContractAvatar(contractId: Int) {
        switch Account.shared.role {
        case .patient:
            Contracts.shared.getAndSaveDoctorAvatar(contractId)
        case .doctor:
            break // FIXME: !!!
        }
    }
}
