//
//  ContractParam+wrappers.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 20.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

extension ContractParam {
    public var wrappedName: String {
        name ?? "Unknown name"
    }
    
    public var wrappedValue: String {
        value ?? "Unknown value"
    }
}
