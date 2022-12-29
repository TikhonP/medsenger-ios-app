//
//  SignInViewModel.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 24.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import SwiftUI

@MainActor
final class SignInViewModel: ObservableObject, Alertable {
    @Published var login: String = ""
    @Published var password: String = ""
    @Published var showLoader = false
    @Published var alert: AlertInfo?
    
    func auth() async {
        guard !login.isEmpty, !password.isEmpty else {
            presentAlert(
                title: Text("SignInViewModel.fieldsAreEmptyAlertTitle", comment: "Provide auth data!"),
                message: Text("SignInViewModel.fieldsAreEmptyAlertMessage", comment: "Please fill both username and password fields."), .warning)
            return
        }
        showLoader = true
        do {
            try await Login.signIn(login: login, password: password)
            showLoader = false
        } catch SignInResource.SignInError.userIsNotActivated {
            showLoader = false
            presentAlert(title: Text("SignInViewModel.userIsNotActivatedAlertTitle", comment: "User is not activated!"), .error)
        } catch SignInResource.SignInError.incorrectData {
            showLoader = false
            presentAlert(title: Text("SignInViewModel.userIsNotFoundAlertTitle", comment: "User is not found!"), .error)
        } catch SignInResource.SignInError.incorrectPassword {
            showLoader = false
            presentAlert(title: Text("SignInViewModel.invalidPasswordALertTitle", comment: "Invalid password!"), .error)
        } catch {
            showLoader = false
            presentGlobalAlert()
        }
    }
}
