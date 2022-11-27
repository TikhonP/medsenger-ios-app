//
//  CallingView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 27.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct CallingView: View {
    @EnvironmentObject private var videoCallViewModel: VideoCallViewModel
    
    var body: some View {
        VStack {
            ZStack {
                VideoView(webRTCClient: videoCallViewModel.webRTCClient)
                VStack {
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
    }
}

struct CallingView_Previews: PreviewProvider {
    static var previews: some View {
        CallingView()
    }
}
