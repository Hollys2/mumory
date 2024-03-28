//
//  extension+View.swift
//  Shared
//
//  Created by 다솔 on 2024/03/28.
//  Copyright © 2024 hollys. All rights reserved.
//


import SwiftUI

extension View {

    public func generateHapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
}
