//
//  Contract+CoreDataClass.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 08.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData

@objc(Contract)
public class Contract: NSManagedObject {
    enum State: String, Decodable {
        case noMessages = "no_messages" // FIXME: !!!
        case unread = "unread"
        case waiting = "waiting"
        case warning = "warning"
        case deadlined = "deadlined"
    }
    
    var state: State {
        guard let stateString = stateString else {
            return .noMessages
        }
        return State(rawValue: stateString) ?? .noMessages
    }
    
    class func get(id: Int, for context: NSManagedObjectContext) -> Contract? {
        let fetchRequest = Contract.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %ld", id)
        let fetchedResults = PersistenceController.fetch(fetchRequest, for: context, detailsForLogging: "Contract get by id")
        return fetchedResults?.first
    }
    
    class func get(id: Int) -> Contract? {
        let context = PersistenceController.shared.container.viewContext
        var contract: Contract?
        context.performAndWait {
            contract = get(id: id, for: context)
        }
        return contract
    }
    
    class func saveAvatar(id: Int, image: Data) {
        PersistenceController.shared.container.performBackgroundTask { (context) in
            context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            let contract = get(id: id, for: context)
            contract?.avatar = image
            PersistenceController.save(for: context, detailsForLogging: "Contract save avatar")
        }
    }
    
    class func updateOnlineStatus(id: Int, isOnline: Bool) {
        PersistenceController.shared.container.performBackgroundTask { (context) in
            context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            let contract = get(id: id, for: context)
            contract?.isOnline = isOnline
            PersistenceController.save(for: context, detailsForLogging: "Contract save online status")
        }
    }
    
    class func updateOnlineStatusFromList(_ onlineIds: [Int]) {
        PersistenceController.shared.container.performBackgroundTask { (context) in
            context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            let fetchRequest = Contract.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "archive == NO")
            guard let fetchedResults = PersistenceController.fetch(fetchRequest, for: context, detailsForLogging: "Contract fetch by archive == NO for updating online status") else {
                return
            }
            for contract in fetchedResults {
                contract.isOnline = onlineIds.contains(Int(contract.id))
            }
            PersistenceController.save(for: context, detailsForLogging: "Contract save online status")
        }
    }
    
    class func updateLastFetchedMessage(id: Int, lastFetchedMessageId: Int) {
        PersistenceController.shared.container.performBackgroundTask { (context) in
            context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            let contract = get(id: id, for: context)
            contract?.lastFetchedMessage = Message.get(id: lastFetchedMessageId, for: context)
            PersistenceController.save(for: context, detailsForLogging: "Contract save lastFetchedMessage")
        }
    }
    
    func addToAgents(_ values: [Agent], for context: NSManagedObjectContext) {
        for agent in values {
            if let isExist = agents?.contains(agent), !isExist {
                addToAgents(agent)
            }
        }
    }
    
    class func clearAllContracts() {
        PersistenceController.shared.container.performBackgroundTask { (context) in
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Contract")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try PersistenceController.shared.container.persistentStoreCoordinator.execute(deleteRequest, with: context)
                PersistenceController.save(for: context, detailsForLogging: "Contract delete all")
            } catch {
                print("Core Data failed to cleanup contracts: \(error.localizedDescription)")
            }
        }
    }
    
    /// Clean contract that was not got in incoming JSON from Medsenger
    /// - Parameters:
    ///   - validContractIds: The contract ids that exists in JSON from Medsenger
    ///   - context: Core Data context
    private class func cleanRemoved(validContractIds: [Int], archive: Bool, for context: NSManagedObjectContext) {
        let fetchRequest = Contract.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "archive == %@", NSNumber(value: archive))
        guard let fetchedResults = PersistenceController.fetch(fetchRequest, for: context, detailsForLogging: "Contract fetch by archive for removing") else {
            return
        }
        for contract in fetchedResults {
            if !validContractIds.contains(Int(contract.id)) {
                context.delete(contract)
                print("Contract removed")
            }
        }
    }
}

extension Contract {
    public var messagesArray: [Message] {
        let set = messages as? Set<Message> ?? []
        return Array(set)
    }
}

// MARK: - Contracts with Doctors

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
    
    private class func saveFromJson(_ data: JsonDecoderRequestAsPatient, for context: NSManagedObjectContext) -> Contract {
        let contract = get(id: data.contract, for: context) ?? Contract(context: context)
        
        if data.isSimilar(contract) {
            return contract
        }
        
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
        
        return contract
    }
    
    class func saveFromJson(_ data: [JsonDecoderRequestAsPatient], archive: Bool) {
        PersistenceController.shared.container.performBackgroundTask { (context) in
            context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            
            // Store got contracts to check if some contractes deleted later
            var gotContractIds = [Int]()
            
            for contractData in data {
                gotContractIds.append(contractData.contract)
                
                let contract = saveFromJson(contractData, for: context)
                
                contract.clinic = Clinic.saveFromJson(contractData.clinic, for: context)

                let agents = Agent.saveFromJson(contractData.agents, for: context)
                contract.addToAgents(NSSet(array: agents))

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
                cleanRemoved(validContractIds: gotContractIds, archive: archive, for: context)
            }
            
            PersistenceController.save(for: context, detailsForLogging: "Contract save JsonDecoderRequestAsPatient")
        }
    }
}

