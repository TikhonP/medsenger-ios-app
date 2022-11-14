//
//  EditPersonalDataView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 27.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct EditPersonalDataView: View {
    @EnvironmentObject private var settingsViewModel: SettingsViewModel
    
    @State private var name: String
    @State private var email: String
    @State private var phone: String
    @State private var birthday: Date
    
    @State private var showLoading = false
    
    private let avatar: Data?
    
    init(user: User) {
        _name = State(initialValue: user.name ?? "")
        _email = State(initialValue: user.email ?? "")
        _phone = State(initialValue: user.phone ?? "")
        _birthday = State(initialValue: user.birthday ?? Date())
        self.avatar = user.avatar
    }
    
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
            Section {
                HStack {
                    Spacer()
                    VStack {
                        ZStack {
                            if let avatarData = avatar {
                                Image(data: avatarData)?
                                    .resizable()
                            } else {
                                ProgressView()
                            }
                        }
                        .frame(width: 95, height: 95)
                        .clipShape(Circle())
                        Button("New photo") {
                            settingsViewModel.showSelectAvatarOptions.toggle()
                        }
                    }
                    Spacer()
                }
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
            
            Section(footer: Text("Write your name and select a photo")) {
                DatePicker("Birthday", selection: $birthday, displayedComponents: [.date])
                TextField("Name", text: $name)
                    .disableAutocorrection(true)
            }
            
            Section(footer: Text("Email is a main identificator for your account, also you can recieve notifications to these adress")) {
                TextField("E-mail", text: $email)
                //                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .textContentType(.emailAddress)
                
            }
            
            Section(footer: Text("Phone is optional value")) {
                TextField("Phone", text: $phone)
                //                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .textContentType(.telephoneNumber)
                    .keyboardType(.numberPad)
            }
        }
        .navigationTitle("Edit personal data")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel", action: settingsViewModel.toggleEditPersonalData)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                if showLoading {
                    ProgressView()
                } else {
                    Button("Save", action: {
                        showLoading = true
                        settingsViewModel.saveProfileData(name: name, email: email, phone: phone, birthday: birthday, completion: {
                            settingsViewModel.toggleEditPersonalData()
                        })
                    })
                }
            }
        }
    }
}

struct EditPersonalDataView_Previews: PreviewProvider {
    static let persistence = PersistenceController.preview
    
    static var user: User = {
        let context = persistence.container.viewContext
        return User.createSampleUser(for: context)
    }()
    
    static var previews: some View {
        NavigationView {
            EditPersonalDataView(user: user)
                .environmentObject(SettingsViewModel())
        }
    }
}
