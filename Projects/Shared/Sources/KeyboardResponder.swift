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
                withAnimation(.easeInOut(duration: duration)) {
                    self.isKeyboardHiddenButtonShown = true
                    DispatchQueue.main.async {
                        self.keyboardHeight = keyboardHeight
                    }
                }
            }
        
        keyboardHideCancellable = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { notification in
                guard let duration: TimeInterval = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
                withAnimation(.easeInOut(duration: duration)) {
                    self.isKeyboardHiddenButtonShown = false
                    DispatchQueue.main.async {
                        self.keyboardHeight = 0
                    }
                }
            }
    }
}

