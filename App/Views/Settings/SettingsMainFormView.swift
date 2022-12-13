//
//  SettingsMainFormView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 09.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct SettingsProfileImageView: View {
    @ObservedObject var user: User
    
    @State private var showAvatarImage = false
    
    var body: some View {
        ZStack {
            if let avatarData = user.avatar {
                Image(data: avatarData)?
                    .resizable()
                    .onTapGesture {
                        showAvatarImage = true
                    }
                    .fullScreenCover(isPresented: $showAvatarImage) {
                        FullscreenImagePreview(imageData: avatarData)
                    }
            } else {
                ProgressView()
            }
        }
        .frame(width: 95, height: 95)
        .clipShape(Circle())
    }
}

struct SettingsProfileTextView: View {
    @ObservedObject var user: User
    
    var body: some View {
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

struct SettingsSyncWithAppleHealthSectionView: View {
    @ObservedObject var healthKitSync: HealthKitSync
    
    @EnvironmentObject private var settingsViewModel: SettingsViewModel
    
    var body: some View {
        Section(header: Text("Apple Health")) {
            Toggle(isOn: $settingsViewModel.isHealthKitSyncActive) {
                Text("Apple Health Sync")
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
}

struct SettingsMainFormView: View {
    var presentationMode: Binding<PresentationMode>
    
    @ObservedObject var user: User
    
    @EnvironmentObject private var settingsViewModel: SettingsViewModel
    
    @StateObject private var healthKitSync = HealthKitSync.shared
    @StateObject private var settingsMainFormViewModel = SettingsMainFormViewModel()
    
    @AppStorage(UserDefaults.Keys.userRoleKey) private var userRole: UserRole = UserDefaults.userRole
    
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Spacer()
                    VStack {
                        SettingsProfileImageView(user: user)
                        SettingsProfileTextView(user: user)
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
                    Label("Change Profile Photo", systemImage: "camera")
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
            
            Section(footer: Text("Your account has access to both the doctor and the user role. How do you want to sign in?")) {
                NavigationLink(destination: {
                    ChangePasswordView()
                }, label: {
                    Label("Change password", systemImage: "person.badge.key")
                })
            }
            
            Section(header: Text("Notifications"), footer: Text("Push notifications can inform you about new message on your phone")) {
                Toggle(isOn: $settingsMainFormViewModel.isEmailNotificationOn, label: {
                    HStack {
                        Label("Email Notifications", systemImage: "envelope.badge")
                        if settingsMainFormViewModel.showEmailNotificationUpdateRequestLoading {
                            ProgressView()
                                .padding(.leading)
                        }
                    }
                })
                .onChange(of: settingsMainFormViewModel.isEmailNotificationOn, perform: settingsMainFormViewModel.updateEmailNotifications)
                .onChange(of: user.emailNotifications, perform: { value in
                    settingsMainFormViewModel.isEmailNotificationOn = value
                })
                
                Toggle(isOn: $settingsMainFormViewModel.isPushNotificationOn, label: {
                    HStack {
                        Label("Push Notifications", systemImage: "bell.badge")
                        if settingsMainFormViewModel.showPushNotificationUpdateRequestLoading {
                            ProgressView()
                                .padding(.leading)
                        }
                    }
                })
                .onChange(of: settingsMainFormViewModel.isPushNotificationOn, perform: settingsMainFormViewModel.updatePushNotifications)
            }
            .alert(item: $settingsMainFormViewModel.alert, content: { error in
                Alert(
                    title: Text(error.title),
                    message: Text(error.message),
                    dismissButton: .default(Text("Close"))
                )
            })
            
            if user.isPatient && user.isDoctor {
                Section(footer: Text("Your account has access to both the doctor and the patient role.")) {
                    if userRole == .patient {
                        Button("Switch to Doctor", action: {
                            Account.shared.changeRole(.doctor)
                            presentationMode.wrappedValue.dismiss()
                        })
                    } else if userRole == .doctor {
                        Button("Switch to Patient", action: {
                            Account.shared.changeRole(.patient)
                            presentationMode.wrappedValue.dismiss()
                        })
                    }
                }
            }
            
            if userRole == .patient && healthKitSync.isHealthDataAvailable {
                SettingsSyncWithAppleHealthSectionView(healthKitSync: healthKitSync)
            }
            
            Section(header: Text("About"), footer: Text("The medsenger.ru service connects the patient and their doctor. Doctors use it to consult and monitor their patients, answering questions as they come.")) {
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
                    HStack {
                        Spacer()
                        Text("Sign Out")
                            .foregroundColor(.red)
                        Spacer()
                    }
                })
            }
        }
    }
}

//struct SettingsMainFormView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingsMainFormView()
//    }
//}
