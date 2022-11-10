//
//  ContractParam+CoreDataClass.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 09.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//
//

import Foundation
import CoreData

@objc(ContractParam)
public class ContractParam: NSManagedObject {
    private class func get(id: Int, contract: Contract, context: NSManagedObjectContext) -> ContractParam? {
        do {
            let fetchRequest = ContractParam.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %ld && contract = %@", id, contract)
            let fetchedResults = try context.fetch(fetchRequest)
            if let contractParam = fetchedResults.first {
                return contractParam
            }
            return nil
        } catch {
            print("Fetch `ContractParam` core data task failed: \(error.localizedDescription)")
            return nil
        }
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
    
    private class func cleanRemoved(validIds: [Int], contract: Contract, context: NSManagedObjectContext) {
        do {
            let fetchRequest = ContractParam.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "contract = %@", contract)
            let fetchedResults = try context.fetch(fetchRequest)
            for contractParam in fetchedResults {
                if !validIds.contains(Int(contractParam.id)) {
                    context.delete(contractParam)
                    PersistenceController.save(context: context)
                }
            }
        } catch {
            print("Fetch `ContractParam` core data task failed: \(error.localizedDescription)")
        }
    }
    
    private class func saveFromJson(data: JsonDecoder, contract: Contract, context: NSManagedObjectContext) -> ContractParam {
        let contractParam = {
            guard let contractParam = get(id: data.id, contract: contract, context: context) else {
                return ContractParam(context: context)
            }
            return contractParam
        }()
        
        contractParam.id = Int64(data.id)
        contractParam.name = data.name
        contractParam.value = data.value
        contractParam.createdAt = data.created_at
        contractParam.updatedAt = data.updated_at
        
        PersistenceController.save(context: context)
        
        return contractParam
    }
    
    class func saveFromJson(data: [JsonDecoder], contract: Contract, context: NSManagedObjectContext) -> [ContractParam] {
        
        var gotIds = [Int]()
        var contractParams = [ContractParam]()
        
        for contractParamData in data {
            let contractParam = saveFromJson(data: contractParamData, contract: contract, context: context)
            
            gotIds.append(contractParamData.id)
            contractParams.append(contractParam)
        }
        
        if !gotIds.isEmpty {
            cleanRemoved(validIds: gotIds, contract: contract, context: context)
        }
        
        return contractParams
    }
}
