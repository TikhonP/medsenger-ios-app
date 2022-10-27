//
//  PasswordFieldView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 24.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct PasswordFieldView: View {
    @Binding var password: String
    
    @State var hidePassword: Bool = true
    
    var body: some View {
        ZStack {
            if hidePassword {
                SecureField("Password", text: $password)
                    .padding()
                    .cornerRadius(5.0)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textContentType(.password)
            } else {
                TextField("Password", text: $password)
                    .padding()
                    .cornerRadius(5.0)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .textContentType(.password)
            }
            
            HStack {
                Spacer()
                Button(action: { hidePassword.toggle() }, label: {
                    Image(systemName: hidePassword ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.gray)
                })
                .padding()
            }
        }
    }
}

struct PasswordFieldView_Previews: PreviewProvider {
    @State var password = ""
    
    static var previews: some View {
        PasswordFieldView(password: .constant(""))
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
    }
}
