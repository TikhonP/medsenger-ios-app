//
//  ChangePasswordView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 13.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct ChangePasswordView: View {
    @StateObject var settingsViewModel = SettingsViewModel()
    
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var password1: String = ""
    @State private var password2: String = ""
    
    
    
    var body: some View {
        Form {
            Section(footer: Text("Password length can be 8 10")) {
                SecureField("New password", text: $password1)
            }
            
            Section {
                SecureField("Repeat password", text: $password2)
            }
        }
        .navigationTitle("Edit personal data")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}

struct ChangePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChangePasswordView()
        }
    }
}
