//
//  VideoCallMessageView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 19.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct VideoCallMessageView: View {
    @ObservedObject var message: Message
    @EnvironmentObject private var chatViewModel: ChatViewModel
    
    var body: some View {
        VStack {
            Label("Call from the Doctor", systemImage: "phone")
            Text(message.wrappedText)
                .frame(width: 230)
            if let date = message.sent {
                Text(date, formatter: DateFormatter.HHmm)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 5)
        .background(
            Color.secondary.opacity(0.5)
        )
        .cornerRadius(25)
    }
}

//struct VideoCallMessageView_Previews: PreviewProvider {
//    static var previews: some View {
//        VideoCallMessageView()
//    }
//}
