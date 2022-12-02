//
//  AddContractViewModel.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 02.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

enum AddContractViewStates {
    case inputClinicAndEmail
    case fetchingUserFromMedsenger
    case knownClient, unknownClient
    case submittingAddPatient
}

enum Sex: Codable {
    case male, female
}

final class AddContractViewModel: ObservableObject {
    @Published var clinic: Clinic?
    @Published var patientEmail = ""
    @Published var state: AddContractViewStates = .inputClinicAndEmail
    
    @Published var patientName = ""
    @Published var patientBirthday = Date()
    @Published var patientSex: Sex = .male
    @Published var patientPhone = ""
    
    @Published var contractNumber = ""
    @Published var contractEndDate = Date()
    @Published var clinicRule: ClinicRule?
    @Published var clinicClassifier: ClinicClassifier?
    @Published var videoEnabled = false
    
    private var contractExist: Bool?
    
    let welcomeMessage = "" // FIXME: !!!
    
    func findPatient() {
        state = .fetchingUserFromMedsenger
        // TODO: validate values
        guard let clinic = clinic else {
            return
        }
        DoctorActions.shared.findUser(clinicId: Int(clinic.id), email: patientEmail, completion: { [weak self] data in
            DispatchQueue.main.async {
                guard data != nil else {
                    self?.state = .inputClinicAndEmail
                    return
                }
                self?.state = .knownClient
            }
        })
    }
    
    func addContract(completion: @escaping () -> Void) {
        guard let contractExist = contractExist, let clinic = clinic, let clinicRule = clinicRule, let clinicClassifier = clinicClassifier else {
            return
        }
        state = .submittingAddPatient
        let addContractRequestModel = AddContractRequestModel(
            clinic: Int(clinic.id),
            email: patientEmail,
            exists: contractExist,
            birthday: patientBirthday,
            name: patientName,
            sex: patientSex,
            phone: patientPhone,
            endDate: contractEndDate,
            rule: String(clinicRule.id),
            classifier: String(clinicClassifier.id),
            welcomeMessage: welcomeMessage,
            video: videoEnabled,
            number: contractNumber)
        DoctorActions.shared.addContract(addContractRequestModel) { succeeded in
            if succeeded {
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
}
