//
//  MessageTimeDividerView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 21.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct MessageTimeDividerView: View {
    let date: Date
    
    var body: some View {
        Group {
            if date.isInToday {
                Text("MessageTimeDividerView.Today")
            } else if date.isInThisYear {
                Text(date, formatter: DateFormatter.ddMMMMFormatter)
            } else {
                Text(date, formatter: DateFormatter.ddMMMMyyyyFormatter)
            }
        }
        .font(.footnote)
        .padding(5)
        .background(Color.secondary.opacity(0.2))
        .clipShape(Capsule())
    }
}

struct MessageTimeDividerView_Previews: PreviewProvider {
    static var previews: some View {
        MessageTimeDividerView(date: Date())
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
            .environment(\.locale, .init(identifier: "ru"))
    }
}
