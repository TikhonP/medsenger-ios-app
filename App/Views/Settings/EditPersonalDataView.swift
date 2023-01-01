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
    @ObservedObject private var user: User
    @EnvironmentObject private var settingsViewModel: SettingsViewModel
    
    @State private var name: String
    @State private var email: String
    @State private var phone: String
    @State private var birthday: Date
    
    init(user: User) {
        _name = State(initialValue: user.wrappedName)
        _email = State(initialValue: user.wrappedEmail)
        _phone = State(initialValue: user.wrappedPhone)
        _birthday = State(initialValue: user.birthday ?? Date())
        self.user = user
    }
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Spacer()
                    VStack {
                        SettingsProfileImageView(user: user)
                        Button("EditPersonalDataView.newPhotoButton") {
                            settingsViewModel.showSelectAvatarOptions.toggle()
                        }
                    }
                    Spacer()
                }
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
            
            Section(footer: Text("EditPersonalDataView.nameAndBirthDayFooter", comment: "Write your name and select a photo")) {
                DatePicker("EditPersonalDataView.BirthdayDatePicker", selection: $birthday, displayedComponents: [.date])
                TextField("EditPersonalDataView.nameTextFieldPlaceholder", text: $name)
                    .disableAutocorrection(true)
                    .textContentType(.name)
            }
            
            Section(footer: Text("EditPersonalDataView.emailFooter", comment: "Email is the main identifier for your account and an address for sending notifications")) {
                TextField("EditPersonalDataView.emailTextFieldPlaceholder", text: $email)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
            }
            
            Section(footer: Text("EditPersonalDataView.phoneFooter", comment: "Phone is optional")) {
                TextField("EditPersonalDataView.phoneTextFieldPlaceholder", text: $phone)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textContentType(.telephoneNumber)
                    .keyboardType(.phonePad)
            }
        }
        .navigationTitle("EditPersonalDataView.navigationTitle")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("EditPersonalDataView.navigationCancelButton", action: {
                    settingsViewModel.showEditProfileData.toggle()
                })
            }
            
            ToolbarItem(placement: .confirmationAction) {
                if editPersonalDataViewModel.showLoading {
                    ProgressView()
                } else {
                    Button("EditPersonalDataView.navigationSaveButton", action: {
                        Task(priority: .userInitiated) {
                            try await editPersonalDataViewModel.saveProfileData(name: name, email: email, phone: phone, birthday: birthday)
                            settingsViewModel.showEditProfileData.toggle()
                        }
                    })
                }
            }
        }
        .scrollDismissesKeyboardIos16Only()
        .alert(item: $editPersonalDataViewModel.alert) { $0.alert }
    }
}

#if DEBUG
//struct EditPersonalDataView_Previews: PreviewProvider {
//    static let persistence = PersistenceController.preview
//    
//    static var user: User = {
//        let context = persistence.container.viewContext
//        return User.createSampleUser(for: context)
//    }()
//    
//    static var previews: some View {
//        NavigationView {
//            EditPersonalDataView(user: user)
//                .environmentObject(SettingsViewModel())
//        }
//    }
//}
#endif
