//
//  ReadSize.swift
//  Medsenger
//
//  Created by Tikhon Petrishchev on 02.01.2023.
//  Copyright © 2023 TelePat ltd. All rights reserved.
//

import SwiftUI

fileprivate struct ReadSizeViewModifier<K: PreferenceKey>: ViewModifier where K.Value == CGSize {
    let onSizeChange: (CGSize) -> Void
    
    func body(content: Content) -> some View {
        Group {
            content.background(
                GeometryReader { proxy in
                    Color.clear.preference(
                        key: K.self,
                        value: proxy.size
                    )
                }
            )
        }
        .onPreferenceChange(K.self) { preferences in
            onSizeChange(preferences)
        }
    }
}

fileprivate struct ReadMessagesInputSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> Value) {
        _ = nextValue()
    }
}

fileprivate struct ReadMessageSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> Value) {
        _ = nextValue()
    }
}

extension View {
    func readMessagesInputSize(onChange: @escaping (CGSize) -> Void) -> some View {
        modifier(ReadSizeViewModifier<ReadMessagesInputSizePreferenceKey>(onSizeChange: onChange))
    }
    
    func readMessageSize(onChange: @escaping (CGSize) -> Void) -> some View {
        modifier(ReadSizeViewModifier<ReadMessageSizePreferenceKey>(onSizeChange: onChange))
    }
}
