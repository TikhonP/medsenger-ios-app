//
//  LocalizedString+.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 26.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI
import os.log

extension LocalizedStringKey {
    var stringKey: String? {
        Mirror(reflecting: self).children.first(where: { $0.label == "key" })?.value as? String
    }
}

extension String {
    static func localizedString(for key: String, locale: Locale = .current) -> String {
        let language = locale.languageCode
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj") else {
//            Logger.defaultLogger.error("Failed to load localized string for key: \(key): Bundle path is nil")
            return "Failed to load localized string"
        }
        guard let bundle = Bundle(path: path)  else {
//            Logger.defaultLogger.error("Failed to load localized string for key: \(key): Failed to create bundle from path")
            return "Failed to load localized string"
        }
        let localizedString = NSLocalizedString(key, bundle: bundle, comment: "")
        return localizedString
    }
}

extension LocalizedStringKey {
    func stringValue(locale: Locale = .current) -> String {
        return .localizedString(for: stringKey!, locale: locale)
    }
}
