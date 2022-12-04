//
//  SettingsView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 26.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var settingsViewModel = SettingsViewModel()
    @StateObject private var healthKitSync = HealthKitSync.shared
    
    @Environment(\.presentationMode) private var presentationMode
    
    @FetchRequest(sortDescriptors: [], animation: .default)
    private var users: FetchedResults<User>
    
    @AppStorage(UserDefaults.Keys.userRoleKey) var userRole: UserRole = UserDefaults.userRole
    
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    var body: some View {
        NavigationView {
            if let user = users.first {
                if settingsViewModel.showEditProfileData {
                    EditPersonalDataView(user: user)
                        .transition(.opacity)
                    
                } else {
                    profileView(user)
                        .deprecatedRefreshable { await settingsViewModel.updateProfile() }
                        .transition(.opacity)
                        .onAppear(perform: settingsViewModel.updateProfile)
                        .navigationTitle("Settings")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Done") {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                            
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Edit", action: settingsViewModel.toggleEditPersonalData)
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
            ImagePicker(selectedMedia: $settingsViewModel.selectedAvatarImage, sourceType: .photoLibrary, mediaTypes: [.image], edit: true)
                .edgesIgnoringSafeArea(.all)
        }
        .fullScreenCover(isPresented: $settingsViewModel.showTakeImageSheet) {
            ImagePicker(selectedMedia: $settingsViewModel.selectedAvatarImage, sourceType: .camera, mediaTypes: [.image], edit: true)
                .edgesIgnoringSafeArea(.all)
        }
        .onChange(of: settingsViewModel.selectedAvatarImage) { newValue in
            guard let selectedMedia = newValue,
                  selectedMedia.type == .image else {
                return
            }
            settingsViewModel.uploadAvatar(image: selectedMedia)
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
                .onChange(of: settingsViewModel.isEmailNotificationOn, perform: { value in
                    settingsViewModel.updateEmailNotifications()
                })
                .onChange(of: user.emailNotifications, perform: { value in
                    settingsViewModel.isEmailNotificationOn = value
                })
                
                Toggle(isOn: $settingsViewModel.isPushNotificationOn, label: {
                    Label("Push Notifications", systemImage: "bell.badge")
                })
                .onChange(of: settingsViewModel.isPushNotificationOn, perform: { value in
                    settingsViewModel.updatePushNotifications()
                })
            }
            
            if user.isPatient && user.isDoctor {
                Section(footer: Text("You can login as doctor and as patient")) {
                    if userRole == .patient {
                        Button("Change role to doctor", action: {
                            Account.shared.changeRole(.doctor)
                        })
                    } else if userRole == .doctor {
                        Button("Change role to patient", action: {
                            Account.shared.changeRole(.patient)
                        })
                    }
                }
            }
            
            if healthKitSync.isHealthDataAvailable {
                syncWithAppleHealthSection
            }
            
            Section(header: Text("About"), footer: Text("The medsenger.ru sservice implements the exchange of messages between a patient and his doctor. With its help, doctors advise their patients, answering their questions as they come.")) {
                HStack {
                    Text("Version")
                    Spacer()
                    if let appVersion = appVersion {
                        Text(appVersion)
                    } else {
                        Text("Version not found")
                    }
                }
                Button(action: {
                    if let url = URL(string: "https://medsenger.ru") {
                        UIApplication.shared.open(url)
                    }
                }, label: {
                    Label("Website", systemImage: "network")
                })
                Button(action: {
                    let email = "support@medsenger.ru"
                    if let url = URL(string: "mailto:\(email)") {
                        UIApplication.shared.open(url)
                    }
                }, label: {
                    Label("Support", systemImage: "envelope")
                })
            }
            
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
            Toggle(isOn: $settingsViewModel.isHealthKitSyncActive) {
                Text("Sync with apple health")
            }
            .onChange(of: settingsViewModel.isHealthKitSyncActive, perform: { _ in
                settingsViewModel.updateHealthKitSync()
            })
            if settingsViewModel.isHealthKitSyncActive {
                if let stepsCount = healthKitSync.lastHealthSyncStepsCount {
                    VStack(alignment: .leading) {
                        Text("Steps")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        HStack {
                            Image(systemName: "figure.walk")
                            Text(stepsCount)
                        }
                    }
                }
            }
            if let heartRate = healthKitSync.lastHealthSyncHeartRate {
                VStack(alignment: .leading) {
                    Text("Heart Rate")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    HStack {
                        Image(systemName: "heart.fill")
                        Text(heartRate)
                    }
                }
            }
            if let oxygenSaturation = healthKitSync.lastHealthSyncOxygenSaturation {
                VStack(alignment: .leading) {
                    Text("Oxygen Saturation")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    HStack {
                        Image(systemName: "lungs.fill")
                        Text(oxygenSaturation)
                    }
                }
            }
            if let respiratoryRate = healthKitSync.lastHealthSyncRespiratoryRate {
                VStack(alignment: .leading) {
                    Text("Respiratory Rate")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    HStack {
                        Image(systemName: "bubbles.and.sparkles.fill")
                        Text(respiratoryRate)
                    }
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
            
            if let email = user.email {
                Text(email)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if let phone = user.phone {
                Text(phone)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
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
