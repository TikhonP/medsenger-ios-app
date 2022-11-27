//
//  WaitingCallView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 27.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct WaitingCallView: View {
    @EnvironmentObject private var videoCallViewModel: VideoCallViewModel
    
    var body: some View {
        VStack {
            Spacer()
            if videoCallViewModel.answered {
                Text("Answered...")
                    .font(.largeTitle)
            } else {
                Text("Calling...")
                    .font(.largeTitle)
            }
            switch videoCallViewModel.state {
            case .new:
                Text("New")
            case .checking:
                Text("checking")
            default:
                Text("\(videoCallViewModel.state.rawValue)")
            }
            Spacer()
            Button(action: videoCallViewModel.hangUp, label: {
                Image(systemName: "phone.down.circle.fill")
                    .foregroundColor(.red)
                    .font(.largeTitle)
                    .padding()
            })
        }
    }
}

struct WaitingCallView_Previews: PreviewProvider {
    static var previews: some View {
        WaitingCallView()
    }
}
