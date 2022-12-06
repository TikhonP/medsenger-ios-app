//
//  ClinicClassifier+Wrappers.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 06.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

extension ClinicClassifier {
    public var wrappedName: String {
        name ?? "Unknown name"
    }
}
