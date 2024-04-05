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
//        self.listenForKeyboardNotifications()
        
        keyboardShowCancellable = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .sink { notification in
                let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
                let keyboardHeight = keyboardSize?.height ?? 0

                //                guard let duration: TimeInterval = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }

                DispatchQueue.main.async {
                    withAnimation(.easeInOut(duration: 0.45)) {
                        self.keyboardHeight = keyboardHeight
                        self.isKeyboardHiddenButtonShown = true
                    }
                }
            }

        keyboardHideCancellable = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { _ in
                DispatchQueue.main.async {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        self.keyboardHeight = 0
                        self.isKeyboardHiddenButtonShown = false
                    }
                }
            }
    }
    
    public func listenForKeyboardNotifications() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidShowNotification,
                                               object: nil,
                                               queue: .main) { (notification) in
            guard let userInfo = notification.userInfo,
                  let keyboardRect = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
            
            DispatchQueue.main.async {
//                withAnimation(.easeInOut(duration: 0.45)) {
                    self.keyboardHeight = keyboardRect.height
                    self.isKeyboardHiddenButtonShown = true
//                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidHideNotification,
                                               object: nil,
                                               queue: .main) { (notification) in
            
            DispatchQueue.main.async {
//                withAnimation(.easeInOut(duration: 0.45)) {
                    self.keyboardHeight = 0
                    self.isKeyboardHiddenButtonShown = false
//                }
            }
        }
    }
}

