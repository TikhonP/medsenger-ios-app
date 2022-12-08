//
//  SignInView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 24.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct SignInView: View {
    @StateObject private var signInViewModel = SignInViewModel()
    
    @EnvironmentObject private var networkConnectionMonitor: NetworkConnectionMonitor
    
    var body: some View {
        VStack {
            Spacer()
            Text("Medsenger")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundColor(.accentColor)
                .multilineTextAlignment(.center)
                .padding()
            Spacer()
            TextField("Email", text: $signInViewModel.login)
                .padding()
                .textContentType(.username)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            PasswordFieldView(password: $signInViewModel.password)
            Spacer()
            
            Button(action: signInViewModel.auth, label: {
                ZStack {
                    if signInViewModel.showLoader {
                        ProgressView()
                    } else {
                        Text("Sign In")
                    }
                }
                .font(.headline)
                .foregroundColor(Color(UIColor.systemBackground))
                .padding(.vertical)
                .padding(.horizontal, 50)
                .background(Color.accentColor)
                .clipShape(Capsule())
            })
            Spacer()
        }
        .alert(item: $signInViewModel.alert, content: { error in
            Alert(
                title: Text(error.title),
                message: Text(error.message),
                dismissButton: .default(Text("Close"))
            )
        })
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
