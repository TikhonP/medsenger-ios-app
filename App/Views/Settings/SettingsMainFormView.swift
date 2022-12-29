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
    @EnvironmentObject private var settingsViewModel: SettingsViewModel
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
        .actionSheet(isPresented: $settingsViewModel.showSelectAvatarOptions) {
            ActionSheet(title: Text("SettingsProfileImageView.chooseNewProfilePhotoAlertTitle", comment: "Choose a new profile photo"),
                        buttons: [
                            .default(Text("SettingsProfileImageView.takePhotoButton", comment: "Take Photo")) {
                                settingsViewModel.showTakeImageSheet = true
                            },
                            .default(Text("SettingsProfileImageView.choosePhotoButton", comment: "Choose Photo")) {
                                settingsViewModel.showSelectPhotosSheet = true
                            },
                            .default(Text("SettingsProfileImageView.browseButton", comment: "Browse...")) {
                                settingsViewModel.showFilePickerModal = true
                            },
                            .cancel()
                        ])
        }
        .sheet(isPresented: $settingsViewModel.showSelectPhotosSheet) {
            NewImagePicker(filter: .images, selectionLimit: 1, pickedCompletionHandler: { media in
                Task {
                    await settingsViewModel.updateAvatarFromImage(media)
                }
            })
            .edgesIgnoringSafeArea(.all)
        }
        .fullScreenCover(isPresented: $settingsViewModel.showTakeImageSheet) {
            ImagePicker(selectedMedia: $settingsViewModel.selectedAvatarImage, sourceType: .camera, mediaTypes: [.image], edit: true)
                .edgesIgnoringSafeArea(.all)
        }
        .sheet(isPresented: $settingsViewModel.showFilePickerModal) {
            FilePicker(types: [.image], allowMultiple: false, onPicked: { media in
                Task {
                    await settingsViewModel.updateAvatarFromFile(media)
                }
            })
            .edgesIgnoringSafeArea(.all)
        }
        .onChange(of: settingsViewModel.selectedAvatarImage, perform: { newValue in
            Task {
                await settingsViewModel.updateAvatarFromImage(newValue)
            }
        })
    }
}

struct SettingsProfileTextView: View {
    @ObservedObject var user: User
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text(user.wrappedName)
                .font(.title3)
                .bold()
                .multilineTextAlignment(.center)
            
