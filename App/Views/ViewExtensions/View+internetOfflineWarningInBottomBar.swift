//
//  View+internetOfflineWarningInBottomBar.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 09.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

fileprivate struct InternetOfflineWarningInBottomBarModifier: ViewModifier {
    @EnvironmentObject private var networkConnectionMonitor: NetworkConnectionMonitor
    
    func body(content: Content) -> some View {
        content.toolbar {
            ToolbarItem(placement: .bottomBar) {
                if !networkConnectionMonitor.isConnected {
                    VStack {
                        HStack {
                            Image(systemName: "wifi.exclamationmark")
                            Text("internetOfflineWarningInBottomBar.title", comment: "Internet connection not available")
                        }
                        Text("internetOfflineWarningInBottomBar.message", comment: "Turn off Airplane Mode or connect to Wi-Fi.")
                            .foregroundColor(.secondary)
                    }
                    .font(.caption)
                }
            }
        }
    }
}

extension View {
    @MainActor @ViewBuilder func internetOfflineWarningInBottomBar() -> some View {
        self.modifier(InternetOfflineWarningInBottomBarModifier())
    }
}
