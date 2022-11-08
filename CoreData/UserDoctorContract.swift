//
//  UserDoctorContract.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 31.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import CoreData

//extension Contract {
//    class func save(doctorContracts: [DoctorContract]) {
//        PersistenceController.shared.container.performBackgroundTask { (context) in
//            context.reset()
//            
//            // Store got contracts to check if some contractes deleted later
//            var gotContractIds = [Int]()
//            
//            for contract in doctorContracts {
//                gotContractIds.append(contract.contract)
//                let userDoctorContract = updateOrCreate(doctorContract: contract, context: context)
//                let clinic = Clinic.saveFromContracts(contract.clinic, context: context)
//                userDoctorContract.clinic = clinic
//                
//                PersistenceController.save(context: context)
//                
//                // Save Agents
//                var agentsIds = [Int]()
//                for agent in contract.agents {
//                    let agentModel = Agent.save(agent: agent, context: context)
//                    userDoctorContract.addToAgents(agentModel)
//                    agentsIds.append(agent.id)
//                }
//                if let agents = userDoctorContract.agents {
//                    for agentModel in agents {
//                        if !agentsIds.contains(Int((agentModel as! Agent).medsengerId)) {
//                            userDoctorContract.removeFromAgents(agentModel as! Agent)
//                        }
//                    }
//                }
//                
////                PersistenceController.save(context: context)
//                
////                AgentAction.save(agentActions: contract.agent_actions, contract: userDoctorContract, context: context)
////                BotAction.save(botActions: contract.bot_actions, contract: userDoctorContract, context: context)
//                
//                // TODO: save agent tasks
//                
////                PatientHelper.save(patientHelpers: contract.patient_helpers, contract: userDoctorContract, context: context)
////                DoctorHelper.save(doctorHelpers: contract.doctor_helpers, contract: userDoctorContract, context: context)
////                ContractParam.save(contractParams: contract.params, contract: userDoctorContract, context: context)
////                if let infoMaterials = contract.info_materials {
////                    InfoMaterial.save(infoMaterials: infoMaterials, contract: userDoctorContract, context: context)
////                }
//            }
//            
//            if !gotContractIds.isEmpty {
//                cleanRemoved(validContractIds: gotContractIds, context: context)
//            }
//            
//            PersistenceController.save(context: context)
//        }
//    }
//}
