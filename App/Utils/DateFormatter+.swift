//
//  DateFormatter+.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 31.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

extension DateFormatter {
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        return formatter
    }()
    
    static let ddMMyyyy: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.calendar = Calendar(identifier: .iso8601)
        return formatter
    }()
    
    static let ddMMyyyyAndTimeWithParentheses: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy (HH:mm)"
        formatter.calendar = Calendar(identifier: .iso8601)
        return formatter
    }()
    
    static let ddMMyyyyAndTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.calendar = Calendar(identifier: .iso8601)
        return formatter
    }()
}
