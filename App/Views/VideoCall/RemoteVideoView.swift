//
//  RemoteVideoView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 27.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI
import UIKit
import WebRTC

class RemoteVideoViewController: UIViewController {
    private let webRTCClient: WebRTCClient
    private var remoteRenderer: RTCVideoRenderer?
    
    init(webRTCClient: WebRTCClient) {
        self.webRTCClient = webRTCClient
        super.init(nibName: String(describing: RemoteVideoViewController.self), bundle: Bundle.main)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let remoteRenderer = RTCMTLVideoView(frame: self.view.frame)
        
        self.remoteRenderer = remoteRenderer
        
        remoteRenderer.videoContentMode = .scaleAspectFill
        
        self.webRTCClient.renderRemoteVideo(to: remoteRenderer)
        
        self.embedView(remoteRenderer, into: self.view)
        self.view.sendSubviewToBack(remoteRenderer)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let remoteRenderer = remoteRenderer {
            self.webRTCClient.stopVideoRender(to: remoteRenderer)
        }
    }
    
    private func embedView(_ view: UIView, into containerView: UIView) {
        containerView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
                                                                    options: [],
                                                                    metrics: nil,
                                                                    views: ["view":view]))
        
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|",
                                                                    options: [],
                                                                    metrics: nil,
                                                                    views: ["view":view]))
        containerView.layoutIfNeeded()
    }
}

struct RemoteVideoView: UIViewControllerRepresentable {
    let webRTCClient: WebRTCClient
    
    func makeUIViewController(context: Context) -> RemoteVideoViewController {
        return RemoteVideoViewController(webRTCClient: self.webRTCClient)
    }
    
    func updateUIViewController(_ uiViewController: RemoteVideoViewController, context: Context) {
        
    }
}

#if DEBUG
struct VideoView_Previews: PreviewProvider {
    static var previews: some View {
        RemoteVideoView(webRTCClient: WebRTCClient(contractId: 1234))
    }
}
#endif
