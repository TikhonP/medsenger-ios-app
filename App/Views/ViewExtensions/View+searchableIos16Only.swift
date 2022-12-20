//
//  View+searchableIos16Only.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 15.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

@available(iOS 16.0, *)
fileprivate struct SearchableIos16OnlyModifier: ViewModifier {
    let text: Binding<String>
    let prompt: Text?

    func body(content: Content) -> some View {
        content.searchable(text: text, prompt: prompt)
    }
    
}

extension View {
    @ViewBuilder
    func searchableIos16Only(text: Binding<String>, prompt: Text? = nil) -> some View {
        if #available(iOS 16.0, *) {
            self.modifier(SearchableIos16OnlyModifier(text: text, prompt: prompt))
        } else {
            self
        }
    }
}
