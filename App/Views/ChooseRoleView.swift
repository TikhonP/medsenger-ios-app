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
            Text("Your account has access to both the doctor role and the user role. How do you want to enter?")
                .multilineTextAlignment(.center)
                .font(.callout)
                .padding(.horizontal, 30)

            Button("Sign in as Patient") { Account.shared.changeRole(.patient) }
                .font(.headline)
                .foregroundColor(Color(UIColor.systemBackground))
                .padding(.vertical)
                .padding(.horizontal, 50)
                .background(Color.accentColor)
                .clipShape(Capsule())
            
            Button("Sign in as Doctor") { Account.shared.changeRole(.doctor) }
                .font(.headline)
                .foregroundColor(Color(UIColor.systemBackground))
                .padding(.vertical)
                .padding(.horizontal, 50)
                .background(Color.accentColor)
                .clipShape(Capsule())
        }
    }
}

struct ChooseRoleView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseRoleView()
    }
}
