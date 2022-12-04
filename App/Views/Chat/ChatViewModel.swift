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

enum ChatViewAttachmentType: String {
    case image, video, audio, file
}

struct ChatViewAttachment: Identifiable, Equatable {
    let id = UUID()
    let data: Data
    let extention: String
    let realFilename: String?
    let type: ChatViewAttachmentType
    
    var mimeType: String {
        if let mimeType = UTType(filenameExtension: extention)?.preferredMIMEType {
            return mimeType
        } else {
            return "multipart/form-data"
        }
    }
    
    var randomFilename: String {
        let url = URL(fileURLWithPath: String.uniqueFilename(), relativeTo: nil)
        let fileURL = url.appendingPathExtension(extention)
        return fileURL.relativePath
    }
    
    var filename: String {
        realFilename ?? randomFilename
    }
}

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
    @Published var replyToMessage: Message?
    
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
    @Published var selectedMedia: ImagePickerMedia?
    @Published var addedImages = [ChatViewAttachment]()

    @Published var scrollToMessageId: Int?
    
    @Published var isAudioMessagePlayingWithId: Int?
    @Published var totalAudioMessageTime: Double?
    @Published var playingAudioProgress: Double = 0
    
    init(contractId: Int) {
        self.contractId = contractId
    }
    
    private var replyToId: Int? {
        guard let replyToMessage = replyToMessage else {
            return nil
        }
        return Int(replyToMessage.id)
    }
    
    func onChatViewAppear(contract: Contract) {
        Messages.shared.fetchMessages(contractId: contractId)
        UIApplication.shared.applicationIconBadgeNumber -= Int(contract.unread)
    }
    
    func sendMessage() {
        if showRecordedMessage {
            sendVoiceMessage()
            return
        }
        guard !message.isEmpty || !addedImages.isEmpty else {
            return
        }
        if !addedImages.isEmpty {
            Messages.shared.sendMessage(
                message,
                for: contractId,
                replyToId: replyToId,
                attachments: addedImages) {
                    DispatchQueue.main.async {
                        self.addedImages = []
                        self.message = ""
                    }
                }
        } else {
            Messages.shared.sendMessage(message, for: contractId, replyToId: replyToId) {
                DispatchQueue.main.async {
                    self.message = ""
                }
            }
        }
    }
    
    func fetchAttachment(_ attachment: Attachment, completion: (() -> Void)? = nil) {
        Messages.shared.fetchAttachmentData(attachmentId: Int(attachment.id)) {
            DispatchQueue.main.async {
                if let completion = completion {
                    completion()
                }
            }
        }
    }
    
    func fetchImageAttachment(_ imageAttachment: ImageAttachment, completion: (() -> Void)? = nil) {
        Messages.shared.fetchImageAttachmentImage(imageAttachmentId: Int(imageAttachment.id))
    }
    
    func showAttachmentPreview(_ attachment: Attachment) {
        if let dataPath = attachment.dataPath {
            quickLookDocumentUrl = dataPath
        } else {
            loadingAttachmentIds.append(Int(attachment.id))
            fetchAttachment(attachment) {
                if let index = self.loadingAttachmentIds.firstIndex(of: Int(attachment.id)) {
                    self.loadingAttachmentIds.remove(at: index)
                }
                self.quickLookDocumentUrl = Attachment.get(id: Int(attachment.id))?.dataPath
            }
        }
    }
    
    func sendVoiceMessage() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let voiceMessageFilePath = documentsDirectory.appendingPathComponent(Constants.voiceMessageFileName)
        guard let data = try? Data(contentsOf: voiceMessageFilePath) else { return }
        Messages.shared.sendMessage(
            Constants.voiceMessageText,
            for: contractId,
            replyToId: replyToId,
            attachments: [ChatViewAttachment(
                data: data, extention: "m4a", realFilename: Constants.voiceMessageFileName, type: .audio)]) { [weak self] in
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
    func startPlaying(_ url: URL, attachmentId: Int? = nil, completion: (() -> Void)? = nil) {
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
            totalAudioMessageTime = audioPlayer.duration
            playingAudioProgress = audioPlayer.currentTime / audioPlayer.duration
            Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] timer in
                guard let self = self else {
                    timer.invalidate()
                    return
                }
                if !self.isVoiceMessagePlaying && self.isAudioMessagePlayingWithId == nil {
                    timer.invalidate()
                } else {
                    self.playingAudioProgress = self.audioPlayer.currentTime / self.audioPlayer.duration
                }
            }
            if let attachmentId = attachmentId {
                isAudioMessagePlayingWithId = attachmentId
            }
            if let completion = completion {
                completion()
            }
        } catch {
            ChatViewModel.logger.error("Playing voice message failed: \(error.localizedDescription)")
        }
    }
    
    func stopPlaying() {
        audioPlayer.stop()
        isVoiceMessagePlaying = false
        isAudioMessagePlayingWithId = nil
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
            self.isAudioMessagePlayingWithId = nil
            self.isVoiceMessagePlaying = false
        }
    }
    
    internal func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            ChatViewModel.logger.error("audioPlayerDecodeErrorDidOccur: \(error.localizedDescription)")
        } else {
            ChatViewModel.logger.error("audioPlayerDecodeErrorDidOccur")
        }
    }
}
