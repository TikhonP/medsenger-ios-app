//
//  ContractViewModel.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 02.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

final class ContractViewModel: ObservableObject {
    let contractId: Int
    
    init(contractId: Int) {
        self.contractId = contractId
    }
    
    func declineMessages() {
        DoctorActions.shared.deactivateMessages(contractId)
    }
    
    func concludeContract() {
        DoctorActions.shared.concludeContract(contractId)
    }
}
