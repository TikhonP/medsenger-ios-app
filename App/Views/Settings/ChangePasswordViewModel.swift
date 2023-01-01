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
    
    enum ChangePasswordRequestError: Error {
        case passwordsDoNotMatch, passwordMustBeMoreThan6characters, request(Error)
    }
    
    func changePasswordRequest(password1: String, password2: String) async throws {
        guard password1.count > 6 else {
            presentAlert(title: Text("ChangePasswordViewModel.passwordMustBeMoreThan6charactersAlertTitle", comment: "Password must be more than 6 characters"), .warning)
            throw ChangePasswordRequestError.passwordMustBeMoreThan6characters
        }
        guard password1 == password2 else {
            presentAlert(
                title: Text("ChangePasswordViewModel.passwordsDoNotMatchAlertTitle", comment: "Passwords do not match!"),
                message: Text("ChangePasswordViewModel.passwordsDoNotMatchAlertMessage", comment: "Please check that the passwords are the same."), .warning)
            throw ChangePasswordRequestError.passwordsDoNotMatch
        }
        showLoading = true
        do {
            try await Login.changePassword(newPassword: password1)
            showLoading = false
        } catch {
            presentGlobalAlert()
            showLoading = false
            throw ChangePasswordRequestError.request(error)
        }
    }
}
