//
//  SettingsView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 26.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @StateObject var settingsViewModel = SettingsViewModel()
    
    @Environment(\.presentationMode) private var presentationMode
    
    @FetchRequest(sortDescriptors: [], animation: .default)
    private var users: FetchedResults<User>
    
    var body: some View {
        NavigationView {
            if let user = users.first {
                if settingsViewModel.showEditProfileData {
                    EditPersonalDataView(user: user)
                        .transition(.opacity)
                        
                } else {
                    profileView(user)
                        .transition(.opacity)
                        .onAppear(perform: settingsViewModel.updateProfile)
                        .navigationTitle("Settings")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Edit", action: settingsViewModel.toggleEditPersonalData)
                            }
                            
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Done") {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }
                }
            } else {
                Text("Failed to fetch user")
            }
        }
        .environmentObject(settingsViewModel)
        .actionSheet(isPresented: $settingsViewModel.showSelectAvatarOptions) {
            ActionSheet(title: Text("Choose a new photo"),
                        buttons: [
                            .default(Text("Pick from library")) {
                                settingsViewModel.showSelectPhotosSheet = true
                            },
                            .default(Text("Take a photo")) {
                                settingsViewModel.showTakeImageSheet = true
                            },
                            .cancel()
                        ])
        }
        .sheet(isPresented: $settingsViewModel.showSelectPhotosSheet) {
            ImagePicker(sourceType: .photoLibrary, selectedImage: $settingsViewModel.selectedAvatarImage)
        }
        .sheet(isPresented: $settingsViewModel.showTakeImageSheet) {
            ZStack {
                Color.black
                ImagePicker(sourceType: .camera, selectedImage: $settingsViewModel.selectedAvatarImage)
                    .padding(.bottom, 40)
                    .padding(.top)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .onChange(of: settingsViewModel.selectedAvatarImage) { newValue in
            Task { settingsViewModel.uploadAvatar(image: newValue) }
        }
    }
    
    func profileView(_ user: User) -> some View {
        Form {
            Section {
                HStack {
                    Spacer()
                    VStack {
                        profileImageView(user)
                        profileTextView(user)
                    }
                    Spacer()
                }
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
            
            Section {
                Button(action: {
                    settingsViewModel.showSelectAvatarOptions.toggle()
                }, label: {
                    Label("Change photo", systemImage: "camera")
                })
            }
            
            Section {
                HStack {
                    Text("Birthday")
                    Spacer()
                    if let birthday = user.birthday {
                        Text(birthday, style: .date)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Section(footer: Text("You can change password for strong security")) {
                NavigationLink(destination: {
                    ChangePasswordView()
                }, label: {
                    Label("Change password", systemImage: "person.badge.key")
                })
            }
            
            Section(header: Text("Notifications"), footer: Text("Push messages allows you to be notify about new message in your phone")) {
                Toggle(isOn: $settingsViewModel.isEmailNotificationOn, label: {
                    Label("Email Notifications", systemImage: "envelope.badge")
                })
                Toggle(isOn: $settingsViewModel.isPushNotificationOn, label: {
                    Label("Push Notifications", systemImage: "bell.badge")
                })
            }
            
            if user.isPatient && user.isDoctor {
                Section(footer: Text("You can login as doctor and as patient")) {
                    if user.role == .patient {
                        Button("Change role to doctor", action: {
                            User.role = .doctor
                        })
                    } else if user.role == .doctor {
                        Button("Change role to patient", action: {
                            User.role = .patient
                        })
                    }
                }
            }
            
            syncWithAppleHealthSection
            
            Section {
                Button (action: settingsViewModel.signOut, label: {
                    Text("Sign out")
                        .foregroundColor(.red)
                })
            }
        }
    }
    
    var syncWithAppleHealthSection: some View {
        Section(header: Text("Apple Health")) {
            Toggle(isOn: $settingsViewModel.syncWithAppleHealth) {
                Text("Sync with apple health")
            }
            VStack(alignment: .leading) {
                Text("Steps")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                HStack {
                    Image(systemName: "figure.walk")
                    Text("33")
                }
            }
            VStack(alignment: .leading) {
                Text("Pulse")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                HStack {
                    Image(systemName: "heart.fill")
                    Text("64")
                }
            }
            VStack(alignment: .leading) {
                Text("SpO2")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                HStack {
                    Image(systemName: "lungs.fill")
                    Text("156")
                }
            }
            VStack(alignment: .leading) {
                Text("CHdd")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                HStack {
                    Image(systemName: "bubbles.and.sparkles.fill")
                    Text("1245543")
                }
            }
        }
    }
    
    func profileImageView(_ user: User) -> some View {
        ZStack {
            if let avatarData = user.avatar {
                Image(data: avatarData)?
                    .resizable()
            } else {
                ProgressView()
            }
        }
        .frame(width: 95, height: 95)
        .clipShape(Circle())
    }
    
    func profileTextView(_ user: User) -> some View {
        VStack(alignment: .center, spacing: 0) {
            Text(user.name ?? "Data reading error")
                .font(.title3)
                .bold()
                .multilineTextAlignment(.center)
            
            Text(user.email ?? "Data reading error")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Text(user.phone ?? "Data reading error")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    struct SettingsView_PreviewsContainer: View {
        @State private var showSettingsModal: Bool = true
        
        var body: some View {
            Text("Chats List")
                .sheet(isPresented: $showSettingsModal, content: {
                    SettingsView()
                })
        }
    }
    
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        return SettingsView_PreviewsContainer()
            .environment(\.managedObjectContext, context)
    }
}
