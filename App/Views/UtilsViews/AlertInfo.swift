//
//  AlertInfo.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 08.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

protocol AlertInfo: Identifiable {
    associatedtype IdentificationType: Hashable
    
    var id: IdentificationType { get }
    var title: String { get }
    var message: String { get }
}
