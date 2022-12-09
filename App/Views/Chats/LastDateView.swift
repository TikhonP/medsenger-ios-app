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
    let currentDate = Date()
    
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
        if Calendar.current.isDateInToday(date) {
            Text(date, style: .time)
        } else if isSameWeek(date1: date, date2: currentDate) {
            Text(date, formatter: dayOfWeekFormatter)
        } else if isSameYear(date1: date, date2: currentDate) {
            Text(date, formatter: ddMMFormatter)
        } else {
            Text(date, formatter: ddMMYYYYFormatter)
        }
    }
    
    func isSameWeek(date1: Date, date2: Date) -> Bool {
        guard let diff = Calendar.current.dateComponents([.day], from: date1, to: date2).day else {
            return false
        }
        if diff < 7 {
            return true
        } else {
            return false
        }
    }
    
    func isSameYear(date1: Date, date2: Date) -> Bool {
        let diff = Calendar.current.dateComponents([.year], from: date1, to: date2)
        if diff.day == 0 {
            return true
        } else {
            return false
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
