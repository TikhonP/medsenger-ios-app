//
//  DoctorActions.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 02.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

/// Actions requests for doctor
final class DoctorActions {
    static let shared = DoctorActions()
    
    private var findUserRequest: APIRequest<FindUserResource>?
    private var addContractRequest: APIRequest<AddContractResource>?
    private var deactivateMessagesRequest: APIRequest<DeactivateMessagesResource>?
    private var concludeContractRequest: APIRequest<ConcludeContractResource>?
    private var deviceStateRequest: APIRequest<DeviceResource>?
    
    /// Check if user exists in Medseger when adding contract
    /// - Parameters:
    ///   - clinicId: Clinic Id where search user
    ///   - email: User email
    ///   - completion: Request completion
    public func findUser(clinicId: Int, email: String, completion: @escaping (_ result: FindUserResource.Model?, _ contractExist: Bool) -> Void) {
        let findUserResource = FindUserResource(clinicId: clinicId, email: email)
        findUserRequest = APIRequest(findUserResource)
        findUserRequest?.execute{ result in
            switch result {
            case .success(let data):
                completion(data, false)
            case .failure(let error):
                switch error {
                case .api(let errorResponse, _):
                    if errorResponse.errors.contains("Contract exists") {
                        completion(nil, true)
                    } else {
                        completion(nil, false)
                        processRequestError(error, "DoctorActions.findUser")
                    }
                default:
                    completion(nil, false)
                    processRequestError(error, "DoctorActions.findUser")
                }
            }
        }
    }
    
    /// Add contract
    /// - Parameters:
    ///   - addContractRequestModel: Contract data
    ///   - completion: Request completion
    public func addContract(_ addContractRequestModel: AddContractRequestModel, completion: @escaping (_ succeeded: Bool) -> Void) {
        let addContractResource = AddContractResource(addContractRequestModel: addContractRequestModel)
        addContractRequest = APIRequest(addContractResource)
        addContractRequest?.execute { result in
            switch result {
            case .success(_):
                completion(true)
            case .failure(let error):
                processRequestError(error, "DoctorActions: addContract")
                completion(false)
            }
        }
    }
    
    /// Deactivate unread messages for doctor
    /// - Parameters:
    ///   - contractId: Contract Id
    ///   - completion: Request completion
    public func deactivateMessages(_ contractId: Int, completion: (() -> Void)? = nil) {
        let deactivateMessagesResource = DeactivateMessagesResource(contractId: contractId)
        deactivateMessagesRequest = APIRequest(deactivateMessagesResource)
        deactivateMessagesRequest?.execute { result in
            switch result {
            case .success(_):
                if let completion = completion {
                    completion()
                }
            case .failure(let error):
                processRequestError(error, "DoctorActions: deactivateMessages")
            }
        }
    }
    
    /// Conclude Archive contract
    /// - Parameters:
    ///   - contractId: Contract Id
    ///   - completion: Request completion
    public func concludeContract(_ contractId: Int, completion: (() -> Void)? = nil) {
        let concludeContract = ConcludeContractResource(contractId: contractId)
        concludeContractRequest = APIRequest(concludeContract)
        concludeContractRequest?.execute { result in
            switch result {
            case .success(_):
                if let completion = completion {
                    completion()
                }
            case .failure(let error):
                processRequestError(error, "DoctorActions: concludeContract")
            }
        }
    }
    
    public func deviceState(devices: [DeviceNode], contractId: Int, completion: @escaping (_ succeeded: Bool) -> Void) {
        let deviceResource = DeviceResource(devices: devices, contractId: contractId)
        deviceStateRequest = APIRequest(deviceResource)
        deviceStateRequest?.execute { result in
            switch result {
            case .success(_):
                Contracts.shared.fetchContracts()
                completion(true)
            case .failure(let error):
                completion(false)
                processRequestError(error, "DoctorActions: deviceState")
            }
        }
    }
}
