//
//  UserDoctorContract.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 31.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import CoreData

extension UserDoctorContract {
    private static func getContract(contractId: Int, context: NSManagedObjectContext) -> UserDoctorContract? {
        do {
            let fetchRequest = UserDoctorContract.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "contract == %ld", contractId)
            let fetchedResults = try context.fetch(fetchRequest)
            if let userDoctorContract = fetchedResults.first {
                return userDoctorContract
            }
            return nil
        }
        catch {
            print("Fetch core data task failed: ", error)
            return nil
        }
    }
    
    private static func updateOrCreate(doctorContract: DoctorContract, context: NSManagedObjectContext) -> UserDoctorContract {
        let userDoctorContract = {
            guard let userDoctorContract = getContract(contractId: doctorContract.contract, context: context) else {
                return UserDoctorContract(context: context)
            }
            return userDoctorContract
        }()
        
        userDoctorContract.contract = Int64(doctorContract.contract)
        userDoctorContract.name = doctorContract.name
//        userDoctorContract.patient_name = doctorContract.patient_name
//        userDoctorContract.doctor_name = doctorContract.doctor_name
        userDoctorContract.specialty = doctorContract.specialty
        userDoctorContract.mainDoctor = doctorContract.mainDoctor
        userDoctorContract.startDate = doctorContract.startDateAsDate
        userDoctorContract.endDate = doctorContract.endDateAsDate
        if let photo_id = doctorContract.photo_id {
            userDoctorContract.photoId = Int64(photo_id)
        }
        userDoctorContract.archive = doctorContract.archive
        userDoctorContract.sent = Int64(doctorContract.sent)
        userDoctorContract.received = Int64(doctorContract.received)
        userDoctorContract.shortName = doctorContract.short_name
        userDoctorContract.number = doctorContract.number
        if let unread = doctorContract.unread {
            userDoctorContract.unread = Int64(unread)
        }
        userDoctorContract.isOnline = doctorContract.is_online
        userDoctorContract.role = doctorContract.role
        userDoctorContract.activated = doctorContract.activated
        userDoctorContract.canApplySubmissionToContractExtension = doctorContract.can_apply
        if let urlString = doctorContract.info_url, let url = URL(string: urlString) {
            userDoctorContract.infoUrl = url
        }
        userDoctorContract.scenarioName = doctorContract.scenario?.name
        userDoctorContract.scenarioDescription = doctorContract.scenario?.description
        userDoctorContract.scenarioPreset = doctorContract.scenario?.preset
        
        return userDoctorContract
    }
    
    /// Clean contract that was not got in incoming JSON from Medsenger
    /// - Parameters:
    ///   - validContractIds: The contract ids that exists in JSON from Medsenger
    ///   - context: Core Data context
    private static func cleanRemoved(validContractIds: [Int], context: NSManagedObjectContext) {
        do {
            let fetchRequest = UserDoctorContract.fetchRequest()
            let fetchedResults = try context.fetch(fetchRequest)
            for contract in fetchedResults {
                if !validContractIds.contains(Int(contract.contract)) {
                    context.delete(contract)
                }
            }
        }
        catch {
            print("Fetch core data task failed: ", error)
        }
    }
    
    class func save(doctorContracts: [DoctorContract]) {
        PersistenceController.shared.container.performBackgroundTask { (context) in
            context.reset()
            
            // Store got contracts to check if some contractes deleted later
            var gotContractIds = [Int]()
            
            for contract in doctorContracts {
                gotContractIds.append(contract.contract)
                let userDoctorContract = updateOrCreate(doctorContract: contract, context: context)
                let clinic = Clinic.saveFromContracts(contract.clinic, context: context)
                userDoctorContract.clinic = clinic
                
                PersistenceController.save(context: context)
                
                // Save Agents
                var agentsIds = [Int]()
                for agent in contract.agents {
                    let agentModel = Agent.save(agent: agent, context: context)
                    userDoctorContract.addToAgents(agentModel)
                    agentsIds.append(agent.id)
                }
                if let agents = userDoctorContract.agents {
                    for agentModel in agents {
                        if !agentsIds.contains(Int((agentModel as! Agent).medsengerId)) {
                            userDoctorContract.removeFromAgents(agentModel as! Agent)
                        }
                    }
                }
                
//                PersistenceController.save(context: context)
                
//                AgentAction.save(agentActions: contract.agent_actions, contract: userDoctorContract, context: context)
//                BotAction.save(botActions: contract.bot_actions, contract: userDoctorContract, context: context)
                
                // TODO: save agent tasks
                
//                PatientHelper.save(patientHelpers: contract.patient_helpers, contract: userDoctorContract, context: context)
//                DoctorHelper.save(doctorHelpers: contract.doctor_helpers, contract: userDoctorContract, context: context)
//                ContractParam.save(contractParams: contract.params, contract: userDoctorContract, context: context)
//                if let infoMaterials = contract.info_materials {
//                    InfoMaterial.save(infoMaterials: infoMaterials, contract: userDoctorContract, context: context)
//                }
            }
            
            if !gotContractIds.isEmpty {
                cleanRemoved(validContractIds: gotContractIds, context: context)
            }
            
            PersistenceController.save(context: context)
        }
    }
    
    class func saveAvatar(contractId: Int, image: Data) {
        PersistenceController.shared.container.performBackgroundTask { (context) in
            let userDoctorContract = getContract(contractId: contractId, context: context)
            userDoctorContract?.avatar = image
            PersistenceController.save(context: context)
        }
    }
}