            if !user.wrappedEmail.isEmpty {
                Text(user.wrappedEmail)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if !user.wrappedPhone.isEmpty {
                Text(user.wrappedPhone)
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
        Section(header: Text("SettingsSyncWithAppleHealthSectionView.appleHealthHeader", comment: "Apple Health")) {
            Toggle(isOn: $settingsViewModel.isHealthKitSyncActive) {
                Text("SettingsSyncWithAppleHealthSectionView.appleHealthSyncToggle", comment: "Apple Health Sync")
            }
            .onChange(of: settingsViewModel.isHealthKitSyncActive, perform: { _ in
                settingsViewModel.updateHealthKitSync()
            })
            if settingsViewModel.isHealthKitSyncActive {
                if let stepsCount = healthKitSync.lastHealthSyncStepsCount {
                    VStack(alignment: .leading) {
                        Text("SettingsSyncWithAppleHealthSectionView.steps", comment: "Steps")
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
                    Text("SettingsSyncWithAppleHealthSectionView.heartRate", comment: "Heart Rate")
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
                    Text("SettingsSyncWithAppleHealthSectionView.oxygenSaturation", comment: "Oxygen Saturation")
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
                    Text("SettingsSyncWithAppleHealthSectionView.respiratoryRate", comment: "Respiratory Rate")
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
    @StateObject private var settingsMainFormViewModel: SettingsMainFormViewModel
    
    @AppStorage(UserDefaults.Keys.userRoleKey) private var userRole: UserRole = UserDefaults.userRole
    @AppStorage(UserDefaults.Keys.showFullPreviewForImagesKey) private var showFullPreviewForImages: Bool = UserDefaults.showFullPreviewForImages
    @AppStorage(UserDefaults.Keys.isPushNotificationsOnKey) private var isPushNotificationsOn: Bool = UserDefaults.isPushNotificationsOn
    
    @State private var showAppBuild = false
    @State private var showSignout = false
    
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    private let appBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    
    init(presentationMode: Binding<PresentationMode>, user: User) {
        self.presentationMode = presentationMode
        self.user = user
        _settingsMainFormViewModel = StateObject(wrappedValue: SettingsMainFormViewModel(isEmailNotificationOn: user.emailNotifications))
    }
    
    var body: some View {
        Form {
            profileSection
            tokeAvartarOhotoSection
            birthdaySection
            changePasswordActionSecction
            notificationsSection
                .alert(item: $settingsMainFormViewModel.alert) { $0.alert }
            
            if user.isPatient && user.isDoctor {
                changeRoleSection
            }
            
            showFullImageSecction
            
            if userRole == .patient && healthKitSync.isHealthDataAvailable {
                SettingsSyncWithAppleHealthSectionView(healthKitSync: healthKitSync)
            }
            
            aboutSection
            signOutActionSection
        }
        .refreshableIos15Only { await settingsViewModel.updateProfile(presentFailedAlert: true) }
    }
    
    var profileSection: some View {
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
    }
    
    var tokeAvartarOhotoSection: some View {
        Section {
            Button(action: {
                settingsViewModel.showSelectAvatarOptions.toggle()
            }, label: {
                Label("SettingsMainFormView.changeProfilePhotoLabel", systemImage: "camera")
            })
        }
    }
    
    var birthdaySection: some View {
        Section {
            HStack {
                Text("SettingsMainFormView.birthday", comment: "Birthday")
                Spacer()
                if let birthday = user.birthday {
                    Text(birthday, style: .date)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    var changePasswordActionSecction: some View {
        Section(footer: Text("SettingsMainFormView.changePasswordFooter", comment: "Change your password for strong security")) {
            NavigationLink(destination: {
                ChangePasswordView()
            }, label: {
                Label("SettingsMainFormView.changePasswordLabel", systemImage: "person.badge.key")
            })
        }
    }
    
    var notificationsSection: some View {
        Section(
            header: Text("SettingsMainFormView.notificationHeader", comment: "Notifications"),
            footer: Text("SettingsMainFormView.notificationFooter", comment: "Push notifications can inform you about new message on your phone")) {
                Toggle(isOn: $settingsMainFormViewModel.isEmailNotificationOn, label: {
                    HStack {
                        Label("SettingsMainFormView.emailNotificationsLabel", systemImage: "envelope.badge")
                        if settingsMainFormViewModel.showEmailNotificationUpdateRequestLoading {
                            ProgressView()
                                .padding(.leading)
                        }
                    }
                })
                .onChange(of: settingsMainFormViewModel.isEmailNotificationOn) { newValue in
                    Task {
                        await settingsMainFormViewModel.updateEmailNotifications(newValue)
                    }
                }
                .onChange(of: user.emailNotifications, perform: { value in
                    settingsMainFormViewModel.isEmailNotificationOn = value
                })
                
                Toggle(isOn: $isPushNotificationsOn, label: {
                    HStack {
                        Label("SettingsMainFormView.pushNotificationsLabel", systemImage: "bell.badge")
                        if settingsMainFormViewModel.showPushNotificationUpdateRequestLoading {
                            ProgressView()
                                .padding(.leading)
                        }
                    }
                })
                .onTapGesture {
                    settingsMainFormViewModel.updatePushNotifications(!isPushNotificationsOn)
                }
            }
    }
    
    var changeRoleSection: some View {
        Section(footer: Text("SettingsMainFormView.changeRoleFooter", comment: "Your account has access to both the doctor and the patient role.")) {
            if settingsMainFormViewModel.showChangeRoleLoading {
                ProgressView()
            } else if userRole == .patient {
                Button("SettingsMainFormView.switchToDoctorButtonLabel", action: {
                    Task {
                        await settingsMainFormViewModel.changeRole(.doctor)
                        await MainActor.run { presentationMode.wrappedValue.dismiss() }
                    }
                })
            } else if userRole == .doctor {
                Button("SettingsMainFormView.switchToPatientButtonLabel", action: {
                    Task {
                        await settingsMainFormViewModel.changeRole(.patient)
                        await MainActor.run { presentationMode.wrappedValue.dismiss() }
                    }
                })
            }
        }
        .animation(.default, value: settingsMainFormViewModel.showChangeRoleLoading)
        .animation(.default, value: userRole)
    }
    
    var showFullImageSecction: some View {
        Section(footer: Text("SettingsMainFormView.showFullPreviewForImages.Footer")) {
            Toggle(isOn: $showFullPreviewForImages, label: {
                Text("SettingsMainFormView.showFullPreviewForImages.Toggle", comment: "Show large image preview")
            })
        }
    }
    
    var aboutSection: some View {
        Section(
            header: Text("SettingsMainFormView.aboutHeader", comment: "About"),
            footer: Text("SettingsMainFormView.aboutFooter", comment: "The medsenger.ru service connects the patient and their doctor. Doctors use it to consult and monitor their patients, answering questions as they come.")) {
                HStack {
                    Text("SettingsMainFormView.version", comment: "Version")
                    Spacer()
                    if let appVersion = appVersion {
                        HStack {
                            Text(appVersion)
                            if showAppBuild {
                                if let appBuild = appBuild {
                                    Text("(\(appBuild))")
                                        .foregroundColor(.secondary)
                                } else {
                                    Text("SettingsMainFormView.buildNotFound", comment: "(Build not found)")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .onTapGesture {
                            withAnimation {
                                showAppBuild.toggle()
                            }
                        }
                    } else {
                        Text("SettingsMainFormView.versionNotFound", comment: "Version not found")
                    }
                }
                Button(action: {
                    if let url = URL(string: "https://medsenger.ru") {
                        UIApplication.shared.open(url)
                    }
                }, label: {
                    Label("SettingsMainFormView.websiteLabel", systemImage: "network")
                })
                Button(action: {
                    let email = "support@medsenger.ru"
                    if let url = URL(string: "mailto:\(email)") {
                        UIApplication.shared.open(url)
                    }
                }, label: {
                    Label("SettingsMainFormView.supportLabel", systemImage: "envelope")
                })
            }
    }
    
    var signOutActionSection: some View {
        Section {
            Button (action: {
                showSignout.toggle()
            }, label: {
                HStack {
                    Spacer()
                    Text("SettingsMainFormView.signOutButton", comment: "Sign Out")
                        .foregroundColor(.red)
                    Spacer()
                }
            })
            .actionSheet(isPresented: $showSignout, content: {
                ActionSheet(title: Text("SettingsMainFormView.signOutConfirmationActionSheetTitle"),
                            buttons: [
                                .destructive(Text("SettingsMainFormView.signOutButton"), action: {
                                    Task {
                                        await settingsViewModel.signOut()
                                    }
                                }),
                                .cancel()
                            ]
                )
            })
        }
    }
}

//struct SettingsMainFormView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingsMainFormView()
//    }
//}
