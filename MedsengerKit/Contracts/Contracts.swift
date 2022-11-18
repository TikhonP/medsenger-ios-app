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
    private var deactivateMessagesRequest: APIRequest<DeactivateMessagesResource>?
    private var concludeContractRequest: APIRequest<ConcludeContractResource>?
    private var getImageRequests = [FileRequest]()
    
    public func getDoctors() {
        let doctorsResourse = DoctorsResource()
        getDoctorsRequest = APIRequest(resource: doctorsResourse)
        getDoctorsRequest?.execute { result in
            switch result {
            case .success(let data):
                if let data = data {
                    Contract.saveContractsFromJson(data: data, archive: false)
                }
            case .failure(let error):
                processRequestError(error, "get contracts doctors")
            }
        }
    }
    
    public func getDoctorsArchive() {
        let doctorsArchiveResource = DoctorsArchiveResource()
        getDoctorsArchiveRequest = APIRequest(resource: doctorsArchiveResource)
        getDoctorsArchiveRequest?.execute { result in
            switch result {
            case .success(let data):
                if let data = data {
                    Contract.saveContractsFromJson(data: data, archive: true)
                }
            case .failure(let error):
                processRequestError(error, "get contracts doctors archive")
            }
        }
    }
    
    public func getAndSaveDoctorAvatar(_ contractId: Int) {
        let getAvatarRequest = FileRequest(path: "/doctors/\(contractId)/photo")
        getImageRequests.append(getAvatarRequest)
        getAvatarRequest.execute { result in
            switch result {
            case .success(let data):
                if let data = data {
                    Contract.saveAvatar(id: contractId, image: data)
                }
            case .failure(let error):
                processRequestError(error, "get doctor avatar")
            }
        }
    }
    
    public func deactivateMessages(_ contractId: Int) {
        let deactivateMessagesResource = DeactivateMessagesResource(contractId: contractId)
        deactivateMessagesRequest = APIRequest(resource: deactivateMessagesResource)
        deactivateMessagesRequest?.execute { result in
            switch result {
            case .success(_):
                break
            case .failure(let error):
                processRequestError(error, "save profile data")
            }
        }
    }
    
    public func concludeContract(_ contractId: Int) {
        let concludeContract = ConcludeContractResource(contractId: contractId)
        concludeContractRequest = APIRequest(resource: concludeContract)
        concludeContractRequest?.execute { result in
            switch result {
            case .success(_):
                break
            case .failure(let error):
                processRequestError(error, "save profile data")
            }
        }
    }
    
    public func getAndSaveClinicLogo(_ contractId: Int) {
        guard let contract = Contract.get(id: contractId), let clinic = contract.clinic else {
            return
        }
        let getLogoRequest = FileRequest(path: "/\(contractId)/logo")
        getImageRequests.append(getLogoRequest)
        getLogoRequest.execute { result in
            switch result {
            case .success(let data):
                if let data = data {
                    Clinic.saveLogo(id: Int(clinic.id), image: data)
                }
            case .failure(let error):
                processRequestError(error, "get clinic logo")
            }
        }
    }
}
