//
//  SettingsViewModel.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 26.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import SwiftUI

final class SettingsViewModel: ObservableObject {
    @Published var isHealthKitSyncActive: Bool = UserDefaults.isHealthKitSyncActive
    
    @Published var showEditProfileData: Bool = false
    
    @Published var showSelectAvatarOptions = false
    @Published var selectedAvatarImage: ImagePickerMedia?
    
    func getAvatar() {
        Account.shared.fetchAvatar()
    }
    
    func signOut() {
        Login.shared.signOut()
    }
    
    func updateProfile() {
        Account.shared.updateProfile()
    }
    
    func uploadAvatar(image: ImagePickerMedia) {
        Account.shared.uploadAvatar(image)
    }
    
    func updateHealthKitSync() {
        if isHealthKitSyncActive {
            HealthKitSync.shared.authorizeHealthKit { [weak self] success in
                if success {
                    UserDefaults.isHealthKitSyncActive = true
                    HealthKitSync.shared.syncDataFromHealthKit {
                        HealthKitSync.shared.startObservingHKChanges()
                    }
                } else {
                    self?.isHealthKitSyncActive = false
                    UserDefaults.isHealthKitSyncActive = false
                }
            }
        } else {
            UserDefaults.isHealthKitSyncActive = false
        }
    }
    
    func updateAvatarFromFile(_ urls: [URL]) {
        guard let fileURL = urls.first else {
            return
        }
        do {
            if fileURL.startAccessingSecurityScopedResource() {
                let data = try Data(contentsOf: fileURL)
                fileURL.stopAccessingSecurityScopedResource()
                uploadAvatar(image: ImagePickerMedia(data: data, extention: fileURL.pathExtension, realFilename: fileURL.lastPathComponent, type: .image))
            }
        } catch {
            print("Failed to load file: \(error.localizedDescription)")
        }
    }
    
    func updateAvatarFromImage(_ selectedMedia: ImagePickerMedia?) {
        guard let selectedMedia = selectedMedia,
              selectedMedia.type == .image else {
            return
        }
        uploadAvatar(image: selectedMedia)
    }
}
