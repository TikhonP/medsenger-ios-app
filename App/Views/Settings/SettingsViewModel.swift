//
//  SettingsViewModel.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 26.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

final class SettingsViewModel: ObservableObject {
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
}
