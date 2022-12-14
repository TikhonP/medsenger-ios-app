//
//  PasswordFieldView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 24.10.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct PasswordFieldView: View {
    @Binding private var password: String
    private let placeholder: LocalizedStringKey
    
    init(password: Binding<String>, placeholder: LocalizedStringKey = "") {
        _password = password
        self.placeholder = placeholder
    }
    
    @State private var hidePassword: Bool = true
    
    var body: some View {
        ZStack(alignment: .trailing) {
            if hidePassword {
                SecureField(placeholder, text: $password)
            } else {
                TextField(placeholder, text: $password)
            }
            
            Button(action: { hidePassword.toggle() }, label: {
                Image(systemName: hidePassword ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(.gray)
                    .padding(.trailing, 10)
            })
        }
        .autocapitalization(.none)
        .disableAutocorrection(true)
        .textContentType(.password)
        .animation(.default, value: hidePassword)
    }
}

#if DEBUG
struct PasswordFieldView_Previews: PreviewProvider {
    @State var password = ""
    
    static var previews: some View {
        PasswordFieldView(password: .constant(""))
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
    }
}
#endif
