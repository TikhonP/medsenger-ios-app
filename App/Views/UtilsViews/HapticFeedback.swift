//
//  HapticFeedback.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 09.12.2022.
//  Copyright © 2022 TelePat ltd. All rights reserved.
//

import Foundation
import UIKit

class HapticFeedback {
    static let shared = HapticFeedback()
    
    func preparePlay() {
        UIImpactFeedbackGenerator().prepare()
    }
    
    func prepareNotify() {
        UINotificationFeedbackGenerator().prepare()
    }
    
    func play(_ feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: feedbackStyle).impactOccurred()
    }
    
    func notify(_ feedbackType: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(feedbackType)
    }
    
    func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
