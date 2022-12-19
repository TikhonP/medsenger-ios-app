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
    static let shared = Account()
    
    private var getAvatarRequest: FileRequest?
    private var checkRequest: APIRequest<CheckResource>?
    private var uploadAvatarRequest: APIRequest<UploadAvatarResource>?
    private var updateAcountRequest: APIRequest<UpdateAccountResource>?
    private var notificationsRequest: APIRequest<NotificationsResource>?
    private var pushNotificationsRequest: APIRequest<PushNotificationsResource>?
    
    public func changeRole(_ role: UserRole) {
        DispatchQueue.global(qos: .background).async {
            PersistenceController.clearDatabase(withUser: false)
            UserDefaults.userRole = role
            if let fcmToken = UserDefaults.fcmToken {
                self.updatePushNotifications(fcmToken: fcmToken, storeOrRemove: false) { [weak self] succeeded in
                    if let fcmToken = UserDefaults.fcmToken {
                        self?.updatePushNotifications(fcmToken: fcmToken, storeOrRemove: true) { succeeded in
                            if !succeeded {
                                UserDefaults.isPushNotificationsOn = false
                            }
                        }
                    }
                }
            }
            ChatsViewModel.shared.getContracts()
        }
    }
    
    public func fetchAvatar() {
        getAvatarRequest = FileRequest(path: "/photo/")
        getAvatarRequest?.execute { result in
            switch result {
            case .success(let data):
                if let data = data {
                    User.saveAvatar(data)
                }
            case .failure(let error):
                processRequestError(error, "get user avatar")
            }
        }
    }
    
    public func updateProfile() {
        let checkResource = CheckResource()
        checkRequest = APIRequest(checkResource)
        checkRequest?.execute { [weak self] result in
            switch result {
            case .success(let data):
                if let data = data {
                    User.saveUserFromJson(data)
                    self?.fetchAvatar()
                }
            case .failure(let error):
                processRequestError(error, "get profile data")
            }
        }
    }
    
    public func uploadAvatar(_ image: ImagePickerMedia) {
        User.saveAvatar(nil)
        let uploadAvatarResource = UploadAvatarResource(image: image)
        uploadAvatarRequest = APIRequest(uploadAvatarResource)
        uploadAvatarRequest?.execute { [weak self] result in
            switch result {
            case .success(_):
                self?.fetchAvatar()
            case .failure(let error):
                processRequestError(error, "upload user avatar")
            }
        }
    }
    
    enum saveProfileDataStates {
        case succeess, failure, phoneExists
    }
    
    public func saveProfileData(name: String, email: String, phone: String, birthday: Date, completion: @escaping (_ result: saveProfileDataStates) -> Void) {
        let updateAccountResource = UpdateAccountResource(name: name, email: email, phone: phone, birthday: birthday)
        updateAcountRequest = APIRequest(updateAccountResource)
        updateAcountRequest?.execute { result in
            switch result {
            case .success(_):
                completion(.succeess)
            case .failure(let error):
                switch error {
                case .api(let errorResponse, _):
                    if errorResponse.errors.contains("Phone exists") {
                        completion(.phoneExists)
                    } else {
                        processRequestError(error, "save profile data")
                        completion(.failure)
                    }
                default:
                    processRequestError(error, "save profile data")
                    completion(.failure)
                }
            }
        }
    }
    
    public func updateEmailNotiofication(emailNotify: Bool, completion: @escaping (_ succeeded: Bool) -> Void) {
        let notificationsResource = NotificationsResource(emailNotify: emailNotify)
        notificationsRequest = APIRequest(notificationsResource)
        notificationsRequest?.execute { result in
            switch result {
            case .success(_):
                completion(true)
            case .failure(let error):
                processRequestError(error, "update email notification")
                completion(false)
            }
        }
    }
    
    /// Save or delete `fcmToken` from remote server
    /// - Parameters:
    ///   - fcmToken: the `fcmToken`
    ///   - storeOrRemove: Store or remove token from remote, if true save token, otherwise remove
    public func updatePushNotifications(fcmToken: String, storeOrRemove: Bool, completion: @escaping (_ succeeded: Bool) -> Void) {
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
        let pushNotificationsResource = PushNotificationsResource(fcmToken: fcmToken, store: storeOrRemove)
        pushNotificationsRequest = APIRequest(pushNotificationsResource)
        pushNotificationsRequest?.execute { result in
            switch result {
            case .success(_):
                UserDefaults.isPushNotificationsOn = storeOrRemove
                completion(true)
            case .failure(let error):
                processRequestError(error, "store device push notification token")
                completion(false)
            }
        }
    }
}
