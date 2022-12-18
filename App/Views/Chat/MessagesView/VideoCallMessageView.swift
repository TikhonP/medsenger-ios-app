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
            MessageTimeBadge(message: message)
        }
        .padding(10)
        .background(
            Color.secondary
        )
        .cornerRadius(25)
        .frame(width: 450)
    }
}

//struct VideoCallMessageView_Previews: PreviewProvider {
//    static var previews: some View {
//        VideoCallMessageView()
//    }
//}
