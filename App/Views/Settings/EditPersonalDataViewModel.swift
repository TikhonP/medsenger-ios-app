//
//  EditPersonalDataViewModel.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 09.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import SwiftUI

@MainActor
final class EditPersonalDataViewModel: ObservableObject, Alertable {
    @Published var alert: AlertInfo?
    @Published var showLoading = false
    
    enum SaveProfileError: Error {
        case invalidEmail, nameCannotBeEmpty
    }
    
    func saveProfileData(name: String, email: String, phone: String, birthday: Date) async throws {
        guard email.isEmail() else {
            presentAlert(title: Text("EditPersonalDataViewModel.invalidEmailAlertTitle", comment: "Invalid email!"), .warning)
            throw SaveProfileError.invalidEmail
        }
        guard !name.isEmpty else {
            presentAlert(
                title: Text("EditPersonalDataViewModel.nameCannotBeEmptyAlertTitle", comment: "Name cannot be empty!"),
                message: Text("EditPersonalDataViewModel.nameCannotBeEmptyAlertMessage", comment: "Please provide a name to continue."), .warning)
            throw SaveProfileError.nameCannotBeEmpty
        }
        showLoading = true
        do {
            try await Account.saveProfileData(name: name, email: email, phone: phone, birthday: birthday)
            showLoading = false
        } catch is UpdateAccountResource.PhoneExistsError {
            showLoading = false
            presentAlert(
                title: Text("EditPersonalDataViewModel.thisPhoneAlresdyInUseAlertTitle", comment: "This phone already in use!"),
                message: Text("EditPersonalDataViewModel.thisPhoneAlresdyInUseAlertMessage", comment: "Please check if the phone is correct."), .warning)
            throw UpdateAccountResource.PhoneExistsError()
        } catch {
            showLoading = false
            presentGlobalAlert()
            throw error
        }
    }
}
