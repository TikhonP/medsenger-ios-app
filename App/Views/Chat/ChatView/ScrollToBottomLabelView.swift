//
//  ScrollToBottomLabelView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 06.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct ScrollToBottomLabelView: View {
    var body: some View {
        Image(systemName: "chevron.down")
            .resizable()
            .scaledToFit()
            .foregroundColor(.gray)
            .padding(10)
            .frame(width: 38)
            .padding(5)
            .blurEffect()
            .clipShape(Circle())
            .overlay(
                Circle().stroke(.gray, lineWidth: 0.2)
            )
        
    }
}

struct ScrollToBottomLabelView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollToBottomLabelView()
            .padding()
            .previewLayout(PreviewLayout.sizeThatFits)
    }
}
