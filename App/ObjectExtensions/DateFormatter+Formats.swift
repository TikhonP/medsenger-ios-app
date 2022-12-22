//
//  DateFormatter+.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 31.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

extension DateFormatter {
    static let iso8601Full = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        return formatter
    }()
    
    static let ddMMyyyy = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()
    
    static let ddMMyyyyAndTimeWithParentheses = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy (HH:mm)"
        return formatter
    }()
    
    static let ddMMyyyyAndTime = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    static let dayOfWeekFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EE"
        return dateFormatter
    }()
    
    static let ddMMFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM"
        return dateFormatter
    }()
    
    static let ddMMYYYYFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter
    }()
    
    static let ddMMMMFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM"
        return dateFormatter
    }()
    
    static let ddMMMMyyyyFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        return dateFormatter
    }()
}
