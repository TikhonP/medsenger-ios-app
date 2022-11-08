//
//  Contracts.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 03.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

class Contracts {
    static let shared = Contracts()
    
    private var getDoctorsRequest: APIRequest<DoctorsResource>?
    private var getDoctorsArchiveRequest: APIRequest<DoctorsArchiveResource>?
    private var getAvatarRequests = [ImageRequest]()
    
    public func getDoctors() {
        let doctorsResourse = DoctorsResource()
        getDoctorsRequest = APIRequest(resource: doctorsResourse)
        getDoctorsRequest?.execute { result in
            switch result {
            case .success:
                break
            case .SuccessData(let data):
                Contract.saveContractsFromJson(data: data, archive: false)
            case .Error(let error):
                processRequestError(error, "get contracts doctors")
            }
        }
    }
    
    public func getDoctorsArchive() {
        let doctorsArchiveResource = DoctorsArchiveResource()
        getDoctorsArchiveRequest = APIRequest(resource: doctorsArchiveResource)
        getDoctorsArchiveRequest?.execute { result in
            switch result {
            case .success:
                break
            case .SuccessData(let data):
                Contract.saveContractsFromJson(data: data, archive: true)
            case .Error(let error):
                processRequestError(error, "get contracts doctors archive")
            }
        }
    }
    
    public func getAndSaveDoctorAvatar(_ contractId: Int) {
        let getAvatarRequest = ImageRequest(path: "/doctors/\(contractId)/photo")
        getAvatarRequests.append(getAvatarRequest)
        getAvatarRequest.execute { result in
            switch result {
            case .success:
                break
            case .SuccessData(let data):
                Contract.saveAvatar(id: contractId, image: data)
            case .Error(let error):
                processRequestError(error, "get doctor avatar")
            }
        }
    }
}
