//
//  MessageInputButtonLabel.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 08.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct MessageInputButtonLabel: View {
    let imageSystemName: String
    @Binding var showProgress: Bool
    private let height: CGFloat = 38
    
    var body: some View {
        if showProgress {
            ZStack {
                Circle()
                ProgressView()
            }
            .frame(width: height, height: height)
        } else {
            Image(systemName: imageSystemName)
                .resizable()
                .scaledToFit()
                .frame(height: height)
        }
    }
}

struct MessageInputButtonLabel_Previews: PreviewProvider {
    static var previews: some View {
        MessageInputButtonLabel(imageSystemName: "paperclip.circle.fill", showProgress: .constant(true))
            .foregroundColor(.accentColor)
    }
}
