//
//  View+searchableIos16Only.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 15.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

extension View {
    @ViewBuilder
    func searchableIos16Only(text: Binding<String>, prompt: Text? = nil) -> some View {
        if #available(iOS 16.0, *) {
            self.searchable(text: text, prompt: prompt)
        } else {
            self
        }
    }
}
