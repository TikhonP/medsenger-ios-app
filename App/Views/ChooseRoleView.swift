//
//  ChooseRoleView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 26.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct ChooseRoleView: View {
    @MainActor @State private var showLoading = false
    
    var body: some View {
        VStack {
            Text("ChooseRoleView.chooseRoleLabel", comment: "Your account has access to both the doctor and the patient role.")
                .multilineTextAlignment(.center)
                .font(.callout)
                .padding(.horizontal, 30)
            
            if showLoading {
                ProgressView()
                    .padding()
            } else {
                Text("ChooseRoleView.chooseRoleQuestion", comment: "How do you want to sign in?")
                    .multilineTextAlignment(.center)
                    .font(.callout)
                    .padding(.horizontal, 30)
                
                Button("ChooseRoleView.SignInAsPatient.Button") {
                    Task(priority: .userInitiated) {
                        showLoading = true
                        await Login.changeRole(.patient)
                        showLoading = false
                    }
                }
                .font(.headline)
                .foregroundColor(.systemBackground)
                .padding(.vertical)
                .frame(width: 250)
                .background(Color.accentColor)
                .clipShape(Capsule())
                
                Button("ChooseRoleView.SignInAsDoctor.Button") {
                    Task(priority: .userInitiated) {
                        showLoading = true
                        await Login.changeRole(.doctor)
                        showLoading = false
                    }
                }
                .font(.headline)
                .foregroundColor(.systemBackground)
                .padding(.vertical)
                .frame(width: 250)
                .background(Color.accentColor)
                .clipShape(Capsule())
            }
        }
        .animation(.default, value: showLoading)
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
