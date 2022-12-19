//
//  Contract+DecoderRequestAsPatient.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 06.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import CoreData

extension Contract {
    struct JsonDecoderRequestAsPatient: Decodable {
        struct ScenarioResponse: Decodable {
            let name: String
            let description: String
            let preset: String
        }
        
        let name: String
        let patient_name: String
        let doctor_name: String
        let specialty: String
        let clinic: Clinic.JsonDecoderRequestAsPatient
        let mainDoctor: String
        let startDate: String
        let endDate: String
        let contract: Int
        let photo_id: Int?
        let archive: Bool
        let sent: Int
        let received: Int
        let short_name: String
        let state: Contract.State
        let number: String
        let unread: Int?
        let is_online: Bool
        let agent_actions: Array<AgentAction.JsonDecoder>
        let bot_actions: Array<BotAction.JsonDecoder>
        let agent_tasks: Array<AgentTask.JsonDecoder>
        let agents: Array<Agent.JsonDecoderRequestAsPatient>
        let role: String
        let patient_helpers: Array<PatientHelper.JsonDecoder>
        let doctor_helpers: Array<DoctorHelper.JsonDecoder>
        let compliance: Array<Int>
        let params: Array<ContractParam.JsonDecoder>
        let activated: Bool
        let info_materials: Array<InfoMaterial.JsonDecoder>?
        let can_apply: Bool
        let info_url: String?
        //    let public_attachments:
        let scenario: ScenarioResponse?
        
        var startDateAsDate: Date? {
            let formatter = DateFormatter.ddMMyyyy
            return formatter.date(from: startDate)
        }
        
        var endDateAsDate: Date? {
            let formatter = DateFormatter.ddMMyyyyAndTimeWithParentheses
            return formatter.date(from: endDate)
        }
    }
    
    private class func saveFromJson(_ data: JsonDecoderRequestAsPatient, for context: NSManagedObjectContext, isConsilium: Bool) -> Contract {
        let contract = get(id: data.contract, for: context) ?? Contract(context: context)
        
        contract.id = Int64(data.contract)
        contract.name = data.name
        contract.patientName = data.patient_name
        contract.doctorName = data.doctor_name
        contract.specialty = data.specialty
        contract.mainDoctor = data.mainDoctor
        contract.startDate = data.startDateAsDate
        contract.endDate = data.endDateAsDate
        if let photo_id = data.photo_id {
            contract.photoId = Int64(photo_id)
        }
        contract.archive = data.archive
        contract.sent = Int64(data.sent)
        contract.received = Int64(data.received)
        contract.shortName = data.short_name
        contract.number = data.number
        if let unread = data.unread {
            contract.unread = Int64(unread)
        }
        //        contract.isOnline = data.is_online
        contract.role = data.role
        contract.activated = data.activated
        contract.canApplySubmissionToContractExtension = data.can_apply
        if let urlString = data.info_url, let url = URL(string: urlString) {
            contract.infoUrl = url
        }
        contract.scenarioName = data.scenario?.name
        contract.scenarioDescription = data.scenario?.description
        contract.scenarioPreset = data.scenario?.preset
        contract.sortRating = 0
        contract.isConsilium = isConsilium
        
        return contract
    }
    
    class func saveFromJson(_ data: [JsonDecoderRequestAsPatient], archive: Bool, isConsilium: Bool = false) {
        PersistenceController.shared.container.performBackgroundTask { (context) in
            context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            
            // Store got contracts to check if some contractes deleted later
            var gotContractIds = [Int]()
            
            for contractData in data {
                gotContractIds.append(contractData.contract)
                
                let contract = saveFromJson(contractData, for: context, isConsilium: isConsilium)
                
                contract.clinic = Clinic.saveFromJson(contractData.clinic, for: context)

                Agent.saveFromJson(contractData.agents, contract: contract, for: context)
                
                _ = AgentAction.saveFromJson(contractData.agent_actions, contract: contract, for: context)
                _ = BotAction.saveFromJson(contractData.bot_actions, contract: contract, for: context)
                _ = AgentTask.saveFromJson(contractData.agent_tasks, contract: contract, for: context)
                _ = DoctorHelper.saveFromJson(contractData.doctor_helpers, contract: contract, for: context)
                _ = PatientHelper.saveFromJson(contractData.patient_helpers, contract: contract, for: context)
                _ = ContractParam.saveFromJson(contractData.params, contract: contract, for: context)
                
                if let infoMaterialsData = contractData.info_materials {
                    _ = InfoMaterial.saveFromJson(infoMaterialsData, contract: contract, for: context)
                }
            }
                                       
            if !gotContractIds.isEmpty {
                cleanRemoved(validContractIds: gotContractIds, archive: archive, for: context, isConsilium: isConsilium)
            }
            
            PersistenceController.save(for: context, detailsForLogging: "Contract save JsonDecoderRequestAsPatient")
        }
    }
}
