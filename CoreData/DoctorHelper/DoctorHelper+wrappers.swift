//
//  DoctorHelper+wrappers.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 21.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

extension DoctorHelper {
    public var wrappedName: String {
        name ?? "Unknown name"
    }
    
    public var wrappedRole: String {
        role ?? "Unknown role"
    }
}
