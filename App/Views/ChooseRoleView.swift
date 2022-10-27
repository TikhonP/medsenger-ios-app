//
//  ChooseRoleView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 26.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct ChooseRoleView: View {
    var body: some View {
        VStack {
            Spacer()
            Button("Sign in as patient") { PersistenceController.setUserRole(role: UserRole.patient) }
                .padding()
            Button("Sign in as doctor") { PersistenceController.setUserRole(role: UserRole.doctor) }
                .padding()
            Spacer()
        }
    }
}

struct ChooseRoleView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseRoleView()
    }
}
