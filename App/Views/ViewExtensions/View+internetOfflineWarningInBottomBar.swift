//
//  View+internetOfflineWarningInBottomBar.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 09.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

extension View {
    @ViewBuilder
    func internetOfflineWarningInBottomBar(networkMonitor: NetworkConnectionMonitor) -> some View {
        self.toolbar {
            ToolbarItem(placement: .bottomBar) {
                if !networkMonitor.isConnected {
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
