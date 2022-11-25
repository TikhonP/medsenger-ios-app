//
//  Account.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 03.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

class Account {
    static let shared = Account()
    
    private var getAvatarRequest: FileRequest?
    private var checkRequest: APIRequest<CheckResource>?
    private var uploadAvatarRequest: UploadImageRequest<UploadAvatarResource>?
    private var updateAcountRequest: APIRequest<UpdateAccountResource>?
    private var notificationsRequest: APIRequest<NotificationsResource>?
    
    public func changeRole(_ role: UserRole) {
        Contract.clearAllContracts()
        UserDefaults.userRole = role
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
        checkRequest = APIRequest(resource: checkResource)
        checkRequest?.execute { result in
            switch result {
            case .success(let data):
                if let data = data {
                    User.saveUserFromJson(data)
                    self.fetchAvatar()
                }
            case .failure(let error):
                processRequestError(error, "get profile data")
            }
        }
    }
    
    public func uploadAvatar(_ image: Data) {
        User.saveAvatar(nil)
        
        let uploadAvatarResource = UploadAvatarResource(image: image)
        uploadAvatarRequest = UploadImageRequest(resource: uploadAvatarResource)
        uploadAvatarRequest?.execute { result in
            switch result {
            case .success(_):
                self.fetchAvatar()
            case .failure(let error):
                processRequestError(error, "upload user avatar")
            }
        }
    }
    
    public func saveProfileData(name: String, email: String, phone: String, birthday: Date, completion: @escaping () -> Void) {
        let updateAccountResource = UpdateAccountResource(name: name, email: email, phone: phone, birthday: birthday)
        updateAcountRequest = APIRequest(resource: updateAccountResource)
        updateAcountRequest?.execute { result in
            switch result {
            case .success(_):
                DispatchQueue.main.async { completion() }
            case .failure(let error):
                processRequestError(error, "save profile data")
            }
        }
    }
    
    public func updateEmailNotiofication(emailNotify: Bool, completion: (() -> Void)? = nil) {
        let notificationsResource = NotificationsResource(emailNotify: emailNotify)
        notificationsRequest = APIRequest(resource: notificationsResource)
        notificationsRequest?.execute { result in
            switch result {
            case .success(_):
                if let completion = completion {
                    completion()
                }
            case .failure(let error):
                processRequestError(error, "save profile data")
            }
        }
    }
}
