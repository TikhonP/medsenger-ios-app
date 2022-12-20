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
    private var updateCommentsRequest: APIRequest<UpdateCommentsResource>?
    private var removeScenarioRequest: APIRequest<RemoveScenarioResource>?
    private var addScenarioRequest: APIRequest<AddScenarioResource>?
    
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
    public func addContract(_ addContractRequestModel: AddContractRequestModel, completion: @escaping APIRequestCompletion) {
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
    public func deactivateMessages(_ contractId: Int, completion: @escaping APIRequestCompletion) {
        let deactivateMessagesResource = DeactivateMessagesResource(contractId: contractId)
        deactivateMessagesRequest = APIRequest(deactivateMessagesResource)
        deactivateMessagesRequest?.execute { result in
            switch result {
            case .success(_):
                completion(true)
            case .failure(let error):
                completion(false)
                processRequestError(error, "DoctorActions: deactivateMessages")
            }
        }
    }
    
    /// Conclude Archive contract
    /// - Parameters:
    ///   - contractId: Contract Id
    ///   - completion: Request completion
    public func concludeContract(_ contractId: Int, completion: @escaping APIRequestCompletion) {
        let concludeContract = ConcludeContractResource(contractId: contractId)
        concludeContractRequest = APIRequest(concludeContract)
        concludeContractRequest?.execute { result in
            switch result {
            case .success(_):
                completion(true)
            case .failure(let error):
                completion(false)
                processRequestError(error, "DoctorActions: concludeContract")
            }
        }
    }
    
    /// Update connected devices
    /// - Parameters:
    ///   - devices: List of device node with states
    ///   - contractId: Contract Id
    ///   - completion: Request completion
    public func deviceState(devices: [DeviceNode], contractId: Int, completion: @escaping APIRequestCompletion) {
        let deviceResource = DeviceResource(devices: devices, contractId: contractId)
        deviceStateRequest = APIRequest(deviceResource)
        deviceStateRequest?.execute { result in
            switch result {
            case .success(_):
                ChatsViewModel.shared.getContracts(presentFailedAlert: false)
                completion(true)
            case .failure(let error):
                completion(false)
                processRequestError(error, "DoctorActions: deviceState")
            }
        }
    }
    
    /// Update notes for doctor with any string
    /// - Parameters:
    ///   - contractId: Contract Id
    ///   - notes: Notes string
    ///   - completion: Request completion
    public func updateContractNotes(contractId: Int, notes: String, completion: @escaping APIRequestCompletion) {
        let updateCommentsResource = UpdateCommentsResource(contractId: contractId, comment: notes)
        updateCommentsRequest = APIRequest(updateCommentsResource)
        updateCommentsRequest?.execute { result in
            switch result {
            case .success(_):
                Contract.updateContractNotes(id: contractId, notes: notes)
                completion(true)
            case .failure(let error):
                completion(false)
                processRequestError(error, "DoctorActions: updateContractNotes")
            }
        }
    }
    
    /// Clear scenario from contract
    /// - Parameters:
    ///   - contractId: Contract Id
    ///   - completion: Request completion
    public func removeScenario(contractId: Int, completion: @escaping APIRequestCompletion) {
        let removeScenarioResource = RemoveScenarioResource(contractId: contractId)
        removeScenarioRequest = APIRequest(removeScenarioResource)
        removeScenarioRequest?.execute { result in
            switch result {
            case .success(_):
                completion(true)
            case .failure(let error):
                completion(false)
                processRequestError(error, "DoctorActions: removeScenario")
            }
        }
    }
    
    /// Start scenario for contract
    /// - Parameters:
    ///   - contractId: Contract Id
    ///   - scenarioId: Scenario Id
    ///   - params: Scenario params, that configured when selecting scenario
    ///   - completion: Request completion
    public func addScenario(contractId: Int, scenarioId: Int, params: [ClinicScenarioParamNode], completion: @escaping APIRequestCompletion) {
        let addScenarioResource = AddScenarioResource(contractId: contractId, scenarioId: scenarioId, params: params)
        addScenarioRequest = APIRequest(addScenarioResource)
        addScenarioRequest?.execute { result in
            switch result {
            case .success(_):
                completion(true)
            case .failure(let error):
                completion(false)
                processRequestError(error, "DoctorActions: addScenario")
            }
        }
    }
}
