//
//  AgentTask+wrappers.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 21.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

extension AgentTask {
    public var wrappedText: String {
        text ?? "Unknown text"
    }
}
