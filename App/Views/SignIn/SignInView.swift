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
    @StateObject private var motionManager = MotionManager()
    @EnvironmentObject private var networkConnectionMonitor: NetworkConnectionMonitor
    
    @State var buttonXoffset: CGFloat = .zero
    @State var buttonYoffset: CGFloat = .zero
    
    @State var degrees: CGFloat = .zero
    
    @State var scale: CGFloat = 1
    
    func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { time in
            if Bool.random() && Bool.random() {
                self.buttonXoffset = CGFloat.random(in: -100...100)
                self.buttonYoffset = CGFloat.random(in: -100...100)
            }
        })
    }
    
    func startRolling() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { time in
            self.degrees += 20
            if self.degrees > 360 {
                self.degrees = 0
            }
        })
    }
    
    func startScale() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { time in
            if self.scale > 2 {
                self.scale -= 0.1
            } else if self.scale < 0 {
                self.scale += 0.1
            } else {
                self.scale = CGFloat.random(in: 0...2)
            }
        })
    }
    
    var body: some View {
        VStack {
            Spacer()
            Text("Medsenger")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundColor(.accentColor)
                .multilineTextAlignment(.center)
                .padding()
                .offset(x: motionManager.x * 100, y: motionManager.y * 100)

            Spacer()
            TextField("Email", text: $signInViewModel.login)
                .padding()
                .textContentType(.username)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .rotationEffect(.degrees(degrees))
                .onTapGesture {
                    startRolling()
                }
            PasswordFieldView(password: $signInViewModel.password)
                .padding()
                .scaleEffect(scale)
                .onTapGesture {
                    startScale()
                }
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
                .rotationEffect(.degrees(0 + motionManager.x * 20 - motionManager.y * 20))
                .shadow(color: .gray, radius: 30, x: motionManager.x * 20, y: motionManager.y * 20)
                .offset(x: buttonXoffset, y: buttonYoffset)
            })
            Spacer()
        }
        .alert(item: $signInViewModel.alert) { $0.alert }
        .animation(.default, value: motionManager.x)
        .animation(.default, value: motionManager.y)
        .animation(.default, value: buttonXoffset)
        .animation(.default, value: buttonYoffset)
        .animation(.default, value: degrees)
        .animation(.default, value: scale)
        .onAppear(perform: {
            startTimer()
        })
    }
}

#if DEBUG
struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
#endif
