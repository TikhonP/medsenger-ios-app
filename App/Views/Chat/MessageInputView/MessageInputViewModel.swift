//
//  MessageInputViewModel.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 14.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import AVFAudio
import os.log
import SwiftUI

@MainActor
final class MessageInputViewModel: NSObject, ObservableObject, Alertable {
    
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: MessageInputViewModel.self)
    )
    
    private var contractId: Int
    
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    
    @Published var alert: AlertInfo?
    
    @Published var message: String
    @Published var replyToMessage: Message?
    @Published var messageAttachments = [ChatViewAttachment]()
    @Published var showSendingMessageLoading = false
    
    @Published var isRecordingVoiceMessage = false
    @Published var isVoiceMessagePlaying = false
    @Published var showRecordedMessage = false
    @Published var recordedMessageUrl: URL?
    @Published var currentVoiceMessageTime: TimeInterval = 0
    
    @Published var totalAudioMessageTime: Double?
    @Published var playingAudioProgress: Double = 0
    
    private var recordingMessageTimer: Timer?
    private var playingMessageTimer: Timer?
    
    init(contractId: Int, messageDraft: String) {
        self.message = messageDraft
        self.contractId = contractId
    }
    
    private var replyToId: Int? {
        guard let replyToMessage = replyToMessage else {
            return nil
        }
        return Int(replyToMessage.id)
    }
    
    func sendMessage() async {
        guard !message.isEmpty || !messageAttachments.isEmpty else {
            return
        }
        showSendingMessageLoading = true
        do {
            try await Messages.sendMessage(
                message,
                for: contractId,
                replyToId: replyToId,
                attachments: messageAttachments)
            showSendingMessageLoading = false
            messageAttachments = []
            message = ""
            saveMessageDraft()
            replyToMessage = nil
        } catch {
            showSendingMessageLoading = false
            presentGlobalAlert()
        }
    }
    
    func sendVoiceMessage() async {
        guard showRecordedMessage, let recordedMessageUrl = recordedMessageUrl, let data = try? Data(contentsOf: recordedMessageUrl) else {
            return
        }
        let attachment = ChatViewAttachment(data: data, extention: "m4a", realFilename: recordedMessageUrl.lastPathComponent, type: .audio)
        if isVoiceMessagePlaying {
            stopPlaying()
        }
        showSendingMessageLoading = true
        do {
            try await Messages.sendMessage(
                Constants.voiceMessageText,
                for: contractId,
                replyToId: replyToId,
                attachments: [attachment])
            showSendingMessageLoading = false
            self.isRecordingVoiceMessage = false
            self.showRecordedMessage = false
            self.replyToMessage = nil
        } catch {
            showSendingMessageLoading = false
            presentGlobalAlert()
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
    
    func addFilesAttachments(_ urls: [URL]) async {
        for fileURL in urls {
            do {
                if fileURL.startAccessingSecurityScopedResource() {
                    let data = try Data(contentsOf: fileURL)
                    messageAttachments.append(ChatViewAttachment(
                        data: data, extention: fileURL.pathExtension, realFilename: fileURL.lastPathComponent, type: .file))
                    fileURL.stopAccessingSecurityScopedResource()
                }
            } catch {
                presentAlert(title: Text("MessageInputViewModel.failedToAddAttachmentAlertTitle", comment: "Failed to add attachment"))
                MessageInputViewModel.logger.error("Failed to load file: \(error.localizedDescription)")
            }
        }
    }
    
    enum AddOnDropAttachmentsError: Error {
        case providersIsEmpty
    }
    
    func addOnDropAttachments(_ providers: [NSItemProvider]) async throws {
        guard !providers.isEmpty else {
            throw AddOnDropAttachmentsError.providersIsEmpty
        }
        for itemProvider in providers {
            guard let typeIdentifier = itemProvider.registeredTypeIdentifiers.first else {
                continue
            }
            let (data, filename, fileExtention) = try await itemProvider.loadFileRepresentation(forTypeIdentifier: typeIdentifier)
            messageAttachments.append(
                ChatViewAttachment(
                    data: data,
                    extention: fileExtention,
                    realFilename: filename,
                    type: .file)
            )
        }
    }
    
    func saveMessageDraft() {
        Task(priority: .background) {
            try? await Contract.saveMessageDraft(id: contractId, messageDraft: message)
        }
    }
    
    func removeFile(_ url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            Logger.defaultLogger.error("Failed to remove file preview: \(error.localizedDescription)")
        }
    }
}

