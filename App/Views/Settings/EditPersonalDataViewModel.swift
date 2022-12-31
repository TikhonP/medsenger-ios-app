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
    
    func saveProfileData(name: String, email: String, phone: String, birthday: Date) async -> Bool {
        guard email.isEmail() else {
            presentAlert(title: Text("EditPersonalDataViewModel.invalidEmailAlertTitle", comment: "Invalid email!"), .warning)
            return false
        }
        guard !name.isEmpty else {
            presentAlert(
                title: Text("EditPersonalDataViewModel.nameCannotBeEmptyAlertTitle", comment: "Name cannot be empty!"),
                message: Text("EditPersonalDataViewModel.nameCannotBeEmptyAlertMessage", comment: "Please provide a name to continue."), .warning)
            return false
        }
        showLoading = true
        do {
            try await Account.saveProfileData(name: name, email: email, phone: phone, birthday: birthday)
            showLoading = false
            return true
        } catch is UpdateAccountResource.PhoneExistsError {
            showLoading = false
            presentAlert(
                title: Text("EditPersonalDataViewModel.thisPhoneAlresdyInUseAlertTitle", comment: "This phone already in use!"),
                message: Text("EditPersonalDataViewModel.thisPhoneAlresdyInUseAlertMessage", comment: "Please check if the phone is correct."), .warning)
            return false
        } catch {
            showLoading = false
            presentGlobalAlert()
            return false
        }
    }
}
