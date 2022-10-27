//
//  SignInViewModel.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 24.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI
import Foundation

final class SignInViewModel: ObservableObject {
    @Published var error: String = LocalizedStringKey("Unknown Error").stringValue()
    @Published var showError: Bool = false
    
    private let account: Account
    
    @Published var login: String = ""
    @Published var password: String = ""
    
    @Published var showLoader = false
    
    init(account: Account) {
        self.account = account
    }
    
    func auth() {
        account.signIn(login: login, password: password) { code in
            switch code {
            case .success:
                break
            case .unknownError:
                self.showError = true
            case .userIsNotActivated:
                self.error = LocalizedStringKey("User not activated").stringValue()
                self.showError = true
            case .incorrectData:
                self.error = LocalizedStringKey("User is not found").stringValue()
                self.showError = true
            case .incorrectPassword:
                self.error = LocalizedStringKey("Invalid password").stringValue()
                self.showError = true
            }
        }
    }
}
