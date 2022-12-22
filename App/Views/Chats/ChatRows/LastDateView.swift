//
//  LastDateView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 03.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct LastDateView: View {
    let date: Date
    
    var body: some View {
        if date.isInToday {
            Text(date, style: .time)
        } else if date.isInThisWeek {
            Text(date, formatter: DateFormatter.dayOfWeekFormatter)
        } else if date.isInThisYear {
            Text(date, formatter: DateFormatter.ddMMFormatter)
        } else {
            Text(date, formatter: DateFormatter.ddMMYYYYFormatter)
        }
    }
}

#if DEBUG
struct LastDateView_Previews: PreviewProvider {
    static var previews: some View {
        LastDateView(date: Date())
            .previewLayout(PreviewLayout.sizeThatFits)
            .padding()
            .environment(\.locale, .init(identifier: "ru"))
    }
}
#endif
