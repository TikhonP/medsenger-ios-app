//
//  SettingsViewModel.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 26.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

final class SettingsViewModel: ObservableObject {
    
    private var getAvatarRequest: ImageRequest?
    private var checkRequest: APIRequest<CheckResource>?
    private var uploadAvatarRequest: UploadImageRequest<UploadAvatarResource>?
    private var updateAcountRequest: APIRequest<UpdateAccountResource>?
    
    func getAvatar() {
        getAvatarRequest = ImageRequest(path: "/photo/")
        getAvatarRequest?.execute { data, errorReponse, networkRequestError in
            guard let data = data else {
                return
            }
            PersistenceController.saveUserAvatar(data: data)
        }
    }
    
    func signOut() {
        KeychainSwift.apiToken = nil
//        PersistenceController.deleteUser()
        objectWillChange.send()
    }
    
    func updateProfile() {
        let checkResource = CheckResource()
        checkRequest = APIRequest(resource: checkResource)
        checkRequest?.execute { data, errorReponse, networkRequestError in
            if let data = data {
                print(data)
                data.data.saveUser()
                self.getAvatar()
            }
            if let errorReponse = errorReponse {
                print(errorReponse)
            }
            if let networkRequestError = networkRequestError {
                print(networkRequestError)
            }
        }
    }
    
    func uploadAvatar(image: Data) {
        PersistenceController.saveUserAvatar(data: nil)
        
        let uploadAvatarResource = UploadAvatarResource(image: image)
        uploadAvatarRequest = UploadImageRequest(resource: uploadAvatarResource)
        uploadAvatarRequest?.execute { data, errorReponse, networkRequestError in
            self.getAvatar()
            
            if let errorReponse = errorReponse {
                print(errorReponse)
                return
            }
            if let networkRequestError = networkRequestError {
                print(networkRequestError)
                return
            }

        }
    }
    
    func saveProfileData(name: String, email: String, phone: String, birthday: Date, completion: @escaping () -> Void) {
        
        
        let updateAccountResource = UpdateAccountResource(name: name, email: email, phone: phone, birthday: birthday)
        updateAcountRequest = APIRequest(resource: updateAccountResource)
        updateAcountRequest?.execute { data, errorReponse, networkRequestError in
            if let errorReponse = errorReponse {
                print(errorReponse)
            }
            if let networkRequestError = networkRequestError {
                print(networkRequestError)
            }
            completion()
        }
    }
}
