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
                .padding(.horizontal)
            Spacer()
            if !networkConnectionMonitor.isConnected {
                Image(systemName: "wifi.exclamationmark")
                    .imageScale(.large)
                Text("SignInView.internetNotAvailableTitle", comment: "Internet connection not available")
                    .font(.body)
                    .fontWeight(.bold)
                Text("SignInView.internetNotAvailableMessage", comment: "Turn off Airplane Mode or connect to Wi-Fi.")
                    .font(.body)
                    .foregroundColor(Color.gray)
                    .multilineTextAlignment(.center)
                    .padding(.leading, 40)
                    .padding(.trailing, 40)
                Spacer()
            }
            TextField("SignInView.Email.TextField", text: $signInViewModel.login)
                .padding(10)
                .textContentType(.username)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color("medsengerBlue"), lineWidth: 2)
                )
                .padding(.horizontal)
            PasswordFieldView(password: $signInViewModel.password, placeholder: "TextField.Password.TextField")
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color("medsengerBlue"), lineWidth: 2)
                )
                .padding(.horizontal)
            Spacer()
            Button {
                Task(priority: .userInitiated) {
                    await signInViewModel.auth()
                }
            } label: {
                Group {
                    if signInViewModel.showLoader {
                        ProgressView()
                    } else {
                        Text("SignInView.signIn.Button", comment: "Sign In")
                    }
                }
                .font(.headline)
                .foregroundColor(.systemBackground)
                .frame(height: 40)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(colors: [Color("medsengerBlue"), .accentColor], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .cornerRadius(10)
                .padding()
                .animation(.default, value: signInViewModel.showLoader)
            }
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
