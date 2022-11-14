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
    @Published var isPushNotificationOn: Bool = false
    @Published var isEmailNotificationOn: Bool = false
    @Published var syncWithAppleHealth: Bool = false
    
    @Published var showEditProfileData: Bool = false
    
    @Published var showSelectAvatarOptions: Bool = false
    @Published var showSelectPhotosSheet = false
    @Published var showTakeImageSheet = false
    @Published var selectedAvatarImage = Data()
    
    func getAvatar() {
        Account.shared.getAvatar()
    }
    
    func signOut() {
        Login.shared.signOut()
    }
    
    func updateProfile() {
        Account.shared.updateProfile()
    }
    
    func uploadAvatar(image: Data) {
        Account.shared.uploadAvatar(image)
    }
    
    func saveProfileData(name: String, email: String, phone: String, birthday: Date, completion: @escaping () -> Void) {
        Account.shared.saveProfileData(name: name, email: email, phone: phone, birthday: birthday, completion: completion)
    }
    
    func toggleEditPersonalData() {
        withAnimation {
            showEditProfileData.toggle()
        }
    }
}
