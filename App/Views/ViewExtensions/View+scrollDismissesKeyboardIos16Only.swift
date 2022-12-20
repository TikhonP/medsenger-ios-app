//
//  View+scrollDismissesKeyboardIos16Only.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 18.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

@available(iOS 16.0, *)
fileprivate struct ScrollDismissesKeyboardIos16OnlyModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.scrollDismissesKeyboard(.interactively)
    }
    
}

extension View {
    @ViewBuilder
    func scrollDismissesKeyboardIos16Only() -> some View {
        if #available(iOS 16.0, *) {
            self.scrollDismissesKeyboard(.interactively)
        } else {
            self
        }
    }
}
