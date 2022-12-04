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
            Button("Sign in as patient") { Account.shared.changeRole(.patient) }
                .padding()
            Button("Sign in as doctor") { Account.shared.changeRole(.doctor) }
                .padding()
        }
    }
}

struct ChooseRoleView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseRoleView()
    }
}
