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
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: Contracts.self)
    )
    
    /// Fetch user contracts
    public static func fetchContracts() async throws {
        switch UserDefaults.userRole {
        case .patient:
            let contractsRequestAsPatientResource = ContractsRequestAsPatientResource()
            do {
                let data = try await APIRequest(contractsRequestAsPatientResource).executeWithResult()
                try await Contract.saveFromJson(data, archive: false, isConsilium: false)
            } catch {
                throw await processRequestError(error, "get contracts request as patient", apiErrors: contractsRequestAsPatientResource.apiErrors)
            }
        case .doctor:
            let contractsRequestAsDoctorResource = ContractsRequestAsDoctorResource()
            do {
                let data = try await APIRequest(contractsRequestAsDoctorResource).executeWithResult()
                try await Contract.saveFromJson(data, archive: false, isConsilium: false)
            } catch {
                throw await processRequestError(error, "get contracts request as doctor", apiErrors: contractsRequestAsDoctorResource.apiErrors)
            }
        case .unknown:
            Contracts.logger.error("Failed to fetch contracts: User role unknown")
        }
    }
    
    /// Fetch archive contracts for user
    public static func fetchArchiveContracts() async throws {
        switch UserDefaults.userRole {
        case .patient:
            let contractsArchiveRequestAsPatientResource = ContractsArchiveRequestAsPatientResource()
            do {
                let data = try await APIRequest(contractsArchiveRequestAsPatientResource).executeWithResult()
                try await Contract.saveFromJson(data, archive: true, isConsilium: false)
            } catch {
                throw await processRequestError(error, "get contracts archive request as patient", apiErrors: contractsArchiveRequestAsPatientResource.apiErrors)
            }
        case .doctor:
            let contractsArchiveRequestAsDoctorResource = ContractsArchiveRequestAsDoctorResource()
            do {
                let data = try await APIRequest(contractsArchiveRequestAsDoctorResource).executeWithResult()
                try await Contract.saveFromJson(data, archive: true, isConsilium: false)
            } catch {
                throw await processRequestError(error, "get contracts archive request as doctor", apiErrors: contractsArchiveRequestAsDoctorResource.apiErrors)
            }
        case .unknown:
            Contracts.logger.error("Failed to fetch archive contracts: User role unknown")
        }
    }
    
    /// Fetch helper contracts
    public static func fetchConsiliumContracts() async throws {
        switch UserDefaults.userRole {
        case .patient:
            let consiliumContractsResource = ConsiliumContractsResourceRequestAsPatient()
            do {
                let data = try await APIRequest(consiliumContractsResource).executeWithResult()
                try await Contract.saveFromJson(data, archive: false, isConsilium: true)
            } catch {
                throw await processRequestError(error, "get consilium contracts request as patient", apiErrors: consiliumContractsResource.apiErrors)
            }
        case .doctor:
            let consiliumContractsResource = ConsiliumContractsResourceRequestAsDoctor()
            do {
                let data = try await APIRequest(consiliumContractsResource).executeWithResult()
                try await Contract.saveFromJson(data, archive: false, isConsilium: true)
            } catch {
                throw await processRequestError(error, "get consilium contracts request as doctor", apiErrors: consiliumContractsResource.apiErrors)
            }
        case .unknown:
            Contracts.logger.error("Failed to fetch consilium contracts: User role unknown")
        }
    }
    
    /// Fetch avatar for contract
    /// - Parameter contractId: Contract Id
    public static func fetchContractAvatar(_ contractId: Int) async throws {
        let contract = try? await Contract.get(id: contractId)
        let isConsilium = await MainActor.run {
            contract?.isConsilium
        }
        if let isConsilium = isConsilium, isConsilium {
            async let doctorAvatarRequest = FileRequest(path: "/patients/\(contractId)/photo").executeWithResult()
            async let patientavatarRequest = FileRequest(path: "/doctors/\(contractId)/photo").executeWithResult()
            do {
                let (doctorAvatar, patientAvatar) = await (try doctorAvatarRequest, try patientavatarRequest)
                _ = await (
                    try Contract.saveAvatar(id: contractId, image: doctorAvatar, type: .doctor),
                    try Contract.saveAvatar(id: contractId, image: patientAvatar, type: .patient)
                )
            } catch {
                throw await processRequestError(error, "get consilium contract avatars")
            }
        } else {
            do {
                let data = try await FileRequest(path: "/\(UserDefaults.userRole.clientsForNetworkRequest)/\(contractId)/photo").executeWithResult()
                try await Contract.saveAvatar(id: contractId, image: data)
            } catch {
                throw await processRequestError(error, "get contract avatar")
            }
        }
    }
    
    /// Fetch logo image for clinic
    public static func fetchClinicLogo(contractId: Int, clinicId: Int) async throws {
        do {
            let data = try await FileRequest(path: "/\(contractId)/logo").executeWithResult()
            try await Clinic.saveLogo(id: clinicId, image: data)
        } catch {
            throw await processRequestError(error, "get clinic logo")
        }
    }
}