extension MessageInputViewModel: AVAudioRecorderDelegate {
    func startRecording() async {
        let recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            presentAlert(title: Text("MessageInputViewModel.failedToPrepareAudioRecordingAlertTitle", comment: "Failed to prepare audio recording"))
            MessageInputViewModel.logger.error("Failed to prepare AVAudioSession: \(error.localizedDescription)")
            return
        }
        recordingSession.requestRecordPermission() { [weak self] allowed in
            guard let strongSelf = self else {
                return
            }
            guard allowed else {
                strongSelf.presentAlert(
                    Alert(
                        title: Text("MessageInputViewModel.allowMicrophoneAccessAlertTitle", comment: "Please Allow Access"),
                        message: Text("MessageInputViewModel.allowMicrophoneAccessAlertMessage", comment: "Medsenger needs access to your microphone so that you can send voice messages.\n\nPlease go to your device's settings > Privacy > Microphone and set Medsenger to ON."),
                        primaryButton: .cancel(Text("MessageInputViewModel.allowMicrophoneAccessAlertCancelButton", comment: "Not Now")),
                        secondaryButton: .default(Text("MessageInputViewModel.allowMicrophoneAccessAlertSettingsButton", comment: "Settings")) {
                            DispatchQueue.main.async {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
                            }
                        })
                )
                return
            }
            
            guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                return
            }
            let voiceMessageFilePath = documentsDirectory.appendingPathComponent(Constants.voiceMessageFileName)
            strongSelf.recordedMessageUrl = voiceMessageFilePath
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            do {
                let audioRecorder = try AVAudioRecorder(url: voiceMessageFilePath, settings: settings)
                strongSelf.audioRecorder = audioRecorder
                if !audioRecorder.prepareToRecord() {
                    strongSelf.isRecordingVoiceMessage = false
                    //                        self.showRecordingfailedAlert = true
                    MessageInputViewModel.logger.error("Failed to prepareToRecord audio recording")
                }
                audioRecorder.delegate = self
                audioRecorder.record()
                strongSelf.isRecordingVoiceMessage = true
                strongSelf.currentVoiceMessageTime = audioRecorder.currentTime
                strongSelf.recordingMessageTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] timer in
                    guard let strongSelf = self else {
                        timer.invalidate()
                        return
                    }
                    DispatchQueue.main.async {
                        if !strongSelf.isRecordingVoiceMessage {
                            strongSelf.recordingMessageTimer?.invalidate()
                        } else {
                            if let currentTime = strongSelf.audioRecorder?.currentTime {
                                strongSelf.currentVoiceMessageTime = currentTime
                            }
                        }
                    }
                }
            } catch {
                strongSelf.audioRecorder?.stop()
                strongSelf.audioRecorder = nil
                strongSelf.isRecordingVoiceMessage = false
                strongSelf.presentAlert(title: Text("MessageInputViewModel.recordingMessageFailedAlertTitle", comment: "Recording voice message failed."))
                MessageInputViewModel.logger.error("Failed to start audio recording: \(error.localizedDescription)")
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
    
    nonisolated func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        DispatchQueue.main.async {
            if let error = error {
                MessageInputViewModel.logger.error("audioRecorderEncodeErrorDidOccur: \(error.localizedDescription)")
            }
            try? AVAudioSession.sharedInstance().setActive(false)
        }
    }
    
    nonisolated func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        try? AVAudioSession.sharedInstance().setActive(false)
    }
}

extension MessageInputViewModel: AVAudioPlayerDelegate {
    func startPlaying(_ url: URL, attachmentId: Int? = nil) async throws {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback)
            try audioSession.setActive(true)
        } catch {
            presentAlert(title: Text("MessageInputViewModel.failedToSetupaudioOnYourDeviceAlertTitle", comment: "Failed to setup audio on your device"), .error)
            MessageInputViewModel.logger.error("startPlaying: Failed: \(error.localizedDescription)")
            throw error
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf : url)
        } catch {
            presentAlert(title: Text("MessageInputViewModel.failedToPlayAudioOnYourDevice", comment: "Failed to play audio on your device"), .error)
            MessageInputViewModel.logger.error("Playing voice message failed: \(error.localizedDescription)")
            throw error
        }
        
        audioPlayer?.delegate = self
        audioPlayer?.prepareToPlay()
        audioPlayer?.play()
        totalAudioMessageTime = audioPlayer?.duration
        if let currentTime = self.audioPlayer?.currentTime, let duration = self.audioPlayer?.duration {
            self.playingAudioProgress = currentTime / duration
        }
        playingMessageTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { [weak self] timer in
            guard let strongSelf = self else {
                timer.invalidate()
                return
            }
            DispatchQueue.main.async {
                if !strongSelf.isVoiceMessagePlaying {
                    strongSelf.playingMessageTimer?.invalidate()
                } else {
                    if let currentTime = strongSelf.audioPlayer?.currentTime, let duration = strongSelf.audioPlayer?.duration {
                        strongSelf.playingAudioProgress = currentTime / duration
                    }
                }
            }
        }
    }
    
    func stopPlaying() {
        audioPlayer?.stop()
        isVoiceMessagePlaying = false
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
    
    func startPlayingRecordedVoiceMessage() async {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let voiceMessageFilePath = documentsDirectory.appendingPathComponent(Constants.voiceMessageFileName)
        do {
            try await startPlaying(voiceMessageFilePath)
            self.isVoiceMessagePlaying = true
        } catch {
            
        }
    }
    
    nonisolated internal func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isVoiceMessagePlaying = false
        }
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
    
    nonisolated internal func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        DispatchQueue.main.async {
            if let error = error {
                MessageInputViewModel.logger.error("audioPlayerDecodeErrorDidOccur: \(error.localizedDescription)")
            } else {
                MessageInputViewModel.logger.error("audioPlayerDecodeErrorDidOccur")
            }
        }
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}
