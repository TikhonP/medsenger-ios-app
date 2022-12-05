//
//  View+hideKeyboard.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 05.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
