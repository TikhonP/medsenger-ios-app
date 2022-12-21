//
//  EmptyChatsView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 03.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct EmptyChatsView: View {
    var body: some View {
        VStack {
            Image(systemName: "message.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 70)
                .foregroundColor(.secondary)
            Text("EmptyChatsView.noContracts", comment: "No contracts")
                .font(.title)
                .bold()
            Text("EmptyChatsView.yourContractsAppearHere", comment: "Your contracts will appear here.")
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

#if DEBUG
struct EmptyChatsView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyChatsView()
    }
}
#endif