extension Contract.JsonDecoderRequestAsPatient {
    func isSimilar(_ contract: Contract) -> Bool {
        if contract.id != Int64(self.contract) ||
            contract.name != name ||
            contract.patientName != patient_name ||
            contract.doctorName != doctor_name ||
            contract.specialty != specialty ||
            contract.mainDoctor != mainDoctor ||
            contract.startDate != startDateAsDate ||
            contract.endDate != endDateAsDate {
            return false
        }
        
        if let photo_id = photo_id, contract.photoId != Int64(photo_id){
            return false
        }
        
        if contract.archive != archive ||
            contract.sent != Int64(sent) ||
            contract.received != Int64(received) ||
            contract.shortName != short_name ||
            contract.number != number ||
            contract.role != role ||
            contract.activated != activated ||
            contract.canApplySubmissionToContractExtension != can_apply ||
            contract.scenarioName != scenario?.name ||
            contract.scenarioDescription != scenario?.description ||
            contract.scenarioPreset != scenario?.preset {
            return false
        }
        
        if let unread = unread, contract.unread != Int64(unread) {
            return false
        }
        
        if let urlString = info_url, let url = URL(string: urlString), contract.infoUrl != url {
            return false
        }
        
        return true
    }
}

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
        let email: String
        let phone: String?
        //        let diagnosis: String? // ??
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
    }
    
    private class func saveFromJson(_ data: JsonDecoderRequestAsDoctor, for context: NSManagedObjectContext) -> Contract {
        let contract = get(id: data.contract, for: context) ?? Contract(context: context)
        
        if data.isSimilar(contract) {
            return contract
        }
        
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
    
    class func saveFromJson(_ data: [JsonDecoderRequestAsDoctor], archive: Bool) {
        PersistenceController.shared.container.performBackgroundTask { (context) in
            context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            
            // Store got contracts to check if some contractes deleted later
            var gotContractIds = [Int]()
            for contractData in data {
                gotContractIds.append(contractData.contract)
                
                let contract = saveFromJson(contractData, for: context)
                
                contract.clinic = Clinic.saveFromJson(contractData.clinic, for: context)

                let agents = Agent.saveFromJson(contractData.agents, for: context)
                contract.addToAgents(NSSet(array: agents))

                _ = AgentAction.saveFromJson(contractData.agent_actions, contract: contract, for: context)
                _ = BotAction.saveFromJson(contractData.bot_actions, contract: contract, for: context)
                _ = AgentTask.saveFromJson(contractData.agent_tasks, contract: contract, for: context)
                _ = DoctorHelper.saveFromJson(contractData.doctor_helpers, contract: contract, for: context)
                _ = PatientHelper.saveFromJson(contractData.patient_helpers, contract: contract, for: context)
                _ = ContractParam.saveFromJson(contractData.params, contract: contract, for: context)
            }
            
            if !gotContractIds.isEmpty {
                cleanRemoved(validContractIds: gotContractIds, archive: archive, for: context)
            }
            
            PersistenceController.save(for: context, detailsForLogging: "Contract save JsonDecoderRequestAsDoctor")
        }
    }
}

extension Contract.JsonDecoderRequestAsDoctor {
    func isSimilar(_ contract: Contract) -> Bool {
        if contract.id != Int64(self.contract) ||
            contract.name != name ||
            contract.patientName != patient_name ||
            contract.doctorName != doctor_name ||
            contract.birthday != birthdayAsDate ||
            contract.email != email ||
            contract.phone != phone ||
            contract.mainDoctor != mainDoctor ||
            contract.startDate != startDateAsDate ||
            contract.classifier != classifier ||
            contract.rule != rule ||
            contract.comments != comments ||
            contract.unanswered != unanswered ||
            contract.stateString != state ||
            contract.archive != archive ||
            contract.video != video ||
            contract.canDecline != can_decline ||
            contract.hasQuestions != has_questions ||
            contract.hasWarnings != has_warnings ||
            contract.lastReadMessageIdByPatient != last_read_id ||
            contract.isWaitingForConclusion != is_waiting_for_conclusion ||
            contract.endDate != endDateAsDate {
            return false
        }
        
        if let photo_id = photo_id, contract.photoId != Int64(photo_id){
            return false
        }
        
        if contract.archive != archive ||
            contract.sent != Int64(sent) ||
            contract.received != Int64(received) ||
            contract.shortName != short_name ||
            contract.number != number ||
            contract.role != role ||
            contract.activated != activated ||
            contract.scenarioName != scenario?.name ||
            contract.scenarioDescription != scenario?.description ||
            contract.scenarioPreset != scenario?.preset {
            return false
        }
        
        if let unread = unread, contract.unread != Int64(unread) {
            return false
        }
        
        return true
    }
}
