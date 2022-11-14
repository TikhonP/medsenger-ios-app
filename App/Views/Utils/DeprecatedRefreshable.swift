//
//  DeprecatedRefreshable.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 13.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

extension View {
    @ViewBuilder
    func deprecatedRefreshable(action: @escaping @Sendable () async -> Void) -> some View {
        if #available(iOS 15.0, *) {
            self.refreshable(action: action)
        } else {
            self
        }
    }
}
