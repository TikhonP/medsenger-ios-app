//
//  View+refreshableIos15Only.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 14.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

@available(iOS 15.0, *)
fileprivate struct RefreshableIos15OnlyModifier: ViewModifier {
    let action: @Sendable () async -> Void

    func body(content: Content) -> some View {
        content.refreshable(action: action)
    }
    
}

extension View {
    @ViewBuilder
    func refreshableIos15Only(action: @escaping @Sendable () async -> Void) -> some View {
        if #available(iOS 15.0, *) {
            self.modifier(RefreshableIos15OnlyModifier(action: action))
        } else {
            self
        }
    }
}
