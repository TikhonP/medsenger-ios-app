//
//  ChatViewModel.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 07.11.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import AVFoundation

final class ChatViewModel: NSObject, ObservableObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    @Published var message: String = ""
    
    private var contractId: Int
    
    private var audioRecorder: AVAudioRecorder!
    private var audioPlayer: AVAudioPlayer!
    private var recordingSession: AVAudioSession?
    
    @Published var isRecordingVoiceMessage: Bool = false
    @Published var showAlertRecordingIsNotPermited: Bool = false
    @Published var showRecordingfailedAlert: Bool = false
    @Published var showRecordedMessage: Bool = false
    
    @Published var isVoiceMessagePlaying: Bool = false
    
    @Published var quickLookDocumentUrl: URL?
    @Published var loadingAttachmentIds = [Int]()
    
    init(contractId: Int) {
        self.contractId = contractId
    }
    
    func fetchMessages() {
        Messages.shared.getMessages(contractId: contractId)
    }
    
    func sendMessage() {
        if !self.message.isEmpty {
            let message = self.message
            self.message = ""
            Messages.shared.sendMessage(message, contractId: contractId)
        }
    }
    
    func initRecordingSession() {
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession?.setCategory(.playAndRecord, mode: .default)
            try recordingSession?.setActive(true)
        } catch {
            print("Failed to prepare AVAudioSession: \(error.localizedDescription)")
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
                    print("Failed to start audio recording: \(error.localizedDescription)")
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
    
    func startPlaying(_ url: URL, completion: (() -> Void)? = nil) {
        let playSession = AVAudioSession.sharedInstance()
        
        do {
            try playSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch {
            print("Failed to override output audio port: \(error.localizedDescription)")
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
            print("Playing voice message failed: \(error.localizedDescription)")
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
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isVoiceMessagePlaying = false
        }
    }
    
    func sendVoiceMessage() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let voiceMessageFilePath = documentsDirectory.appendingPathComponent(Constants.voiceMessageFileName)
        
        Messages.shared.sendMessage(
            Constants.voiceMessageText,
            contractId: contractId,
            attachments: [voiceMessageFilePath]) {
                DispatchQueue.main.async {
                    self.isRecordingVoiceMessage = false
                    self.showRecordedMessage = false
                    self.isVoiceMessagePlaying = false
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
}
