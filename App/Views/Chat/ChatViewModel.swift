//
//  ChatViewModel.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 07.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import AVFoundation
import os.log
import UIKit
import SwiftUI

final class ChatViewModel: NSObject, ObservableObject, Alertable {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: ChatViewModel.self)
    )
    
    private var contractId: Int
    
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var recordingSession: AVAudioSession?
    
    @Published var scrollToMessageId: Int?
    
    // Documents QuickLook
    @Published var quickLookDocumentUrl: URL?
    @Published var loadingAttachmentIds = [Int]()
    
    // Playing voice messages varibles
    @Published var isAudioMessagePlayingWithId: Int?
    @Published var totalAudioMessageTime: Double?
    @Published var playingAudioProgress: Double = 0
    
    @Published var alert: AlertInfo?
    
    @Published var showActionWebViewModal = false
    @Published var agentActionUrl: URL?
    @Published var agentActionName: String?
    @Published var actionMessageId: Int?
    
    init(contractId: Int) {
        self.contractId = contractId
    }
    
    func onChatViewAppear(contract: Contract) {
        Messages.shared.fetchMessages(contractId: contractId) { _ in }
        UIApplication.shared.applicationIconBadgeNumber -= Int(contract.unread)
    }
    
    func fetchAttachment(_ attachment: Attachment, completion: ((_ succeeded: Bool) -> Void)? = nil) {
        Messages.shared.fetchAttachmentData(attachmentId: Int(attachment.id)) { succeeded in
            if let completion = completion {
                DispatchQueue.main.async {
                    completion(succeeded)
                }
            }
        }
    }
    
    func fetchImageAttachment(_ imageAttachment: ImageAttachment) {
        Messages.shared.fetchImageAttachmentImage(imageAttachmentId: Int(imageAttachment.id)) { _ in }
    }
    
    func showAttachmentPreview(_ attachment: Attachment) {
        if let dataPath = attachment.dataPath {
            quickLookDocumentUrl = dataPath
        } else {
            loadingAttachmentIds.append(Int(attachment.id))
            fetchAttachment(attachment) { [weak self] succeeded in
                if let index = self?.loadingAttachmentIds.firstIndex(of: Int(attachment.id)) {
                    self?.loadingAttachmentIds.remove(at: index)
                }
                if succeeded {
                    self?.quickLookDocumentUrl = Attachment.get(id: Int(attachment.id))?.dataPath
                } else {
                    self?.presentGlobalAlert()
                }
            }
        }
    }
    
    func openMessageActionLink(message: Message) {
        if let actionType = message.wrappedActionType {
            actionMessageId = Int(message.id)
            switch actionType {
            case .zoom:
                presentAlert(title: Text("ChatViewModel.zoomActionIsNotSupportedNowAlertTitle", comment: "Zoom action is not supported now"))
            case .url:
                if let actionLink = message.actionLink {
                    UIApplication.shared.open(actionLink)
                }
            case .action:
                guard let apiActionLink = message.apiActionLink, var urlComponents = URLComponents(url: apiActionLink, resolvingAgainstBaseURL: false) else {
                    return
                }
                urlComponents.queryItems = {
                    if var queryItems = urlComponents.queryItems {
                        queryItems.append(URLQueryItem(name: "api_token", value: KeyChain.apiToken))
                        return queryItems
                    } else {
                        return [URLQueryItem(name: "api_token", value: KeyChain.apiToken)]
                    }
                }()
                guard let finalLink = urlComponents.url?.absoluteString.removingPercentEncoding else {
                    return
                }
                DispatchQueue.main.async {
                    self.agentActionUrl = URL(string: finalLink)
                    self.agentActionName = message.actionName
                    self.showActionWebViewModal = true
                }
            case .vc:
                presentAlert(title: Text("Vido conference is not supported now"))
            }
        }
    }
}

extension ChatViewModel: AVAudioPlayerDelegate {
    func startPlaying(_ url: URL, attachmentId: Int? = nil, completion: (() -> Void)? = nil) {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playback)
            try audioSession.setActive(true)
        } catch {
            presentAlert(title: Text("ChatViewModel.failedToSetupAudioOnYourDeviceAlertTitle", comment: "Failed to setup audio on your device"), .error)
            ChatViewModel.logger.error("startPlaying: Failed: \(error.localizedDescription)")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf : url)
        } catch {
            presentAlert(title: Text("ChatViewModel.failedToPlayAudioOnYourDeviceAlertTitle", comment: "Failed to play audio on your device"), .error)
            ChatViewModel.logger.error("startPlaying: Playing voice message failed: \(error.localizedDescription)")
            return
        }
        
        audioPlayer?.delegate = self
        audioPlayer?.prepareToPlay()
        audioPlayer?.play()
        totalAudioMessageTime = audioPlayer?.duration
        if let currentTime = self.audioPlayer?.currentTime, let duration = self.audioPlayer?.duration {
            self.playingAudioProgress = currentTime / duration
        }
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            if self.isAudioMessagePlayingWithId == nil {
                timer.invalidate()
            } else {
                if let currentTime = self.audioPlayer?.currentTime, let duration = self.audioPlayer?.duration {
                    DispatchQueue.main.async {
                        self.playingAudioProgress = currentTime / duration
                    }
                }
            }
        }
        if let attachmentId = attachmentId {
            isAudioMessagePlayingWithId = attachmentId
        }
        if let completion = completion {
            completion()
        }
    }
    
    func stopPlaying() {
        audioPlayer?.stop()
        isAudioMessagePlayingWithId = nil
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
    
    func startPlayingRecordedVoiceMessage() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let voiceMessageFilePath = documentsDirectory.appendingPathComponent(Constants.voiceMessageFileName)
        startPlaying(voiceMessageFilePath) { }
    }
    
    internal func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            ChatViewModel.logger.error("audioPlayerDidFinishPlaying: Failed to setActive(false): \(error.localizedDescription)")
        }
        DispatchQueue.main.async {
            self.isAudioMessagePlayingWithId = nil
        }
    }
    
    internal func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            ChatViewModel.logger.error("audioPlayerDecodeErrorDidOccur: \(error.localizedDescription)")
        } else {
            ChatViewModel.logger.error("audioPlayerDecodeErrorDidOccur")
        }
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}
