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

    /// Check if user exists in Medseger when adding contract
    /// - Parameters:
    ///   - clinicId: Clinic Id where search user
    ///   - email: User email
    public static func findUser(clinicId: Int, email: String) async throws -> FindUserResource.Model {
        let findUserResource = FindUserResource(clinicId: clinicId, email: email)
        do {
            return try await APIRequest(findUserResource).executeWithResult()
        } catch {
            throw await processRequestError(error, "DoctorActions.findUser", apiErrors: findUserResource.apiErrors)
        }
    }
    
    /// Add contract
    /// - Parameters:
    ///   - addContractRequestModel: Contract data
    public static func addContract(_ addContractRequestModel: AddContractRequestModel) async throws {
        let addContractResource = AddContractResource(addContractRequestModel: addContractRequestModel)
        do {
            try await APIRequest(addContractResource).execute()
        } catch {
            throw await processRequestError(error, "DoctorActions: addContract", apiErrors: addContractResource.apiErrors)
        }
    }
    
    /// Deactivate unread messages for doctor
    /// - Parameters:
    ///   - contractId: Contract Id
    public static func deactivateMessages(_ contractId: Int) async throws {
        let deactivateMessagesResource = DeactivateMessagesResource(contractId: contractId)
        do {
            try await APIRequest(deactivateMessagesResource).execute()
        } catch {
            throw await processRequestError(error, "DoctorActions: deactivateMessages", apiErrors: deactivateMessagesResource.apiErrors)
        }
    }
    
    /// Conclude Archive contract
    /// - Parameters:
    ///   - contractId: Contract Id
    public static func concludeContract(_ contractId: Int) async throws {
        let concludeContract = ConcludeContractResource(contractId: contractId)
        do {
            try await APIRequest(concludeContract).execute()
        } catch {
            throw await processRequestError(error, "DoctorActions: concludeContract", apiErrors: concludeContract.apiErrors)
        }
    }
    
    /// Update connected devices
    /// - Parameters:
    ///   - devices: List of device node with states
    ///   - contractId: Contract Id
    public static func deviceState(devices: [DeviceNode], contractId: Int) async throws {
        let deviceResource = DeviceResource(devices: devices, contractId: contractId)
        do {
            try await APIRequest(deviceResource).execute()
            await ChatsViewModel.shared.getContracts(presentFailedAlert: false)
        } catch {
            throw await processRequestError(error, "DoctorActions: deviceState", apiErrors: deviceResource.apiErrors)
        }
    }
    
    /// Update notes for doctor with any string
    /// - Parameters:
    ///   - contractId: Contract Id
    ///   - notes: Notes string
    public static func updateContractNotes(contractId: Int, notes: String) async throws {
        let updateCommentsResource = UpdateCommentsResource(contractId: contractId, comment: notes)
        do {
            try await APIRequest(updateCommentsResource).execute()
            try await Contract.updateContractNotes(id: contractId, notes: notes)
        } catch {
            throw await processRequestError(error, "DoctorActions: updateContractNotes", apiErrors: updateCommentsResource.apiErrors)
        }
    }
    
    /// Clear scenario from contract
    /// - Parameters:
    ///   - contractId: Contract Id
    public static func removeScenario(contractId: Int) async throws {
        let removeScenarioResource = RemoveScenarioResource(contractId: contractId)
        do {
            try await APIRequest(removeScenarioResource).execute()
        } catch {
            throw await processRequestError(error, "DoctorActions: removeScenario", apiErrors: removeScenarioResource.apiErrors)
        }
    }
    
    /// Start scenario for contract
    /// - Parameters:
    ///   - contractId: Contract Id
    ///   - scenarioId: Scenario Id
    ///   - params: Scenario params, that configured when selecting scenario
    public static func addScenario(contractId: Int, scenarioId: Int, params: [ClinicScenarioParamNode]) async throws {
        let addScenarioResource = AddScenarioResource(contractId: contractId, scenarioId: scenarioId, params: params)
        do {
            try await APIRequest(addScenarioResource).execute()
        } catch {
            throw await processRequestError(error, "DoctorActions: addScenario", apiErrors: addScenarioResource.apiErrors)
        }
    }
}
