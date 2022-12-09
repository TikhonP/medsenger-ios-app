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
    
    @Environment(\.presentationMode) private var presentationMode
    
    @FetchRequest(sortDescriptors: [], animation: .default) private var users: FetchedResults<User>
    
    @State private var showSelectPhotosSheet = false
    @State private var showTakeImageSheet = false
    @State private var showFilePickerModal = false
    
    var body: some View {
        NavigationView {
            if let user = users.first {
                ZStack {
                    if settingsViewModel.showEditProfileData {
                        EditPersonalDataView(user: user)
                    } else {
                        SettingsMainFormView(presentationMode: presentationMode, user: user)
                            .deprecatedRefreshable { await settingsViewModel.updateProfile() }
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
                                    Button("Edit", action: { settingsViewModel.showEditProfileData.toggle()
                                    })
                                }
                            }
                    }
                }
                .animation(.default, value: settingsViewModel.showEditProfileData)
            } else {
                Text("Failed to fetch user")
            }
        }
        .environmentObject(settingsViewModel)
        .actionSheet(isPresented: $settingsViewModel.showSelectAvatarOptions) {
            ActionSheet(title: Text("Choose a new profile photo"),
                        buttons: [
                            .default(Text("Take Photo")) {
                                showTakeImageSheet = true
                            },
                            .default(Text("Choose Photo")) {
                                showSelectPhotosSheet = true
                            },
                            .default(Text("Browse...")) {
                                showFilePickerModal = true
                            },
                            .cancel()
                        ])
        }
        .sheet(isPresented: $showSelectPhotosSheet) {
            NewImagePicker(filter: .images, selectionLimit: 1, pickedCompletionHandler: settingsViewModel.updateAvatarFromImage)
            .edgesIgnoringSafeArea(.all)
        }
        .fullScreenCover(isPresented: $showTakeImageSheet) {
            ImagePicker(selectedMedia: $settingsViewModel.selectedAvatarImage, sourceType: .camera, mediaTypes: [.image], edit: true)
                .edgesIgnoringSafeArea(.all)
        }
        .sheet(isPresented: $showFilePickerModal) {
            FilePicker(types: [.image], allowMultiple: false, onPicked: settingsViewModel.updateAvatarFromFile)
                .edgesIgnoringSafeArea(.all)
        }
        .onChange(of: settingsViewModel.selectedAvatarImage, perform: settingsViewModel.updateAvatarFromImage)
    }
}

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    struct SettingsView_PreviewsContainer: View {
        @State private var showSettingsModal: Bool = true
        
        var body: some View {
            Text("Chats")
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
#endif
