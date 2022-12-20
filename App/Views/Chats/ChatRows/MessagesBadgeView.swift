//
//  MessagesBadgeView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 20.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct MessagesBadgeView: View {
    let count: Int
    let color: Color
    
    var body: some View {
        Text("\(count)")
            .padding(5)
            .background(
                Capsule()
                    .foregroundColor(color)
                    .frame(minWidth: 30)
            )
    }
}

#if DEBUG
struct MessagesBadgeView_Previews: PreviewProvider {
    static var previews: some View {
        MessagesBadgeView(count: Int.random(in: 0...5), color: .accentColor.opacity(0.5))
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
#endif
