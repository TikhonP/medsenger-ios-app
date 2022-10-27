//
//  ContentViewModel.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 24.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI
import Foundation

final class ContentViewModel: ObservableObject {
    public var account = Account()
    
    func checkIfApiTokeExists() {
        if !account.isSignedIn {
            PersistenceController.deleteUser()
        }
    }
}
