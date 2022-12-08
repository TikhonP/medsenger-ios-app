//
//  Contracts.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 03.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import os.log

class Contracts {
    static let shared = Contracts()
    
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: Contracts.self)
    )
    
    private var contractsRequestAsPatientRequest: APIRequest<ContractsRequestAsPatientResource>?
    private var contractsRequestAsDoctorRequest: APIRequest<ContractsRequestAsDoctorResource>?
    private var contractsArchiveRequestAsPatientRequest: APIRequest<ContractsArchiveRequestAsPatientResource>?
    private var contractsArchiveRequestAsDoctorRequest: APIRequest<ContractsArchiveRequestAsDoctorResource>?
    private var getImageRequests = [FileRequest]()
    
    public func fetchContracts(completion: (() -> Void)? = nil) {
        switch UserDefaults.userRole {
        case .patient:
            let contractsRequestAsPatientResource = ContractsRequestAsPatientResource()
            contractsRequestAsPatientRequest = APIRequest(contractsRequestAsPatientResource)
            contractsRequestAsPatientRequest?.execute { result in
                switch result {
                case .success(let data):
                    if let data = data {
                        Contract.saveFromJson(data, archive: false)
                        if let completion = completion {
                            completion()
                        }
                    }
                case .failure(let error):
                    processRequestError(error, "get contracts request as patient")
                }
            }
        case .doctor:
            let contractsRequestAsDoctorResource = ContractsRequestAsDoctorResource()
            contractsRequestAsDoctorRequest = APIRequest(contractsRequestAsDoctorResource)
            contractsRequestAsDoctorRequest?.execute { result in
                switch result {
                case .success(let data):
                    if let data = data {
                        Contract.saveFromJson(data, archive: false)
                        if let completion = completion {
                            completion()
                        }
                    }
                case .failure(let error):
                    processRequestError(error, "get contracts request as doctor")
                }
            }
        case .unknown:
            Contracts.logger.error("Failed to fetch contracts: User role unknown")
        }
    }
    
    public func fetchArchiveContracts(completion: (() -> Void)? = nil) {
        switch UserDefaults.userRole {
        case .patient:
            let contractsArchiveRequestAsPatientResource = ContractsArchiveRequestAsPatientResource()
            contractsArchiveRequestAsPatientRequest = APIRequest(contractsArchiveRequestAsPatientResource)
            contractsArchiveRequestAsPatientRequest?.execute { result in
                switch result {
                case .success(let data):
                    if let data = data {
                        Contract.saveFromJson(data, archive: true)
                        if let completion = completion {
                            completion()
                        }
                    }
                case .failure(let error):
                    processRequestError(error, "get contracts archive request as patient")
                }
            }
        case .doctor:
            let contractsArchiveRequestAsDoctorResource = ContractsArchiveRequestAsDoctorResource()
            contractsArchiveRequestAsDoctorRequest = APIRequest(contractsArchiveRequestAsDoctorResource)
            contractsArchiveRequestAsDoctorRequest?.execute { result in
                switch result {
                case .success(let data):
                    if let data = data {
                        Contract.saveFromJson(data, archive: true)
                        if let completion = completion {
                            completion()
                        }
                    }
                case .failure(let error):
                    processRequestError(error, "get contracts archive request as doctor")
                }
            }
        case .unknown:
            Contracts.logger.error("Failed to fetch archive contracts: User role unknown")
        }
    }
    
    public func fetchContractAvatar(_ contractId: Int) {
        let getAvatarRequest = FileRequest(path: "/\(UserDefaults.userRole.clientsForNetworkRequest)/\(contractId)/photo")
        getImageRequests.append(getAvatarRequest)
        getAvatarRequest.execute { result in
            switch result {
            case .success(let data):
                if let data = data {
                    Contract.saveAvatar(id: contractId, image: data)
                }
            case .failure(let error):
                processRequestError(error, "get contract avatar")
            }
        }
    }
    
    public func fetchClinicLogo(_ contractId: Int) {
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
