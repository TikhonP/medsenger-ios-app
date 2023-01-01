//
//  Contract+DecoderRequestAsDoctor.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 06.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import CoreData

extension Contract {
    struct JsonDecoderRequestAsDoctor: Decodable {
        struct ScenarioResponse: Decodable {
            let name: String
            let description: String
            let preset: String
        }
        
        let name: String
        let patient_name: String
        let doctor_name: String
        let birthday: String
        let email: String?
        let phone: String?
        let diagnosis: String?
        let clinic: Clinic.JsonDecoderRequestAsDoctor
        let mainDoctor: String
        let startDate: String
        let endDate: String
        let contract: Int
        let number: String
        let classifier: String
        let rule: String
        let comments: String
        let photo_id: Int?
        let unanswered: Int
        let unread: Int?
        let state: String
        let archive: Bool
        let sent: Int
        let received: Int
        let short_name: String
        //        let description
        let is_online: Bool
        let video: Bool
        let agent_actions: Array<AgentAction.JsonDecoder>
        let bot_actions: Array<BotAction.JsonDecoder>
        //        let agent_params
        let agent_tasks: Array<AgentTask.JsonDecoder>
        let agents: Array<Agent.JsonDecoderRequestAsDoctor>
        let role: String
        let patient_helpers: Array<PatientHelper.JsonDecoder>
        let doctor_helpers: Array<DoctorHelper.JsonDecoder>
        let scenario: ScenarioResponse?
        let compliance: Array<Int>
        let params: Array<ContractParam.JsonDecoder>
        let activated: Bool
        let can_decline: Bool
        let has_questions: Bool
        let has_warnings: Bool
        let last_read_id: Int
        //        let related_contracts
        let is_waiting_for_conclusion: Bool
        let last_message_timestamp: TimeInterval
        
        var birthdayAsDate: Date? {
            let formatter = DateFormatter.ddMMyyyy
            return formatter.date(from: startDate)
        }
        
        var startDateAsDate: Date? {
            let formatter = DateFormatter.ddMMyyyy
            return formatter.date(from: startDate)
        }
        
        var endDateAsDate: Date? {
            let formatter = DateFormatter.ddMMyyyyAndTimeWithParentheses
            return formatter.date(from: endDate)
        }
        
        var lastMessageTimestampAsDate: Date {
            Date(timeIntervalSince1970: last_message_timestamp)
        }
    }
    
    private class func saveFromJson(_ data: JsonDecoderRequestAsDoctor, isConsilium: Bool, for moc: NSManagedObjectContext) -> Contract {
        let contract = (try? get(id: data.contract, for: moc)) ?? Contract(context: moc)

        contract.id = Int64(data.contract)
        contract.name = data.name
        contract.patientName = data.patient_name
        contract.doctorName = data.doctor_name
        contract.birthday = data.birthdayAsDate
        contract.email = data.email
        contract.phone = data.phone
        contract.mainDoctor = data.mainDoctor
        contract.startDate = data.startDateAsDate
        contract.endDate = data.endDateAsDate
        contract.number = data.number
        contract.classifier = data.classifier
        contract.rule = data.rule
        contract.comments = data.comments
        contract.unanswered = Int64(data.unanswered)
        if let unread = data.unread {
            contract.unread = Int64(unread)
        }
        if let photo_id = data.photo_id {
            contract.photoId = Int64(photo_id)
        }
        contract.stateString = data.state
        contract.archive = data.archive
        contract.sent = Int64(data.sent)
        contract.received = Int64(data.received)
        contract.shortName = data.short_name
        contract.video = data.video
        //        contract.isOnline = data.is_online
        contract.role = data.role
        contract.scenarioName = data.scenario?.name
        contract.scenarioDescription = data.scenario?.description
        contract.scenarioPreset = data.scenario?.preset
        contract.activated = data.activated
        contract.scenarioName = data.scenario?.name
        contract.scenarioDescription = data.scenario?.description
        contract.scenarioPreset = data.scenario?.preset
        contract.canDecline = data.can_decline
        contract.hasQuestions = data.has_questions
        contract.hasWarnings = data.has_warnings
        contract.lastReadMessageIdByPatient = Int64(data.last_read_id)
        contract.isWaitingForConclusion = data.is_waiting_for_conclusion
        contract.isConsilium = isConsilium
        contract.lastMessageTimestamp = data.lastMessageTimestampAsDate
        
        if let complianceAvailible = data.compliance[safe: 0] {
            contract.complianceAvailible = Int64(complianceAvailible)
        }
        if let complianceDone = data.compliance[safe: 1] {
            contract.complianceDone = Int64(complianceDone)
        }
        
        contract.sortRating = {
            var sortRating = 0
            if contract.state == .waiting {
                sortRating = 1
            }
            if contract.state == .warning {
                sortRating = 2
            }
            if contract.state == .deadlined {
                sortRating = 3
            }
            if contract.hasQuestions {
                sortRating = 4
            }
            if contract.hasWarnings {
                sortRating = 5
            }
            return Int64(sortRating)
        }()
        
        return contract
    }
    
    class func saveFromJson(_ data: [JsonDecoderRequestAsDoctor], archive: Bool, isConsilium: Bool) async throws {
        let moc = PersistenceController.shared.container.wrappedNewBackgroundContext()
        try await moc.crossVersionPerform {
            
            // Store got contracts to check if some contractes deleted later
            var gotContractIds = [Int]()
            for contractData in data {
                gotContractIds.append(contractData.contract)
                
                let contract = saveFromJson(contractData, isConsilium: isConsilium, for: moc)
                
                contract.clinic = Clinic.saveFromJson(contractData.clinic, contract: contract, for: moc)

                _ = try AgentAction.saveFromJson(contractData.agent_actions, contract: contract, for: moc)
                _ = try BotAction.saveFromJson(contractData.bot_actions, contract: contract, for: moc)
                _ = try AgentTask.saveFromJson(contractData.agent_tasks, contract: contract, for: moc)
                _ = try DoctorHelper.saveFromJson(contractData.doctor_helpers, contract: contract, for: moc)
                _ = try PatientHelper.saveFromJson(contractData.patient_helpers, contract: contract, for: moc)
                _ = try ContractParam.saveFromJson(contractData.params, contract: contract, for: moc)
            }
            
            if !gotContractIds.isEmpty {
                try cleanRemoved(validContractIds: gotContractIds, archive: archive, for: moc, isConsilium: isConsilium)
            }
            
            try moc.wrappedSave(detailsForLogging: "Contract save JsonDecoderRequestAsDoctor")
        }
    }
}
