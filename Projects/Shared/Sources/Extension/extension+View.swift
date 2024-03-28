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

extension View {
    
    public func bottomSheet(isShown: Binding<Bool>, mumoryBottomSheet: MumoryBottomSheet) -> some View {
        self.modifier(BottomSheetViewModifier(isShown: isShown, mumoryBottomSheet: mumoryBottomSheet))
    }
    
    public func rewardBottomSheet(isShown: Binding<Bool>) -> some View {
        self.modifier(RewardBottomSheetViewModifier(isShown: isShown))
    }
}
