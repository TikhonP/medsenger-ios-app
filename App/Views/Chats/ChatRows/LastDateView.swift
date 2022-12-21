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
    
    let dayOfWeekFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EE"
        return dateFormatter
    }()
    
    let ddMMFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM"
        return dateFormatter
    }()
    
    let ddMMYYYYFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter
    }()
    
    var body: some View {
        if date.isInToday {
            Text(date, style: .time)
        } else if date.isInThisWeek {
            Text(date, formatter: dayOfWeekFormatter)
        } else if date.isInThisYear {
            Text(date, formatter: ddMMFormatter)
        } else {
            Text(date, formatter: ddMMYYYYFormatter)
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
