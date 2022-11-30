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

final class ChatViewModel: NSObject, ObservableObject {
    
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: ChatViewModel.self)
    )
    
    private var contractId: Int
    
    private var audioRecorder: AVAudioRecorder!
    private var audioPlayer: AVAudioPlayer!
    private var recordingSession: AVAudioSession?
    
    @Published var message: String = ""
    
    @Published var isRecordingVoiceMessage = false
    @Published var showAlertRecordingIsNotPermited = false
    @Published var showRecordingfailedAlert = false
    @Published var showRecordedMessage = false
    
    @Published var isVoiceMessagePlaying = false
    
    @Published var quickLookDocumentUrl: URL?
    @Published var loadingAttachmentIds = [Int]()
    
    @Published var showSelectImageOptions = false
    @Published var showSelectPhotosSheet = false
    @Published var showTakeImageSheet = false
    @Published var selectedImage = Data()
    @Published var isImageAdded = false
    
    init(contractId: Int) {
        self.contractId = contractId
    }
    
    func fetchMessages() {
        Messages.shared.fetchMessages(contractId: contractId)
    }
    
    func sendMessage() {
        if showRecordedMessage {
            sendVoiceMessage()
            return
        }
        guard !message.isEmpty || isImageAdded else {
            return
        }
        if isImageAdded {
            Messages.shared.sendMessage(
                message,
                contractId: contractId,
                attachments: [("image.png", selectedImage)]) {
                    DispatchQueue.main.async {
                        self.isImageAdded = false
                        self.message = ""
                    }
                }
        } else {
            Messages.shared.sendMessage(message, contractId: contractId) {
                DispatchQueue.main.async {
                    self.message = ""
                }
            }
        }
    }
    
    func showAttachmentPreview(_ attachment: Attachment) {
        if let dataPath = attachment.dataPath {
            quickLookDocumentUrl = dataPath
        } else {
            loadingAttachmentIds.append(Int(attachment.id))
            Messages.shared.fetchAttachmentData(attachmentId: Int(attachment.id)) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if let index = self.loadingAttachmentIds.firstIndex(of: Int(attachment.id)) {
                        self.loadingAttachmentIds.remove(at: index)
                    }
                    self.quickLookDocumentUrl = Attachment.get(id: Int(attachment.id))?.dataPath
                }
            }
        }
    }
    
    func sendVoiceMessage() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let voiceMessageFilePath = documentsDirectory.appendingPathComponent(Constants.voiceMessageFileName)
        guard let data = try? Data(contentsOf: voiceMessageFilePath) else { return }
        Messages.shared.sendMessage(
            Constants.voiceMessageText,
            contractId: contractId,
            attachments: [(Constants.voiceMessageFileName, data)]) { [weak self] in
                DispatchQueue.main.async {
                    self?.isRecordingVoiceMessage = false
                    self?.showRecordedMessage = false
                    self?.isVoiceMessagePlaying = false
                }
            }
    }
}

extension ChatViewModel: AVAudioRecorderDelegate {
    func initRecordingSession() {
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession?.setCategory(.playAndRecord, mode: .default)
            try recordingSession?.setActive(true)
        } catch {
            ChatViewModel.logger.error("Failed to prepare AVAudioSession: \(error.localizedDescription)")
        }
    }
    
    func startRecording() {
        if recordingSession == nil {
            initRecordingSession()
        }
        guard let recordingSession = recordingSession else {
            return
        }
        recordingSession.requestRecordPermission() { [unowned self] allowed in
            DispatchQueue.main.async {
                guard allowed else {
                    self.showAlertRecordingIsNotPermited = true
                    return
                }
                
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let voiceMessageFilePath = documentsDirectory.appendingPathComponent(Constants.voiceMessageFileName)
                
                let settings = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 12000,
                    AVNumberOfChannelsKey: 1,
                    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                ]
                
                do {
                    self.audioRecorder = try AVAudioRecorder(url: voiceMessageFilePath, settings: settings)
                    self.audioRecorder.delegate = self
                    self.audioRecorder.record()
                    self.isRecordingVoiceMessage = true
                } catch {
                    self.finishRecording(success: false)
                    ChatViewModel.logger.error("Failed to start audio recording: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        isRecordingVoiceMessage = false
        
        if success {
            showRecordedMessage = true
        } else {
            showRecordingfailedAlert = true
        }
    }
}

extension ChatViewModel: AVAudioPlayerDelegate {
    func startPlaying(_ url: URL, completion: (() -> Void)? = nil) {
        let playSession = AVAudioSession.sharedInstance()
        
        do {
            try playSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch {
            ChatViewModel.logger.error("Failed to override output audio port: \(error.localizedDescription)")
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf : url)
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            if let completion = completion {
                completion()
            }
        } catch {
            ChatViewModel.logger.error("Playing voice message failed: \(error.localizedDescription)")
        }
    }
    
    func stopPlaying(){
        audioPlayer.stop()
        isVoiceMessagePlaying = false
    }
    
    func startPlayingRecordedVoiceMessage() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let voiceMessageFilePath = documentsDirectory.appendingPathComponent(Constants.voiceMessageFileName)
        startPlaying(voiceMessageFilePath) {
            self.isVoiceMessagePlaying = true
        }
    }
    
    internal func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isVoiceMessagePlaying = false
        }
    }
}
