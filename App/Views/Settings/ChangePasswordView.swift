//
//  ChangePasswordView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 13.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct ChangePasswordView: View {
    @StateObject private var changePasswordViewModel = ChangePasswordViewModel()
    
    @EnvironmentObject private var settingsViewModel: SettingsViewModel
    
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var password1: String = ""
    @State private var password2: String = ""
    
    @State private var showLoading = false
    @State private var presentAlert = false
    
    var body: some View {
        Form {
            Section(footer: Text("Password must be more than 6 characters")) {
                PasswordFieldView(password: $password1, placeholder: LocalizedStringKey("New password").stringValue())
                PasswordFieldView(password: $password2, placeholder: LocalizedStringKey("Repeat password").stringValue())
            }
        }
        .navigationTitle("Change password")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(action: {
                    changePasswordViewModel.changePasswordRequest(password1: password1, password2: password2) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }, label: {
                    if showLoading {
                        ProgressView()
                    } else {
                       Text("Save")
                    }
                })
            }
        }
        .deprecatedScrollDismissesKeyboard()
        .alert(item: $changePasswordViewModel.alert, content: { error in
            Alert(
                title: Text(error.title),
                message: Text(error.message),
                dismissButton: .default(Text("Close"))
            )
        })
    }
}

#if DEBUG
struct ChangePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChangePasswordView()
        }
    }
}
#endif
