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
            Text("ChooseRoleView.chooseRoleLabel", comment: "Your account has access to both the doctor and the patient role.")
                .multilineTextAlignment(.center)
                .font(.callout)
                .padding(.horizontal, 30)
            
            Text("ChooseRoleView.chooseRoleQuestion", comment: "How do you want to sign in?")
                .multilineTextAlignment(.center)
                .font(.callout)
                .padding(.horizontal, 30)

            Button("ChooseRoleView.SignInAsPatient.Button") { Account.shared.changeRole(.patient) }
                .font(.headline)
                .foregroundColor(Color(UIColor.systemBackground))
                .padding(.vertical)
                .frame(width: 250)
                .background(Color.accentColor)
                .clipShape(Capsule())
            
            Button("ChooseRoleView.SignInAsDoctor.Button") { Account.shared.changeRole(.doctor) }
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
