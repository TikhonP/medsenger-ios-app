//
//  User+wrappers.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 20.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

extension User {
    var wrappedName: String {
        name ?? "Unknown name"
    }
    
    var wrappedEmail: String {
        email ?? ""
    }
    
    var wrappedPhone: String {
        phone ?? ""
    }
}

extension User {
    var firstName: String {
        String(
            wrappedName.split(separator: " ")[0]
        )
    }
}
