//
//  ProfileDataView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 26.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI
import PhotosUI

struct ProfileDataView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    @FetchRequest(sortDescriptors: [], animation: .default)
    private var users: FetchedResults<User>
    
    @State private var showEditProfileData = false
    
    @State private var showSelectAvatarOptions = false
    @State private var showSelectPhotosSheet = false
    @State private var showTakeImageSheet = false
    
    @State private var selectedAvatarImage = Data()
    
    @State private var userRole: UserRole = .doctor
    
    var body: some View {
        if let user = users.first {
            Form {
                HStack {
                    Spacer()
                    VStack {
                        ZStack {
                            if let avatarData = user.avatar {
                                createImage(avatarData)
                            } else {
                                ProgressView()
                                    .onAppear(perform: settingsViewModel.getAvatar)
                            }
                        }
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        .shadow(radius: 10)
                        .onTapGesture { showSelectAvatarOptions.toggle() }
                        .actionSheet(isPresented: $showSelectAvatarOptions) {
                            ActionSheet(title: Text("Choose a new photo"),
                                        message: Text("Pick a photo that you like"),
                                        buttons: [
                                            .default(Text("Pick from library")) {
                                                showSelectPhotosSheet = true
                                            },
                                            .default(Text("Take a photo")) {
                                                showTakeImageSheet = true
                                            },
                                            .cancel()
                                        ])
                        }
                        .sheet(isPresented: $showSelectPhotosSheet) {
                            ImagePicker(sourceType: .photoLibrary, selectedImage: $selectedAvatarImage)
                        }
                        .sheet(isPresented: $showTakeImageSheet) {
                            ZStack {
                                Color.black
                                ImagePicker(sourceType: .camera, selectedImage: $selectedAvatarImage)
                                    .padding(.bottom, 40)
                                    .padding(.top)
                            }
                            .edgesIgnoringSafeArea(.bottom)
                        }
                        .onChange(of: selectedAvatarImage) { newValue in
                            Task { settingsViewModel.uploadAvatar(image: newValue) }
                        }
                        
                        Text(user.name ?? "Data reading error")
                            .bold()
                            .font(.title)
                        Text(user.birthday!, style: .date)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                
                Section {
                    HStack {
                        Text("Email")
                        Spacer()
                        Text(user.email ?? "not specified")
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Text("Телефон")
                        Spacer()
                        Text(user.phone ?? "not specified")
                            .foregroundColor(.gray)
                    }
                    Button("Edit personal data") { showEditProfileData.toggle() }
                        .sheet(isPresented: $showEditProfileData) {
                            EditPersonalDataView(user: user)
                        }
                }
                
                if user.isPatient && user.isDoctor {
                    Section {
                        Picker("Role", selection: $userRole) {
                            Text("Patient").tag(UserRole.patient)
                            Text("Doctor").tag(UserRole.doctor)
                        }
                    }
                    .onAppear { userRole = UserRole(rawValue: user.role!) ?? .patient }
                    .onChange(of: userRole) { newValue in User.setRole(role: newValue) }
                }
                
                Section {
                    Button (action: settingsViewModel.signOut, label: {
                        Text("Sign out")
                            .bold()
                    })
                }
            }
        }
    }
    
    func createImage(_ value: Data) -> Image {
#if canImport(UIKit)
        let songArtwork: UIImage = UIImage(data: value) ?? UIImage()
        return Image(uiImage: songArtwork)
#elseif canImport(AppKit)
        let songArtwork: NSImage = NSImage(data: value) ?? NSImage()
        return Image(nsImage: songArtwork)
#else
        return Image(systemImage: "some_default")
#endif
    }
}

//struct ProfileDataView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfileDataView()
//    }
//}
