//
//  VideoCallView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 27.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct VideoCallView: View {
    @StateObject private var videoCallViewModel: VideoCallViewModel
    
    init(contractId: Int, contentViewModel: ContentViewModel) {
        _videoCallViewModel = StateObject(wrappedValue: VideoCallViewModel(contractId: contractId, contentViewModel: contentViewModel))
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .edgesIgnoringSafeArea(.all)
            switch videoCallViewModel.state {
            case .new, .checking:
                WaitingCallView()
                    .environmentObject(videoCallViewModel)
            case .connected, .completed:
                CallingView()
                    .environmentObject(videoCallViewModel)
            default:
                Text("Call error")
            }
        }
        .onAppear(perform: videoCallViewModel.makeCall)
    }
}

struct VideoCallView_Previews: PreviewProvider {
    static var previews: some View {
        VideoCallView(contractId: 1234, contentViewModel: ContentViewModel())
    }
}
