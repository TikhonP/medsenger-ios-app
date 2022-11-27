//
//  VideoView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 27.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI

struct VideoView: UIViewControllerRepresentable {
    let webRTCClient: WebRTCClient
    
    func makeUIViewController(context: Context) -> VideoViewController {
        return VideoViewController(webRTCClient: self.webRTCClient)
    }
    
    func updateUIViewController(_ uiViewController: VideoViewController, context: Context) {
        
    }
}

struct VideoView_Previews: PreviewProvider {
    static var previews: some View {
        VideoView(webRTCClient: WebRTCClient(contractId: 1234))
    }
}
