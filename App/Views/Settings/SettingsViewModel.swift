//
//  SettingsViewModel.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 26.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import SwiftUI
import os.log

@MainActor
final class SettingsViewModel: ObservableObject, Alertable {
    
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: SettingsViewModel.self)
    )
    
    @Published var isHealthKitSyncActive: Bool = UserDefaults.isHealthKitSyncActive
    
    @Published var showEditProfileData: Bool = false
    
    @Published var showSelectAvatarOptions = false
    @Published var selectedAvatarImage: ImagePickerMedia?
    
    @Published var showSelectPhotosSheet = false
    @Published var showTakeImageSheet = false
    @Published var showFilePickerModal = false
    
    @Published var alert: AlertInfo?
    
    func getAvatar() async {
        try? await Account.fetchAvatar()
    }
    
    nonisolated func signOut() async {
        try? await Login.signOut()
    }
    
    func updateProfile(presentFailedAlert: Bool) async {
        do {
            try await Account.updateProfile()
        } catch {
            if presentFailedAlert {
                presentGlobalAlert()
            }
        }
    }
    
    func uploadAvatar(image: ImagePickerMedia) async {
        do {
            try await Account.uploadAvatar(image)
        } catch {
            presentGlobalAlert()
        }
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
    
    func updateAvatarFromFile(_ urls: [URL]) async {
        guard let fileURL = urls.first else {
            return
        }
        do {
            if fileURL.startAccessingSecurityScopedResource() {
                let data = try Data(contentsOf: fileURL)
                fileURL.stopAccessingSecurityScopedResource()
                await uploadAvatar(image: ImagePickerMedia(data: data, extention: fileURL.pathExtension, realFilename: fileURL.lastPathComponent, type: .image))
            }
        } catch {
            SettingsViewModel.logger.error("Failed to load file: \(error.localizedDescription)")
        }
    }
    
    func updateAvatarFromImage(_ selectedMedia: ImagePickerMedia?) async {
        guard let selectedMedia = selectedMedia,
              selectedMedia.type == .image else {
            return
        }
        await uploadAvatar(image: selectedMedia)
    }
}
