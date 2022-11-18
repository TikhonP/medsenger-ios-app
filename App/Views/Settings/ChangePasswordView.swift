//
//  ChangePasswordView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 13.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct ChangePasswordView: View {
    @StateObject private var settingsViewModel = SettingsViewModel()
    
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var password1: String = ""
    @State private var password2: String = ""
    
    @State private var showLoading = false
    @State private var presentAlert = false
    
    var body: some View {
        if #available(iOS 16.0, *) {
            form
                .scrollDismissesKeyboard(.interactively)
        } else {
            form
        }
    }
    
    var form: some View {
        Form {
            Section(footer: Text("Password length can be 8 10")) {
                SecureField("New password", text: $password1)
            }
            
            Section {
                SecureField("Repeat password", text: $password2)
            }
            
            Section {
                if passwordsValid {
                    Text("Password valid")
                } else {
                    Text("Password invalid")
                }
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
        }
        .navigationTitle("Edit personal data")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                if showLoading {
                    ProgressView()
                } else {
                    Button("Save") {
                        showLoading = true
                        Login.shared.changePassword(newPassword: password1, completion: { result in
                            DispatchQueue.main.async {
                                showLoading = false
                                switch result {
                                case .success:
                                    presentationMode.wrappedValue.dismiss()
                                case .unknownError:
                                    presentAlert = true
                                case .incorrectData:
                                    presentAlert = true
                                }
                            }
                        })
                    }
                    .disabled(!passwordsValid)
                }
            }
        }
        .alert(isPresented: $presentAlert) {
            Alert(title: Text("Incorrect data"), dismissButton: .default(Text("OK")))
        }
    }
    
    var passwordsValid: Bool {
        password1 == password2 && password1.count >= 6
    }
}

struct ChangePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChangePasswordView()
        }
    }
}
