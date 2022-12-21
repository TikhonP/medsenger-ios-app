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
    
    let ddMMMMFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM"
        return dateFormatter
    }()
    
    let ddMMMMyyyyFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        return dateFormatter
    }()
    
    var body: some View {
        ZStack {
            if date.isInToday {
                Text("MessageTimeDividerView.Today")
            } else if date.isInThisYear {
                Text(date, formatter: ddMMMMFormatter)
            } else {
                Text(date, formatter: ddMMMMyyyyFormatter)
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
