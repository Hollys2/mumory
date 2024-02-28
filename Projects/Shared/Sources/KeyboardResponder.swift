//
//  KeyboardResponder.swift
//  Shared
//
//  Created by 다솔 on 2024/02/22.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Combine

public class KeyboardResponder: ObservableObject {
    
    @Published public var keyboardHeight: CGFloat = 0
    @Published public var isKeyboardHiddenButtonShown: Bool = false
    
    var keyboardShowCancellable: AnyCancellable?
    var keyboardHideCancellable: AnyCancellable?

    public init() {
        keyboardShowCancellable = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .sink { notification in
                let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
                let keyboardHeight = keyboardSize?.height ?? 0
                
                guard let duration: TimeInterval = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
                
//                print("keyboardHeight: \(keyboardHeight)")

                DispatchQueue.main.async {
                    self.isKeyboardHiddenButtonShown = true
                    
                    withAnimation(.spring(response: 0.45, dampingFraction: 1)) {
                        self.keyboardHeight = keyboardHeight
                    }
                }
            }

        keyboardHideCancellable = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { _ in
                DispatchQueue.main.async {
                    self.isKeyboardHiddenButtonShown = false
                    
                    withAnimation(.spring(response: 0.45, dampingFraction: 1)) {
                        self.keyboardHeight = 0
                    }
                }
            }
    }
}

