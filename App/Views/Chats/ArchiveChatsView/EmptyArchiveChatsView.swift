//
//  EmptyArchiveChatsView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 03.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct EmptyArchiveChatsView: View {
    var body: some View {
        VStack {
            Image(systemName: "archiveboxw.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 70)
                .foregroundColor(.secondary)
            Text("No archived contracts")
                .font(.title)
                .bold()
            Text("Your archived contracts will appear here.")
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

#if DEBUG
struct EmptyArchiveChatsView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyArchiveChatsView()
    }
}
#endif
