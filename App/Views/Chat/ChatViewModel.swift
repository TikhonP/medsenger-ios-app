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

final class ChatViewModel: NSObject, ObservableObject {
    
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: ChatViewModel.self)
    )
    
    private var contractId: Int
    
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var recordingSession: AVAudioSession?
    
    @Published var scrollToMessageId: Int?
    
    // Message body varibles
    @Published var message: String = ""
    @Published var replyToMessage: Message?
    @Published var messageAttachments = [ChatViewAttachment]()
    @Published var showSendingMessageLoading = false
    
    // Documents QuickLook
    @Published var quickLookDocumentUrl: URL?
    @Published var loadingAttachmentIds = [Int]()
    
    // Recording voice messages varibles
    @Published var isRecordingVoiceMessage = false
    @Published var isVoiceMessagePlaying = false
    @Published var showAlertRecordingIsNotPermited = false
    @Published var showRecordingfailedAlert = false
    @Published var showRecordedMessage = false
    @Published var recordedMessageUrl: URL?
    @Published var currentVoiceMessageTime: TimeInterval = 0
    
    // Playing voice messages varibles
    @Published var isAudioMessagePlayingWithId: Int?
    @Published var totalAudioMessageTime: Double?
    @Published var playingAudioProgress: Double = 0
    
    init(contractId: Int) {
        self.contractId = contractId
    }
    
    func onChatViewAppear(contract: Contract) {
        Messages.shared.fetchMessages(contractId: contractId)
        UIApplication.shared.applicationIconBadgeNumber -= Int(contract.unread)
    }
    
    func fetchMessagesFrom(messageId: Int) {
        Messages.shared.fetchMessages(contractId: contractId, maxId: messageId, desc: true, limit: 30) {
            
        }
    }
    
    private var replyToId: Int? {
        guard let replyToMessage = replyToMessage else {
            return nil
        }
        return Int(replyToMessage.id)
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
}

// MARK: - Send Message extention
extension ChatViewModel {
    func sendMessage() {
        guard !message.isEmpty || !messageAttachments.isEmpty else {
            return
        }
        showSendingMessageLoading = true
        Messages.shared.sendMessage(
            message,
            for: contractId,
            replyToId: replyToId,
            attachments: messageAttachments) { [weak self] succeeded in
                DispatchQueue.main.async {
                    self?.showSendingMessageLoading = false
                    if succeeded {
                        self?.messageAttachments = []
                        self?.message = ""
                    }
                }
            }
    }
    
    func sendVoiceMessage() {
        guard showRecordedMessage, let recordedMessageUrl = recordedMessageUrl, let data = try? Data(contentsOf: recordedMessageUrl) else {
            return
        }
        let attachment = ChatViewAttachment(data: data, extention: "m4a", realFilename: recordedMessageUrl.lastPathComponent, type: .audio)
        if isVoiceMessagePlaying {
            stopPlaying()
        }
        showSendingMessageLoading = true
        Messages.shared.sendMessage(
            Constants.voiceMessageText,
            for: contractId,
            replyToId: replyToId,
            attachments: [attachment]) { [weak self] succeeded in
                DispatchQueue.main.async {
                    self?.showSendingMessageLoading = false
                    if succeeded {
                        self?.isRecordingVoiceMessage = false
                        self?.showRecordedMessage = false
                    }
                }
            }
    }
    
    func addImagesAttachments(_ selectedMedia: ImagePickerMedia?) {
        guard let selectedMedia = selectedMedia else {
            return
        }
        let chatViewAttachment: ChatViewAttachment
        switch selectedMedia.type {
        case .image:
            chatViewAttachment = ChatViewAttachment(data: selectedMedia.data, extention: selectedMedia.extention, realFilename: selectedMedia.realFilename, type: .image)
        case .movie:
            chatViewAttachment = ChatViewAttachment(data: selectedMedia.data, extention: selectedMedia.extention, realFilename: selectedMedia.realFilename, type: .video)
        }
        messageAttachments.append(chatViewAttachment)
    }
    
    func addFilesAttachments(_ urls: [URL]) {
        for fileURL in urls {
            do {
                if fileURL.startAccessingSecurityScopedResource() {
                    let data = try Data(contentsOf: fileURL)
                    messageAttachments.append(ChatViewAttachment(
                        data: data, extention: fileURL.pathExtension, realFilename: fileURL.lastPathComponent, type: .file))
                    fileURL.stopAccessingSecurityScopedResource()
                }
            } catch {
                print("Failed to load file: \(error.localizedDescription)")
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
        recordingSession.requestRecordPermission() { [weak self] allowed in
            guard let self = self else {
                return
            }
            DispatchQueue.main.async {
                guard allowed else {
                    self.showAlertRecordingIsNotPermited = true
                    return
                }
                
                guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                    return
                }
                let voiceMessageFilePath = documentsDirectory.appendingPathComponent(Constants.voiceMessageFileName)
                self.recordedMessageUrl = voiceMessageFilePath
                
                let settings = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 12000,
                    AVNumberOfChannelsKey: 1,
                    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                ]
                
                do {
                    let audioRecorder = try AVAudioRecorder(url: voiceMessageFilePath, settings: settings)
                    self.audioRecorder = audioRecorder
                    if !audioRecorder.prepareToRecord() {
                        self.isRecordingVoiceMessage = false
                        self.showRecordingfailedAlert = true
                        ChatViewModel.logger.error("Failed to prepareToRecord audio recording")
                    }
                    audioRecorder.delegate = self
                    audioRecorder.record()
                    self.isRecordingVoiceMessage = true
                    self.currentVoiceMessageTime = audioRecorder.currentTime
                    Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] timer in
                        guard let self = self else {
                            timer.invalidate()
                            return
                        }
                        if !self.isRecordingVoiceMessage {
                            timer.invalidate()
                        } else {
                            if let currentTime = self.audioRecorder?.currentTime {
                                self.currentVoiceMessageTime = currentTime
                            }
                        }
                    }
                } catch {
                    self.audioRecorder?.stop()
                    self.audioRecorder = nil
                    self.isRecordingVoiceMessage = false
                    self.showRecordingfailedAlert = true
                    ChatViewModel.logger.error("Failed to start audio recording: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func finishRecording(success: Bool) {
        isRecordingVoiceMessage = false
        audioRecorder?.stop()
        audioRecorder = nil
        
        if success {
            showRecordedMessage = true
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("audioRecorderEncodeErrorDidOccur")
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("audioRecorderDidFinishRecording")
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
                if !self.isVoiceMessagePlaying && self.isAudioMessagePlayingWithId == nil {
                    timer.invalidate()
                } else {
                    if let currentTime = self.audioPlayer?.currentTime, let duration = self.audioPlayer?.duration {
                        self.playingAudioProgress = currentTime / duration
                    }
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
        audioPlayer?.stop()
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
