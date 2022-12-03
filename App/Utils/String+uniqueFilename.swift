//
//  String+uniqueFilename.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 03.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

extension String {
    
    /// Generates a unique string that can be used as a filename for storing data objects that need to ensure they have a unique filename. It is guranteed to be unique.
    ///
    /// - Parameter prefix: The prefix of the filename that will be added to every generated string.
    /// - Returns: A string that will consists of a prefix (if available) and a generated unique string.
    static func uniqueFilename(withPrefix prefix: String? = nil) -> String {
        let uniqueString = ProcessInfo.processInfo.globallyUniqueString
        
        if prefix != nil {
            return "\(prefix!)-\(uniqueString)"
        }
        
        return uniqueString
    }
    
}
