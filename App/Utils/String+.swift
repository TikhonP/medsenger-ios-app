//
//  String+.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 07.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation

// Store allowed character set for reuse (computed lazily).
private let urlAllowed: CharacterSet =
    .alphanumerics.union(.init(charactersIn: "-._~")) // as per RFC 3986

extension String {
    var urlEncoded: String? {
        return addingPercentEncoding(withAllowedCharacters: urlAllowed)
    }
}
