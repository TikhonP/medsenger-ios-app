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
        VStack(alignment: .center) {
            Spacer()
            Image("medsengerFullwhite")
                .resizable()
                .scaledToFit()
                .padding()
            Spacer()
            if !networkConnectionMonitor.isConnected {
                Image(systemName: "wifi.exclamationmark")
                    .imageScale(.large)
                Text("Internet connection not available")
                    .font(.body)
                    .fontWeight(.bold)
                Text("Turn off Airplane Mode or connect to Wi-Fi.")
                    .font(.body)
                    .foregroundColor(Color.gray)
                    .multilineTextAlignment(.center)
                    .padding(.leading, 40)
                    .padding(.trailing, 40)
                Spacer()
            }
            TextField("Email", text: $signInViewModel.login)
                .padding()
                .textContentType(.username)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke()
                        .foregroundColor(.accentColor)
                )
                .padding(.horizontal)
            PasswordFieldView(password: $signInViewModel.password, placeholder: "Password")
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke()
                        .foregroundColor(.accentColor)
                )
                .padding(.horizontal)
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
                .animation(.default, value: signInViewModel.showLoader)
            })
            Spacer()
        }
        .animation(.default, value: networkConnectionMonitor.isConnected)
        .alert(item: $signInViewModel.alert) { $0.alert }
    }
}

#if DEBUG
struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
            .environmentObject(NetworkConnectionMonitor())
    }
}
#endif
