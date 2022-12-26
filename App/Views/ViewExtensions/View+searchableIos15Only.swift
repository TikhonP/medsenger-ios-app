//
//  View+searchableIos15Only.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 15.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

@available(iOS 15.0, *)
fileprivate struct SearchableIos15OnlyModifier: ViewModifier {
    let text: Binding<String>
    let prompt: Text?

    func body(content: Content) -> some View {
        content.searchable(text: text, prompt: prompt)
    }
    
}

extension View {
    @ViewBuilder
    func searchableIos15Only(text: Binding<String>, prompt: Text? = nil) -> some View {
        if #available(iOS 15.0, *) {
            self.modifier(SearchableIos15OnlyModifier(text: text, prompt: prompt))
        } else {
            self
        }
    }
}
