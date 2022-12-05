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
}

enum Sex: String, Codable, CaseIterable {
    case male, female
}

final class AddContractViewModel: ObservableObject {
    @Published var clinicId: Int = {
        if let clinic = Clinic.objectsAll().first {
            return Int(clinic.id)
        } else {
            return 1
        }
    }()
    @Published var clinic: Clinic?
    @Published var patientEmail = ""
    @Published var state: AddContractViewStates = .inputClinicAndEmail
    
    @Published var patientName = ""
    @Published var patientBirthday = Date()
    @Published var patientSex: Sex = .male
    @Published var patientPhone = ""
    
    @Published var contractNumber = ""
    @Published var contractEndDate = Date()
    @Published var clinicRuleId: Int = 0
    @Published var clinicClassifierId: Int = 0
    @Published var videoEnabled = false
    
    @Published var showContractExistsAlert = false
    
    @Published var submittingAddPatient = false
    
    private var userExists: Bool?
    
    let welcomeMessage = "" // FIXME: !!!
    
    func findPatient() {
        state = .fetchingUserFromMedsenger
        clinic = Clinic.get(id: clinicId)
        if let rule = clinic?.rulesArray.first {
            clinicRuleId = Int(rule.id)
        }
        if let classifier = clinic?.classifiersArray.first {
            clinicClassifierId = Int(classifier.id)
        }
        DoctorActions.shared.findUser(clinicId: clinicId, email: patientEmail, completion: { [weak self] data, contractExists in
            DispatchQueue.main.async {
                if contractExists {
                    self?.showContractExistsAlert = true
                    self?.state = .inputClinicAndEmail
                } else {
                    guard let data = data else {
                        self?.state = .inputClinicAndEmail
                        return
                    }
                    self?.userExists = data.found
                    self?.patientName = ""
                    self?.patientBirthday = Date()
                    if data.found {
                        self?.state = .knownClient
                        if let name = data.name, let birthday = data.birthday {
                            self?.patientName = name
                            self?.patientBirthday = birthday
                        }
                    } else {
                        self?.state = .unknownClient
                    }
                }
            }
        })
    }
    
    func addContract(completion: @escaping () -> Void) {
        guard let userExists = userExists else {
            print("lol")
            return
        }
        submittingAddPatient = true
        let addContractRequestModel = AddContractRequestModel(
            clinic: clinicId,
            email: patientEmail,
            exists: userExists,
            birthday: patientBirthday,
            name: patientName,
            sex: patientSex,
            phone: patientPhone,
            endDate: contractEndDate,
            rule: String(clinicRuleId),
            classifier: String(clinicClassifierId),
            welcomeMessage: welcomeMessage,
            video: videoEnabled,
            number: contractNumber)
        DoctorActions.shared.addContract(addContractRequestModel) { [weak self] succeeded in
            DispatchQueue.main.async {
                self?.submittingAddPatient = false
                if succeeded {
                    completion()
                }
            }
        }
    }
}
