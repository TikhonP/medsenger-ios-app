//
//  ContractParam.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 01.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData

extension ContractParam {
    private static func getOrCreate(medsengerId: Int, context: NSManagedObjectContext, contract: UserDoctorContract) -> ContractParam {
        do {
            let fetchRequest = ContractParam.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "medsengerId == %ld && contract = %@", medsengerId, contract)
            let fetchedResults = try context.fetch(fetchRequest)
            if let contractParam = fetchedResults.first {
                return contractParam
            }
            return ContractParam(context: context)
        }
        catch {
            print("Fetch core data task failed: ", error.localizedDescription)
            return ContractParam(context: context)
        }
    }
    
    private static func cleanRemoved(validContractParamIds: [Int], context: NSManagedObjectContext, contract: UserDoctorContract) {
        do {
            let fetchRequest = ContractParam.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "contract = %@", contract)
            let fetchedResults = try context.fetch(fetchRequest)
            for contractParam in fetchedResults {
                if !validContractParamIds.contains(Int(contractParam.medsengerId)) {
                    context.delete(contractParam)
                }
            }
        }
        catch {
            print("Fetch core data task failed: ", error.localizedDescription)
        }
    }
    
    class func save(contractParams: [ParamResponse], contract: UserDoctorContract, context: NSManagedObjectContext) {
        
        var gotContractParamIds = [Int]()
        
        for contractParam in contractParams {
            gotContractParamIds.append(contractParam.id)
            let contractParamModel = getOrCreate(medsengerId: contractParam.id, context: context, contract: contract)
            contractParamModel.medsengerId = Int64(contractParam.id)
            contractParamModel.name = contractParam.name
            contractParamModel.value = contractParam.value
            contractParamModel.createdAt = contractParam.created_at
            contractParamModel.updatedAt = contractParam.updated_at
            contractParamModel.contract = contract
        }
        
        if !gotContractParamIds.isEmpty {
            cleanRemoved(validContractParamIds: gotContractParamIds, context: context, contract: contract)
        }
        
        PersistenceController.save(context: context)
    }
}
