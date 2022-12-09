//
//  Alertable.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 09.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import UIKit

struct AlertInfo: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

protocol Alertable: AnyObject, ObservableObject {
    var alert: AlertInfo? { get set }
}

extension Alertable {
    
    /// Throw alert
    /// - Parameters:
    ///   - alert: AlertType instance
    ///   - feedbackType: optional feedback type if you need haptic feedback
    internal func presentAlert(_ alert: AlertInfo, _ feedbackType: UINotificationFeedbackGenerator.FeedbackType? = nil) {
        DispatchQueue.main.async {
            if let feedbackType = feedbackType {
                HapticFeedback.shared.prepareNotify()
                HapticFeedback.shared.notify(feedbackType)
            }
            self.alert = alert
        }
    }
    
    internal func presentGlobalAlert() {
        let globalAlert = ContentViewModel.shared.getGlobalAlert()
        if !globalAlert.title.isEmpty {
            self.presentAlert(
                AlertInfo(title: globalAlert.title, message: globalAlert.message), .error)
        }
    }
}
