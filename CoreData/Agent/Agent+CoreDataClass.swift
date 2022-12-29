//
//  Agent+CoreDataClass.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 08.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import CoreData

@objc(Agent)
public class Agent: NSManagedObject, CoreDataIdGetable, CoreDataErasable {
    public static func addToAgentTasks(value: AgentTask, agentID: Int, for context: NSManagedObjectContext) throws {
        let agent = try get(id: agentID, for: context)
        if let isExist = agent.agentTasks?.contains(value), !isExist {
            agent.addToAgentTasks(value)
        }
    }
}
