//
//  LocalVideoView.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 28.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import SwiftUI
import UIKit
import WebRTC

class LocalVideoViewController: UIViewController {
    private let webRTCClient: WebRTCClient
    private var localRenderer: RTCVideoRenderer?
    
    init(webRTCClient: WebRTCClient) {
        self.webRTCClient = webRTCClient
        super.init(nibName: String(describing: LocalVideoViewController.self), bundle: Bundle.main)
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
        
        let localRenderer = RTCMTLVideoView(frame: self.view.frame)
        self.localRenderer = localRenderer
        
        localRenderer.videoContentMode = .scaleAspectFill
        
        self.webRTCClient.startCaptureLocalVideo(renderer: localRenderer)
        
        self.embedView(localRenderer, into: self.view)
        self.view.sendSubviewToBack(localRenderer)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let localRenderer = localRenderer {
            self.webRTCClient.stopVideoRender(to: localRenderer)
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

struct LocalVideoView: UIViewControllerRepresentable {
    let webRTCClient: WebRTCClient
    
    func makeUIViewController(context: Context) -> LocalVideoViewController {
        return LocalVideoViewController(webRTCClient: self.webRTCClient)
    }
    
    func updateUIViewController(_ uiViewController: LocalVideoViewController, context: Context) {
        
    }
}

struct LocalVideoView_Previews: PreviewProvider {
    static var previews: some View {
        LocalVideoView(webRTCClient: WebRTCClient(contractId: 1234))
    }
}
