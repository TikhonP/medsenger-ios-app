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
    
    private var getAvatarRequest: ImageRequest?
    private var checkRequest: APIRequest<CheckResource>?
    private var uploadAvatarRequest: UploadImageRequest<UploadAvatarResource>?
    private var updateAcountRequest: APIRequest<UpdateAccountResource>?
    
    public func setRole(_ role: User.Role) {
        User.role = role
    }
    
    public var role: User.Role {
        guard let role = User.role else {
            return User.Role.patient // FIXME: !!!
        }
        return role
    }
    
    public func getAvatar() {
        getAvatarRequest = ImageRequest(path: "/photo/")
        getAvatarRequest?.execute { result in
            switch result {
            case .success:
                break
            case .SuccessData(let data):
                User.saveAvatar(data: data)
            case .Error(let error):
                processRequestError(error, "get user avatar")
            }
        }
    }
    
    public func updateProfile() {
        let checkResource = CheckResource()
        checkRequest = APIRequest(resource: checkResource)
        checkRequest?.execute { result in
            switch result {
            case .success:
                break
            case .SuccessData(let data):
                User.saveUserFromJson(data: data)
                self.getAvatar()
            case .Error(let error):
                processRequestError(error, "get profile data")
            }
        }
    }
    
    public func uploadAvatar(_ image: Data) {
        User.saveAvatar(data: nil)
        
        let uploadAvatarResource = UploadAvatarResource(image: image)
        uploadAvatarRequest = UploadImageRequest(resource: uploadAvatarResource)
        uploadAvatarRequest?.execute { result in
            switch result {
            case .success:
                self.getAvatar()
            case .SuccessData(_):
                break
            case .Error(let error):
                processRequestError(error, "upload user avatar")
            }
        }
    }
    
    public func saveProfileData(name: String, email: String, phone: String, birthday: Date, completion: @escaping () -> Void) {
        let updateAccountResource = UpdateAccountResource(name: name, email: email, phone: phone, birthday: birthday)
        updateAcountRequest = APIRequest(resource: updateAccountResource)
        updateAcountRequest?.execute { result in
            switch result {
            case .success:
                DispatchQueue.main.async { completion() }
            case .SuccessData(_):
                break
            case .Error(let error):
                processRequestError(error, "save profile data")
            }
        }
    }
}
