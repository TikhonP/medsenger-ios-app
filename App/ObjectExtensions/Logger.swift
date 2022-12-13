//
//  Logger.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 29.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import os.log

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!

    /// Logs the HTTP url requests
    static let urlRequest = Logger(subsystem: subsystem, category: "urlRequest")
    
    /// Logs the ``Websockets`` service
    static let websockets = Logger(subsystem: subsystem, category: "websockets")
    
    static let defaultLogger = Logger(subsystem: subsystem, category: "defaultLogger")
}
