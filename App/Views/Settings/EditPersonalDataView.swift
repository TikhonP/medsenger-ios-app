//
//  EditPersonalDataView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 27.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct EditPersonalDataView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var name: String
    @State private var email: String
    @State private var phone: String
    @State private var birthday: Date
    
    @State private var showLoading = false
    
    init(user: User) {
        _name = State(initialValue: user.name ?? "")
        _email = State(initialValue: user.email ?? "")
        _phone = State(initialValue: user.phone ?? "")
        _birthday = State(initialValue: user.birthday ?? Date())
    }
    
    var body: some View {
        HStack {
            Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
            Spacer()
            ZStack {
                if showLoading {
                    ProgressView()
                } else {
                    Button("Save") {
                        settingsViewModel.saveProfileData(name: name, email: email, phone: phone, birthday: birthday) {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
            .padding()
        }
        
        Form {
            Section {
                TextField("Name", text: $name)
                TextField("E-mail", text: $email)
                TextField("Phone", text: $phone)
                DatePicker("Birthday", selection: $birthday, displayedComponents: [.date])
            }
        }
    }
}

//struct EditPersonalDataView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditPersonalDataView()
//    }
//}
