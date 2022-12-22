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
    
    /// Change user role: patient or doctor
    /// - Parameter role: The user role
    public func changeRole(_ role: UserRole) {
        DispatchQueue.global(qos: .background).async {
            PersistenceController.clearDatabase(withUser: false)
            UserDefaults.userRole = role
            PushNotifications.changeRoleFcmToken()
            ChatsViewModel.shared.getContracts(presentFailedAlert: true)
        }
    }
    
    /// Fetch user avatar image
    public func fetchAvatar() {
        getAvatarRequest = FileRequest(path: "/photo/")
        getAvatarRequest?.execute { result in
            switch result {
            case .success(let data):
                if let data = data {
                    User.saveAvatar(data)
                }
            case .failure(let error):
                processRequestError(error, "fetch user avatar")
            }
        }
    }
    
    /// Fetch user data
    /// - Parameter completion: Request completion
    public func updateProfile(completion: @escaping APIRequestCompletion) {
        let checkResource = CheckResource()
        checkRequest = APIRequest(checkResource)
        checkRequest?.execute { [weak self] result in
            switch result {
            case .success(let data):
                if let data = data {
                    User.saveUserFromJson(data)
                    self?.fetchAvatar()
                    completion(true)
                } else {
                    completion(false)
                }
            case .failure(let error):
                processRequestError(error, "get profile data")
                completion(false)
            }
        }
    }
    
    /// Update avatar image for user profile
    /// - Parameters:
    ///   - image: Image data
    ///   - completion: Request completion
    public func uploadAvatar(_ image: ImagePickerMedia, completion: @escaping APIRequestCompletion) {
        User.saveAvatar(nil)
        let uploadAvatarResource = UploadAvatarResource(image: image)
        uploadAvatarRequest = APIRequest(uploadAvatarResource)
        uploadAvatarRequest?.execute { [weak self] result in
            switch result {
            case .success(_):
                self?.fetchAvatar()
                completion(true)
            case .failure(let error):
                processRequestError(error, "upload user avatar")
                completion(false)
            }
        }
    }
    
    enum saveProfileDataStates {
        case succeess, failure, phoneExists
    }
    
    /// Update profile data
    /// - Parameters:
    ///   - name: User name
    ///   - email: User email
    ///   - phone: User phone
    ///   - birthday: User birthday
    ///   - completion: Request completion
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
    
    /// Update user email notifications state
    /// - Parameters:
    ///   - isEmailNotificationsOn: Email notifications state
    ///   - completion: Request completion
    public func updateEmailNotiofication(isEmailNotificationsOn: Bool, completion: @escaping APIRequestCompletion) {
        let notificationsResource = NotificationsResource(emailNotify: isEmailNotificationsOn)
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
    
    enum UpdatePushNotificationsAction {
        case storeToken, removeToken
    }
    
    /// Save or delete `fcmToken` from remote server
    /// - Parameters:
    ///   - fcmToken: the `fcmToken`
    ///   - action: Store or remove token from remote
    public func updatePushNotifications(fcmToken: String, action: UpdatePushNotificationsAction, completion: @escaping APIRequestCompletion) {
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
        let pushNotificationsResource = PushNotificationsResource(fcmToken: fcmToken, store: action == .storeToken)
        pushNotificationsRequest = APIRequest(pushNotificationsResource)
        pushNotificationsRequest?.execute { result in
            switch result {
            case .success(_):
                UserDefaults.isPushNotificationsOn = action == .storeToken
                completion(true)
            case .failure(let error):
                processRequestError(error, "store device push notification token")
                completion(false)
            }
        }
    }
}
