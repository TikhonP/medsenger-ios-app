//
//  ContractParam+JsonDeserializer.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 20.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData

extension ContractParam {
    struct JsonDecoder: Decodable {
        let id: Int
        let name: String
        let value: String
        let created_at: Date
        let updated_at: Date
    }
    
    private class func saveFromJson(_ data: JsonDecoder, contract: Contract, for moc: NSManagedObjectContext) -> ContractParam {
        let contractParam = (try? get(id: data.id, for: moc)) ?? ContractParam(context: moc)
        
        contractParam.id = Int64(data.id)
        contractParam.name = data.name
        contractParam.value = data.value
        contractParam.createdAt = data.created_at
        contractParam.updatedAt = data.updated_at
        contractParam.contract = contract
        
        return contractParam
    }
    
    class func saveFromJson(_ data: [JsonDecoder], contract: Contract, for moc: NSManagedObjectContext) throws -> [ContractParam] {
        
        var gotIds = [Int]()
        var contractParams = [ContractParam]()
        
        for contractParamData in data {
            let contractParam = saveFromJson(contractParamData, contract: contract, for: moc)
            
            gotIds.append(contractParamData.id)
            contractParams.append(contractParam)
        }
        
        if !gotIds.isEmpty {
            try cleanRemoved(gotIds, contract: contract, for: moc)
        }
        
        return contractParams
    }
}
