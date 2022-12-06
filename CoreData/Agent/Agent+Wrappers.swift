//
//  Agent+Wrappers.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 06.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

extension Agent {
    public var wrappedName: String {
        name ?? "Unknown name"
    }
    
    public var wrappedDescription: String {
        agentDescription ?? "Unknown description"
    }
}
