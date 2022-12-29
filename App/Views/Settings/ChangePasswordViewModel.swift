//
//  ChangePasswordViewModel.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 09.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import SwiftUI

@MainActor
final class ChangePasswordViewModel: ObservableObject, Alertable {
    @Published var alert: AlertInfo?
    @Published var showLoading = false
    
    func changePasswordRequest(password1: String, password2: String) async -> Bool {
        guard password1.count > 6 else {
            presentAlert(
                title: Text("ChangePasswordViewModel.passwordsDoNotMatchAlertTitle", comment: "Passwords do not match!"),
                message: Text("ChangePasswordViewModel.passwordsDoNotMatchAlertMessage", comment: "Please check that the passwords are the same."), .warning)
            return false
        }
        guard password1 == password2 else {
            presentAlert(title: Text("ChangePasswordViewModel.passwordMustBeMoreThan6charactersAlertTitle", comment: "Password must be more than 6 characters"), .warning)
            return false
        }
        showLoading = true
        do {
            try await Login.changePassword(newPassword: password1)
            return true
        } catch {
            presentGlobalAlert()
            return false
        }
    }
}
