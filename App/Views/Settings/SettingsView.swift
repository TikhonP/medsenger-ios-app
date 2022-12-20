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
    
    var body: some View {
        NavigationView {
            if let user = users.first {
                ZStack {
                    if settingsViewModel.showEditProfileData {
                        EditPersonalDataView(user: user)
                    } else {
                        SettingsMainFormView(presentationMode: presentationMode, user: user)
                            .refreshableIos15Only { await settingsViewModel.updateProfile(presentFailedAlert: true) }
                            .onAppear {
                                settingsViewModel.updateProfile(presentFailedAlert: false)
                            }
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
                
                EmptyView()
                    .alert(item: $settingsViewModel.alert) { $0.alert }
            } else {
                Text("Failed to fetch user")
            }
        }
        .environmentObject(settingsViewModel)
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
