//
//  ContractParam+CoreDataClass.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 09.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData

@objc(ContractParam)
public class ContractParam: NSManagedObject {
    private class func get(id: Int, for context: NSManagedObjectContext) -> ContractParam? {
        let fetchRequest = ContractParam.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "id == %ld", id)
        let fetchedResults = PersistenceController.fetch(fetchRequest, for: context, detailsForLogging: "ContractParam get by id")
        return fetchedResults?.first
    }
}

extension ContractParam {
    struct JsonDecoder: Decodable {
        let id: Int
        let name: String
        let value: String
        let created_at: Date
        let updated_at: Date
    }
    
    private class func cleanRemoved(validIds: [Int], contract: Contract, for context: NSManagedObjectContext) {
        let fetchRequest = ContractParam.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "contract = %@", contract)
        guard let fetchedResults = PersistenceController.fetch(fetchRequest, for: context, detailsForLogging: "ContractParam fetch by contract for removing") else {
            return
        }
        for contractParam in fetchedResults {
            if !validIds.contains(Int(contractParam.id)) {
                context.delete(contractParam)
            }
        }
    }
    
    private class func saveFromJson(_ data: JsonDecoder, contract: Contract, for context: NSManagedObjectContext) -> ContractParam {
        let contractParam = get(id: data.id, for: context) ?? ContractParam(context: context)
        
        contractParam.id = Int64(data.id)
        contractParam.name = data.name
        contractParam.value = data.value
        contractParam.createdAt = data.created_at
        contractParam.updatedAt = data.updated_at
        contractParam.contract = contract
        
        return contractParam
    }
    
    class func saveFromJson(_ data: [JsonDecoder], contract: Contract, for context: NSManagedObjectContext) -> [ContractParam] {
        
        var gotIds = [Int]()
        var contractParams = [ContractParam]()
        
        for contractParamData in data {
            let contractParam = saveFromJson(contractParamData, contract: contract, for: context)
            
            gotIds.append(contractParamData.id)
            contractParams.append(contractParam)
        }
        
        if !gotIds.isEmpty {
            cleanRemoved(validIds: gotIds, contract: contract, for: context)
        }
        
        return contractParams
    }
}
