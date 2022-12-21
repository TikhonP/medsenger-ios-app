//
//  Alertable.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 09.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import SwiftUI

/// Binding type for alert in SwiftUI View
struct AlertInfo: Identifiable {
    let id = UUID()
    let alert: Alert
    
    init(_ alert: Alert) {
        self.alert = alert
    }
    
    init(title: Text, message: Text? = nil, dismissButton: Alert.Button? = nil) {
        self.alert = Alert(title: title, message: message, dismissButton: dismissButton)
    }
}

/// SwiftUI alert system
///
/// Use `alert` when you want to present alert from your view model
/// First create view model conforming to protocol:
///
///     final class ContentViewModel: ObservableObject, Alertable {
///         @Published var alert: AlertInfo?
///     }
///
/// Then use it in the view:
///
///     @StateObject private var contentViewModel = ContentViewModel()
///     var body: some View {
///         Button("Tap to show alert") {
///             showAlert = true
///         }
///         .alert(item: $contentViewModel.alert) { $0.alert }
///     }
///
protocol Alertable: AnyObject, ObservableObject {
    
    /// Binding varible for alert type
    var alert: AlertInfo? { get set }
}

extension Alertable {
    
    /// Throws an alert with ``AlertInfo``
    /// - Parameters:
    ///   - alertInfo: The ``AlertInfo`` object.
    ///   - feedbackType: Optional feedback type if you need haptic feedback.
    internal func presentAlert(_ alertInfo: AlertInfo, _ feedbackType: UINotificationFeedbackGenerator.FeedbackType? = nil) {
        DispatchQueue.main.async {
            if let feedbackType = feedbackType {
                HapticFeedback.shared.prepareNotify()
                HapticFeedback.shared.notify(feedbackType)
            }
            self.alert = alertInfo
        }
    }
    
    /// Throws an alert with `Alert`
    /// - Parameters:
    ///   - alert: The `Alert` object
    ///   - feedbackType: Optional feedback type if you need haptic feedback.
    internal func presentAlert(_ alert: Alert, _ feedbackType: UINotificationFeedbackGenerator.FeedbackType? = nil) {
        self.presentAlert(.init(alert), feedbackType)
    }
    
    /// Throws an alert with one button.
    /// - Parameters:
    ///   - title: The title of the alert.
    ///   - message: The message to display in the body of the alert.
    ///   - dismissButton: The button that dismisses the alert.
    ///   - feedbackType: Optional feedback type if you need haptic feedback.
    internal func presentAlert(title: Text, message: Text? = nil, dismissButton: Alert.Button? = nil, _ feedbackType: UINotificationFeedbackGenerator.FeedbackType? = nil) {
        self.presentAlert(AlertInfo(title: title, message: message, dismissButton: dismissButton), feedbackType)
    }
    
    /// Throws a global alert.
    /// - Parameter feedbackType: Optional feedback type if you need haptic feedback.
    internal func presentGlobalAlert(_ feedbackType: UINotificationFeedbackGenerator.FeedbackType? = .error) {
        let result = ContentViewModel.shared.getGlobalAlert()
        if let title = result.title {
            self.presentAlert(AlertInfo(title: title, message: result.message), feedbackType)
        }
    }
}
