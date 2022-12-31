//
//  Account.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 03.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import UIKit

class Account {
    
    /// Fetch user avatar image
    public static func fetchAvatar() async throws {
        do {
            let data = try await FileRequest(path: "/photo/").executeWithResult()
            try await User.saveAvatar(data)
        } catch {
            throw await processRequestError(error, "fetch user avatar")
        }
    }
    
    /// Fetch user data
    public static func updateProfile() async throws {
        let checkResource = CheckResource()
        do {
            let data = try await APIRequest(checkResource).executeWithResult()
            try await User.saveUserFromJson(data)
            try await fetchAvatar()
        } catch {
            throw await processRequestError(error, "get profile data", apiErrors: checkResource.apiErrors)
        }
    }
    
    /// Update avatar image for user profile
    /// - Parameters:
    ///   - image: Image data
    public static func uploadAvatar(_ image: ImagePickerMedia) async throws {
        try await User.saveAvatar(nil)
        let uploadAvatarResource = UploadAvatarResource(image: image)
        do {
            try await APIRequest(uploadAvatarResource).execute()
            try await fetchAvatar()
        } catch {
            throw await processRequestError(error, "get profile data", apiErrors: uploadAvatarResource.apiErrors)
        }
    }
    
    
    
    /// Update profile data
    /// - Parameters:
    ///   - name: User name
    ///   - email: User email
    ///   - phone: User phone
    ///   - birthday: User birthday
    public static func saveProfileData(name: String, email: String, phone: String, birthday: Date) async throws {
        let updateAccountResource = UpdateAccountResource(name: name, email: email, phone: phone, birthday: birthday)
        do {
            try await APIRequest(updateAccountResource).execute()
        } catch {
            throw await processRequestError(error, "save profile data", apiErrors: updateAccountResource.apiErrors)
        }
    }
    
    /// Update user email notifications state
    /// - Parameters:
    ///   - isEmailNotificationsOn: Email notifications state
    public static func updateEmailNotiofication(isEmailNotificationsOn: Bool) async throws {
        let notificationsResource = NotificationsResource(emailNotify: isEmailNotificationsOn)
        do {
            try await APIRequest(notificationsResource).execute()
        } catch {
            throw await processRequestError(error, "update email notification", apiErrors: notificationsResource.apiErrors)
        }
    }
    
    enum UpdatePushNotificationsAction {
        case storeToken, removeToken
    }
    
    /// Save or delete `fcmToken` from remote server
    /// - Parameters:
    ///   - fcmToken: the `fcmToken`
    public static func updatePushNotifications(fcmToken: String, action: UpdatePushNotificationsAction) async throws {
        await MainActor.run {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
        let pushNotificationsResource = PushNotificationsResource(fcmToken: fcmToken, store: action == .storeToken)
        do {
            try await APIRequest(pushNotificationsResource).execute()
            UserDefaults.isPushNotificationsOn = action == .storeToken
        } catch {
            throw await processRequestError(error, "store device push notification token", apiErrors: pushNotificationsResource.apiErrors)
        }
    }
}
