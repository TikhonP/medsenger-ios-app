//
//  SignInView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 24.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct SignInView: View {
    @ObservedObject private var signInViewModel: SignInViewModel
    @Environment(\.colorScheme) var colorScheme
    
    init(account: Account) {
        signInViewModel = SignInViewModel(account: account)
    }
    
    var body: some View {
        VStack {
            logoIconLoginView
            titleLoginView
            Spacer()
            usernameField
            PasswordFieldView(password: $signInViewModel.password)
            Spacer()
            
            if signInViewModel.showError {
                CardView(text: signInViewModel.error)
                Spacer()
            }
            
            if signInViewModel.showLoader {
                ProgressView()
            } else {
                Button(action: commitButtonAction, label: { buttonLoginView })
                    .animation(.default)
            }
            
            Spacer()
        }
        .padding()
    }
    
    var logoIconLoginView: some View {
        Image("loginIcon") // FIXME: logo
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 150, height: 150)
            //            .clipShape(Circle())
            //            .shadow(radius: 10)
            .padding()
    }
    
    var titleLoginView: some View {
        Text("Medsenger")
            .font(.largeTitle)
            .fontWeight(.semibold)
            .multilineTextAlignment(.center)
            .padding()
    }
    
    var buttonLoginView: some View {
        Text("Sign In")
            .font(.headline)
            .foregroundColor(colorScheme == .dark ? Color.black : Color.white)
            .padding()
            .frame(width: 220, height: 60)
            .background(colorScheme == .dark ? Color.white : Color.black)
            .cornerRadius(35)
    }
    
    var usernameField: some View {
        TextField("Email", text: $signInViewModel.login)
            .padding()
            .textContentType(.username)
            .cornerRadius(5.0)
            .autocapitalization(.none)
            .disableAutocorrection(true)
    }
    
    func commitButtonAction() {
        signInViewModel.auth()
    }
}

struct CardView: View {
    let text: String
    
    var body: some View {
        Text(text)
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.red, lineWidth: 1)
            )
    }
}

struct SignInView_Previews: PreviewProvider {
    let account = Account()
    
    struct Preview: View {
        let account = Account()

        var body: some View {
            SignInView(account: self.account)
        }
    }
    
    static var previews: some View {
        Preview()
    }
}
