//
//  Contract+CoreDataClass.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 08.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Contract)
public class Contract: NSManagedObject {
    enum State: String, Decodable {
        case noMessages = "no_messages" // FIXME: !!!
        case unread = "unread"
    }
    
    class func get(id: Int, context: NSManagedObjectContext) -> Contract? {
        do {
            let fetchRequest = Contract.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %ld", id)
            let fetchedResults = try context.fetch(fetchRequest)
            if let contract = fetchedResults.first {
                return contract
            }
            return nil
        }
        catch {
            print("Get core data `Contract` with id: \(id) failed: \(error.localizedDescription)")
            return nil
        }
    }
    
    class func saveAvatar(id: Int, image: Data) {
        PersistenceController.shared.container.performBackgroundTask { (context) in
            let contract = get(id: id, context: context)
            contract?.avatar = image
            PersistenceController.save(context: context)
        }
    }
    
    func addToAgents(_ values: [Agent], context: NSManagedObjectContext) {
        for agent in values {
            if let isExist = agents?.contains(agent), !isExist {
                addToAgents(agent)
                PersistenceController.save(context: context)
            }
        }
    }
    
    
}

// MARK: - Contracts with Doctors

extension Contract {
    struct JsonDecoderDoctor: Decodable {
        let name: String
        let patient_name: String
        let doctor_name: String
        let specialty: String
        let clinic: Clinic.JsonDecoderFromContract
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
        let agents: Array<Agent.JsonDecoder>
        let role: String
        let patient_helpers: Array<PatientHelper.JsonDecoder>
        let doctor_helpers: Array<DoctorHelper.JsonDecoder>
        let compliance: Array<Int>
        let params: Array<ParamResponse>
        let activated: Bool
        let info_materials: Array<InfoMaterialResponse>?
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
    
    private class func saveContractFromJson(data: JsonDecoderDoctor, context: NSManagedObjectContext) -> Contract {
        let contract = {
            guard let contract = get(id: data.contract, context: context) else {
                return Contract(context: context)
            }
            return contract
        }()
        
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
        contract.isOnline = data.is_online
        contract.role = data.role
        contract.activated = data.activated
        contract.canApplySubmissionToContractExtension = data.can_apply
        if let urlString = data.info_url, let url = URL(string: urlString) {
            contract.infoUrl = url
        }
        contract.scenarioName = data.scenario?.name
        contract.scenarioDescription = data.scenario?.description
        contract.scenarioPreset = data.scenario?.preset
        
        PersistenceController.save(context: context)
        
        return contract
    }
    
    /// Clean contract that was not got in incoming JSON from Medsenger
    /// - Parameters:
    ///   - validContractIds: The contract ids that exists in JSON from Medsenger
    ///   - context: Core Data context
    private class func cleanRemoved(validContractIds: [Int], archive: Bool, context: NSManagedObjectContext) {
        do {
            let fetchRequest = Contract.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "archive == %@", NSNumber(value: archive))
            let fetchedResults = try context.fetch(fetchRequest)
            for contract in fetchedResults {
                if !validContractIds.contains(Int(contract.id)) {
                    context.delete(contract)
                    PersistenceController.save(context: context)
                    print("Contract removed")
                }
            }
        }
        catch {
            print("Fetch `Contract` core data failed: \(error.localizedDescription)")
        }
    }
    
    class func saveContractsFromJson(data: [JsonDecoderDoctor], archive: Bool) {
        PersistenceController.shared.container.performBackgroundTask { (context) in
            
            // Store got contracts to check if some contractes deleted later
            var gotContractIds = [Int]()
            for contractData in data {
                gotContractIds.append(contractData.contract)
                
                let contract = saveContractFromJson(data: contractData, context: context)
                
                let clinic = Clinic.saveFromJson(data: contractData.clinic, context: context)
                if let isExist = clinic.contracts?.contains(contract), !isExist {
                    clinic.addToContracts(contract)
                }
                PersistenceController.save(context: context)

                let agents = Agent.saveFromJson(data: contractData.agents, context: context)
                contract.addToAgents(NSSet(array: agents))
                PersistenceController.save(context: context)

                let agentActions = AgentAction.saveFromJson(data: contractData.agent_actions, contract: contract, context: context)
                contract.addToAgentActions(NSSet(array: agentActions))
                PersistenceController.save(context: context)

                let botActions = BotAction.saveFromJson(data: contractData.bot_actions, contract: contract, context: context)
                contract.addToBotActions(NSSet(array: botActions))
                PersistenceController.save(context: context)
                
                let agentTasks = AgentAction.saveFromJson(data: contractData.agent_actions, contract: contract, context: context)
                contract.addToAgentTasks(NSSet(array: agentTasks))
                PersistenceController.save(context: context)
                
                let doctorHelpers = DoctorHelper.saveFromJson(data: contractData.doctor_helpers, contract: contract, context: context)
                contract.addToDoctorHelpers(NSSet(array: doctorHelpers))
                PersistenceController.save(context: context)
                
                let patientHelpers = PatientHelper.saveFromJson(data: contractData.patient_helpers, contract: contract, context: context)
                contract.addToPatientHelpers(NSSet(array: patientHelpers))
                PersistenceController.save(context: context)
            }
            
            if !gotContractIds.isEmpty {
                cleanRemoved(validContractIds: gotContractIds, archive: archive, context: context)
            }
        }
    }
}

extension Contract.JsonDecoderDoctor {
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
            contract.isOnline != is_online ||
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
