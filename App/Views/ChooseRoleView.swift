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
            Button("Sign in as patient") { User.setRole(role: UserRole.patient) }
                .padding()
            Button("Sign in as doctor") { User.setRole(role: UserRole.doctor) }
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
