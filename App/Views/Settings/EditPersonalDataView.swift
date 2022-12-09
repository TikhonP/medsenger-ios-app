//
//  EditPersonalDataView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 27.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct EditPersonalDataView: View {
    @StateObject private var editPersonalDataViewModel = EditPersonalDataViewModel()
    
    @EnvironmentObject private var settingsViewModel: SettingsViewModel
    
    @State private var name: String
    @State private var email: String
    @State private var phone: String
    @State private var birthday: Date
    
    private let avatar: Data?
    
    init(user: User) {
        _name = State(initialValue: user.name ?? "")
        _email = State(initialValue: user.email ?? "")
        _phone = State(initialValue: user.phone ?? "")
        _birthday = State(initialValue: user.birthday ?? Date())
        self.avatar = user.avatar
    }
    
    var body: some View {
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
                        Button("New Photo") {
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
                    .textContentType(.name)
            }
            
            Section(footer: Text("Email is the main identifier for your account and an address for sending notifications")) {
                TextField("Email", text: $email)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
            }
            
            Section(footer: Text("Phone is optional")) {
                TextField("Phone", text: $phone)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textContentType(.telephoneNumber)
                    .keyboardType(.phonePad)
            }
        }
        .navigationTitle("Edit personal data")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", action: {
                    settingsViewModel.showEditProfileData.toggle()
                })
            }
            
            ToolbarItem(placement: .confirmationAction) {
                if editPersonalDataViewModel.showLoading {
                    ProgressView()
                } else {
                    Button("Save", action: {
                        editPersonalDataViewModel.saveProfileData(name: name, email: email, phone: phone, birthday: birthday) {
                            settingsViewModel.showEditProfileData.toggle()
                        }
                    })
                }
            }
        }
        .deprecatedScrollDismissesKeyboard()
        .alert(item: $editPersonalDataViewModel.alert, content: { error in
            Alert(
                title: Text(error.title),
                message: Text(error.message),
                dismissButton: .default(Text("Close"))
            )
        })
    }
}

#if DEBUG
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
#endif
