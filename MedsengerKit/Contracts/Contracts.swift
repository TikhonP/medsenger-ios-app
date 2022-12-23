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
    private var consiliumContractsRequestRequestAsPatient: APIRequest<ConsiliumContractsResourceRequestAsPatient>?
    private var consiliumContractsRequestRequestAsDoctor: APIRequest<ConsiliumContractsResourceRequestAsDoctor>?
    private var getImageRequests = [FileRequest]()
    
    /// Fetch user contracts
    /// - Parameter completion: Request completion
    public func fetchContracts(completion: @escaping APIRequestCompletion) {
        switch UserDefaults.userRole {
        case .patient:
            let contractsRequestAsPatientResource = ContractsRequestAsPatientResource()
            contractsRequestAsPatientRequest = APIRequest(contractsRequestAsPatientResource)
            contractsRequestAsPatientRequest?.execute { result in
                switch result {
                case .success(let data):
                    if let data = data {
                        Contract.saveFromJson(data, archive: false, isConsilium: false)
                        completion(true)
                    } else {
                        completion(false)
                    }
                case .failure(let error):
                    processRequestError(error, "get contracts request as patient")
                    completion(false)
                }
            }
        case .doctor:
            let contractsRequestAsDoctorResource = ContractsRequestAsDoctorResource()
            contractsRequestAsDoctorRequest = APIRequest(contractsRequestAsDoctorResource)
            contractsRequestAsDoctorRequest?.execute { result in
                switch result {
                case .success(let data):
                    if let data = data {
                        Contract.saveFromJson(data, archive: false, isConsilium: false)
                        completion(true)
                    } else {
                        completion(false)
                    }
                case .failure(let error):
                    processRequestError(error, "get contracts request as doctor")
                    completion(false)
                }
            }
        case .unknown:
            Contracts.logger.error("Failed to fetch contracts: User role unknown")
            completion(false)
        }
    }
    
    /// Fetch archive contracts for user
    /// - Parameter completion: Request completion
    public func fetchArchiveContracts(completion: @escaping APIRequestCompletion) {
        switch UserDefaults.userRole {
        case .patient:
            let contractsArchiveRequestAsPatientResource = ContractsArchiveRequestAsPatientResource()
            contractsArchiveRequestAsPatientRequest = APIRequest(contractsArchiveRequestAsPatientResource)
            contractsArchiveRequestAsPatientRequest?.execute { result in
                switch result {
                case .success(let data):
                    if let data = data {
                        Contract.saveFromJson(data, archive: true, isConsilium: false)
                        completion(true)
                    } else {
                        completion(false)
                    }
                case .failure(let error):
                    processRequestError(error, "get contracts archive request as patient")
                    completion(false)
                }
            }
        case .doctor:
            let contractsArchiveRequestAsDoctorResource = ContractsArchiveRequestAsDoctorResource()
            contractsArchiveRequestAsDoctorRequest = APIRequest(contractsArchiveRequestAsDoctorResource)
            contractsArchiveRequestAsDoctorRequest?.execute { result in
                switch result {
                case .success(let data):
                    if let data = data {
                        Contract.saveFromJson(data, archive: true, isConsilium: false)
                        completion(true)
                    } else {
                        completion(false)
                    }
                case .failure(let error):
                    processRequestError(error, "get contracts archive request as doctor")
                    completion(false)
                }
            }
        case .unknown:
            Contracts.logger.error("Failed to fetch archive contracts: User role unknown")
            completion(false)
        }
    }
    
    /// Fetch helper contracts
    public func fetchConsiliumContracts() {
        switch UserDefaults.userRole {
        case .patient:
            let consiliumContractsResource = ConsiliumContractsResourceRequestAsPatient()
            consiliumContractsRequestRequestAsPatient = APIRequest(consiliumContractsResource)
            consiliumContractsRequestRequestAsPatient?.execute { result in
                switch result {
                case .success(let data):
                    if let data = data {
                        Contract.saveFromJson(data, archive: false, isConsilium: true)
                    }
                case .failure(let error):
                    processRequestError(error, "get consilium contracts request")
                }
            }
        case .doctor:
            let consiliumContractsResource = ConsiliumContractsResourceRequestAsDoctor()
            consiliumContractsRequestRequestAsDoctor = APIRequest(consiliumContractsResource)
            consiliumContractsRequestRequestAsDoctor?.execute { result in
                switch result {
                case .success(let data):
                    if let data = data {
                        Contract.saveFromJson(data, archive: false, isConsilium: true)
                    }
                case .failure(let error):
                    processRequestError(error, "get consilium contracts request")
                }
            }
        case .unknown:
            Contracts.logger.error("Failed to fetch consilium contracts: User role unknown")
        }
    }
    
    /// Fetch avatar for contract
    /// - Parameter contractId: Contract Id
    public func fetchContractAvatar(_ contractId: Int) {
        if let contract = Contract.get(id: contractId), contract.isConsilium {
            let getDoctorAvatarRequest = FileRequest(path: "/patients/\(contractId)/photo")
            getDoctorAvatarRequest.execute { result in
                switch result {
                case .success(let data):
                    if let data = data {
                        Contract.saveAvatar(id: contractId, image: data, type: .doctor)
                    }
                case .failure(let error):
                    processRequestError(error, "get doctors contract avatar")
                }
            }
            let getPatientsAvatarRequest = FileRequest(path: "/doctors/\(contractId)/photo")
            getPatientsAvatarRequest.execute { result in
                switch result {
                case .success(let data):
                    if let data = data {
                        Contract.saveAvatar(id: contractId, image: data, type: .patient)
                    }
                case .failure(let error):
                    processRequestError(error, "get patients contract avatar")
                }
            }
            getImageRequests.append(getDoctorAvatarRequest)
            getImageRequests.append(getPatientsAvatarRequest)
        } else {
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
    }
    
    /// Fetch logo image for clinic
    /// - Parameter contractId: Contract Id
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
