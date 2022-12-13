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
            Text("Your account has access to both the doctor and the patient role.")
                .multilineTextAlignment(.center)
                .font(.callout)
                .padding(.horizontal, 30)
            
            Text("How do you want to sign in?")
                .multilineTextAlignment(.center)
                .font(.callout)
                .padding(.horizontal, 30)

            Button("Sign In as Patient") { Account.shared.changeRole(.patient) }
                .font(.headline)
                .foregroundColor(Color(UIColor.systemBackground))
                .padding(.vertical)
                .frame(width: 250)
                .background(Color.accentColor)
                .clipShape(Capsule())
            
            Button("Sign In as Doctor") { Account.shared.changeRole(.doctor) }
                .font(.headline)
                .foregroundColor(Color(UIColor.systemBackground))
                .padding(.vertical)
                .frame(width: 250)
                .background(Color.accentColor)
                .clipShape(Capsule())
        }
    }
}

#if DEBUG
struct ChooseRoleView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseRoleView()
            .environment(\.locale, .init(identifier: "ru"))
    }
}
#endif
