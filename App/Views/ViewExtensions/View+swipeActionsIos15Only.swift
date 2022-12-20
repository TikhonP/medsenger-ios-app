//
//  View+swipeActionsIos15Only.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 20.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import SwiftUI

extension View {
    @ViewBuilder
    func swipeActionsIos15Only<T>(allowsFullSwipe: Bool = true, content: () -> T) -> some View where T : View {
        if #available(iOS 15.0, *) {
            self.swipeActions(allowsFullSwipe: allowsFullSwipe, content: content)
        } else {
            self
        }
    }
}
