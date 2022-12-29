//
//  SettingsView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 26.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var user: User
    @StateObject private var settingsViewModel = SettingsViewModel()
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.clear.alert(item: $settingsViewModel.alert) { $0.alert }
                if settingsViewModel.showEditProfileData {
                    EditPersonalDataView(user: user)
                } else {
                    SettingsMainFormView(presentationMode: presentationMode, user: user)
                        .onAppear {
                            Task {
                                await settingsViewModel.updateProfile(presentFailedAlert: false)
                            }
                            PushNotifications.onChatsViewAppear()
                        }
                        .navigationTitle("SettingsView.NavigationTitle")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("SettingsView.Done.Button") {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                            
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("SettingsView.Edit.Button", action: { settingsViewModel.showEditProfileData.toggle()
                                })
                            }
                        }
                }
            }
            .animation(.default, value: settingsViewModel.showEditProfileData)
        }
        .environmentObject(settingsViewModel)
    }
}

#if DEBUG
//struct SettingsView_Previews: PreviewProvider {
//    struct SettingsView_PreviewsContainer: View {
//        var body: some View {
//            SettingsView()
//        }
//    }
//
//    static var previews: some View {
//        let context = PersistenceController.preview.container.viewContext
//        return SettingsView_PreviewsContainer()
//            .environment(\.managedObjectContext, context)
//    }
//}
#endif
